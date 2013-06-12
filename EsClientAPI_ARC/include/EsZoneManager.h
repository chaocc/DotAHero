#import <Foundation/Foundation.h>
#import "EsZone.h"


/**
 * This class manages the list of zones that you should know about based on the rooms that you are in. 
 * Convenient methods are available for looking up rooms.
 * It is not intended that you would create a new instance of this class. It is 
 * instantiated and used by the ElectroServer class. You can access it through 
 * an ElectroServer class instance.
 */
@interface EsZoneManager : NSObject {
	NSMutableDictionary* zonesById_;
	NSMutableDictionary* zonesByName_;
}

/**
 * Gets a zone by name.
 * @return Zone object with the name specified.
 */
- (EsZone*) zoneByName:(NSString*) zoneName;

/**
 * Gets a zone by id.
 * @return Zone object with the id specified.
 */
- (EsZone*) zoneById:(int) zoneId;

/**
 * Gets the list of Zone objects being tracked.
 */
- (NSArray*) zones;

@end
