#import <Foundation/Foundation.h>
#import "EsRoomVariable.h"
#import "EsUser.h"

/**
 * This class represents a room on the server. 
 * It stores a list of users in the room, room variables, and many other room properties.
 */
@interface EsRoom : NSObject {
	@private
	NSMutableDictionary* roomVariablesByName_;
	NSMutableDictionary* usersByName_;
}

/**
 * The id of the room.
 */
@property(readonly) int roomId;

/**
 * The name of the room.
 */
@property(readonly,strong) NSString* name;

/**
 * The id of the zone this room belongs to.
 */
@property(readonly) int zoneId;

/**
 * True if the room is password protected.
 */
@property(readonly) BOOL hasPassword;


/**
 * The room description.
 */
@property(readonly, strong) NSString* roomDescription;

/**
 * Allowable capacitory for the room.
 */
@property(readonly) int capacity;

/**
 * True if the room is hidden.
 */
@property(readonly) BOOL isHidden;

/**
 * The password for this room, if any.
 */
@property(readonly, strong) NSString* password;

/**
 * True if you belong to this room.
 */
@property(readonly) BOOL isJoined;

/**
 * Number of users in this room.
 */
@property(nonatomic, readonly) int userCount;

/**
 * Gets a RoomVariable object by name.
 * @param	Name of the variable to find.
 * @return RoomVariable object that has the name passed in.
 */
- (EsRoomVariable*) roomVariableByName:(NSString*) name;

/**
 * Gets the list of Users in this room.
 */
- (NSArray*) users;

/**
 * Gets the list of RoomVariable objects.
 */
- (NSArray*) roomVariables;
@end
