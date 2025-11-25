#import "DtmfPlugin.h"
#import <flutter_dtmf_plus/flutter_dtmf_plus-Swift.h>

@implementation DtmfPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftDtmfPlugin registerWithRegistrar:registrar];
}
@end
