
import Flutter
import UIKit
import AVFoundation

public class SwiftDtmfPlugin: NSObject, FlutterPlugin {

    // Built on the first tone, never at registration. Reading
    // `mainMixerNode` makes a synchronous audio-server round trip; doing it
    // while plugins register at launch can time out (_ReportRPCTimeout) and
    // abort the app before its first frame.
    private var engine: AVAudioEngine?
    private let player = AVAudioPlayerNode()

    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "flutter_dtmf", binaryMessenger: registrar.messenger())
        let instance = SwiftDtmfPlugin()
        registrar.addMethodCallDelegate(instance, channel: channel)
    }

    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard call.method == "playTone" else {
            result(FlutterMethodNotImplemented)
            return
        }
        let arguments = call.arguments as? NSDictionary
        guard let digits = arguments?["digits"] as? String else {
            result(FlutterError(code: "invalid_args", message: "playTone requires digits", details: nil))
            return
        }
        let samplingRate = arguments?["samplingRate"] as? Double ?? 8000.0
        let durationMs = arguments?["durationMs"] as? Int ?? 500
        let volume = arguments?["volume"] as? Double
        result(playTone(digits: digits, volume: volume, samplingRate: samplingRate, durationMs: durationMs))
    }

    /// Plays [digits] and returns whether playback started. Every path
    /// returns, so the Dart future always completes exactly once.
    func playTone(digits: String, volume: Double?, samplingRate: Double, durationMs: Int) -> Bool {
        let sampleRate = Float(samplingRate)
        guard let tones = DTMF.tonesForString(digits), !tones.isEmpty,
              let audioFormat = AVAudioFormat(commonFormat: .pcmFormatFloat32, sampleRate: samplingRate, channels: 2, interleaved: false)
        else { return false }

        var allSamples = [Float]()
        for tone in tones {
            allSamples.append(contentsOf: DTMF.generateDTMF(tone, markSpace: MarkSpaceType(Float(durationMs), Float(durationMs)), sampleRate: sampleRate))
        }

        let frameCount = AVAudioFrameCount(allSamples.count)
        guard frameCount > 0,
              let buffer = AVAudioPCMBuffer(pcmFormat: audioFormat, frameCapacity: frameCount),
              let channelMemory = buffer.floatChannelData
        else { return false }
        buffer.frameLength = frameCount
        for channelIndex in 0 ..< Int(audioFormat.channelCount) {
            memcpy(channelMemory[channelIndex], allSamples, Int(frameCount) * MemoryLayout<Float>.size)
        }

        let engine = self.engine ?? {
            let created = AVAudioEngine()
            created.attach(player)
            self.engine = created
            return created
        }()
        engine.connect(player, to: engine.mainMixerNode, format: audioFormat)

        if !engine.isRunning {
            do {
                try engine.start()
            } catch {
                // play() on a stopped engine raises an Objective-C exception
                // and crashes the app, so stop here.
                print("DTMF engine start failed - \(error)")
                return false
            }
        }

        player.scheduleBuffer(buffer, at: nil, completionHandler: nil)
        if let volume = volume {
            player.volume = Float(volume)
        }
        player.play()
        return true
    }
}
