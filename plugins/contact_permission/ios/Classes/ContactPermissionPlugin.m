#import "ContactPermissionPlugin.h"
#if __has_include(<contact_permission/contact_permission-Swift.h>)
#import <contact_permission/contact_permission-Swift.h>
#else
// Support project import fallback if the generated compatibility header
// is not copied when this plugin is created as a library.
// https://forums.swift.org/t/swift-static-libraries-dont-copy-generated-objective-c-header/19816
#import "contact_permission-Swift.h"
#endif

@implementation ContactPermissionPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftContactPermissionPlugin registerWithRegistrar:registrar];
}
@end
