#import "EsZone.h"
#import "EsRoom+Internal.h"

/**
 * Internal methods for EsZone. Not meant for public use.
 */
@interface EsZone()

@property int zoneId;
@property(strong) NSString* name;

- (void) addRoom:(EsRoom*) room;
- (void) removeRoom:(int) roomId;
- (void) addJoinedRoom:(EsRoom*) room;
- (void) removeJoinedRoom:(EsRoom*) room;

@end

