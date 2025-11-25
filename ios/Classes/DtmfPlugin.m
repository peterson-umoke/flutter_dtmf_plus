#import "DtmfPlugin.h"
#import <flutter_dtmf_pro/flutter_dtmf_pro-Swift.h>

@implementation DtmfPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftDtmfPlugin registerWithRegistrar:registrar];
}
@end
