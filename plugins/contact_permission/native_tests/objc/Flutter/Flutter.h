#import <Foundation/Foundation.h>
@protocol FlutterPluginRegistrar <NSObject>
@end
@protocol FlutterPlugin <NSObject>
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar;
@end
