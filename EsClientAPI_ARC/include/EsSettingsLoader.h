#import <Foundation/Foundation.h>

@interface EsSettingsLoader : NSObject {
}
- (NSArray*) readServerSettings;
- (NSArray*) readServerSettingsFromFilename:(NSString*) filename;
@end

