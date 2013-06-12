#import <Foundation/Foundation.h>
#import "EsRoom.h"


@interface EsZone : NSObject {
	int zoneId_;
	NSString* name_;
	NSMutableDictionary* roomsById_;
	NSMutableDictionary* roomsByName_;
    NSMutableArray* joinedRooms_;
}

@property(readonly) int zoneId;
@property(readonly, strong) NSString* name;

/**
 * Gets a Room by name.
 * @return Room object with the name specified.
 */
- (EsRoom*) roomByName:(NSString*) roomName;

/**
 * Gets a Room by id.
 * @return Room object with the id specified.
 */
- (EsRoom*) roomById:(int) roomId;

/**
 * Gets the list of Room objects in this zone.
 */
- (NSArray*) rooms;

/**
 * Gets the list of rooms the user is joined to as an NSArray of EsRoom objects.
 */
- (NSArray*) joinedRooms;

@end
