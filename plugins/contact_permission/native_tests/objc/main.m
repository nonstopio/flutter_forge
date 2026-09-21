#import "ContactPermissionPlugin.h"
#import "contact_permission-Swift.h"

static NSObject<FlutterPluginRegistrar>* registered;
@interface Registrar : NSObject<FlutterPluginRegistrar>
@end
@implementation Registrar
@end
@implementation SwiftContactPermissionPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
    registered = registrar;
}
@end

int main(void) {
    @autoreleasepool {
        Registrar* registrar = [Registrar new];
        [ContactPermissionPlugin registerWithRegistrar:registrar];
        NSCAssert(registered == registrar, @"Registration must be forwarded unchanged");
        puts("Objective-C registration check passed");
    }
    return 0;
}
