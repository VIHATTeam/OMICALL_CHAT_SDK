#import "LivetalkSdkPlugin.h"
#if __has_include(<livetalk_sdk/livetalk_sdk-Swift.h>)
#import <livetalk_sdk/livetalk_sdk-Swift.h>
#else
// Support project import fallback if the generated compatibility header
// is not copied when this plugin is created as a library.
// https://forums.swift.org/t/swift-static-libraries-dont-copy-generated-objective-c-header/19816
#import "livetalk_sdk-Swift.h"
#endif

@implementation LivetalkSdkPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftLivetalkSdkPlugin registerWithRegistrar:registrar];
}
@end
