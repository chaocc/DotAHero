#import "EsRoom.h"

/**
 * Internal methods for EsRoom. Not meant for public use.
 */
@interface EsRoom() 

/**
 * The id of the room.
 */
@property int roomId;

/**
 * The name of the room.
 */
@property(strong) NSString* name;

/**
 * The id of the zone this room belongs to.
 */
@property int zoneId;

/**
 * True if the room is password protected.
 */
@property BOOL hasPassword;


/**
 * The room description.
 */
@property(strong) NSString* roomDescription;

/**
 * Allowable capacitory for the room.
 */
@property int capacity;

/**
 * True if the room is hidden.
 */
@property BOOL isHidden;

/**
 * The password for this room, if any.
 */
@property(strong) NSString* password;

/**
 * True if you belong to this room.
 */
@property BOOL isJoined;

/**
 * Number of users in this room.
 */
@property int userCount;


/**
 * Removes all users and flags isJoined as false. Not intended for public use.
 * @private
 */
- (void) purgeUsers;

/**
 * Removes all room variables. Not intended for public use.
 * @private
 */
- (void) purgeRoomVariables;

/**
 * Adds a new RoomVariable. Not intended for public use. Use the AddRoomVariableRequest to add a RoomVariable.
 * @param	The RoomVariable to add.
 * @private
 */
- (void) addRoomVariable:(EsRoomVariable*) rv;

/**
 * Removes a RoomVariable by name. Not intended for public use. Use the RemoveRoomVariableRequest to remove a RoomVariable.
 * @param	Name of the variable to remove
 * @private
 */
- (void) removeRoomVariable:(NSString*) name;

/**
 * Add User to the room. Not intended for public use.
 * @param	User to add to the room.
 * @private
 */
- (void) addUser:(EsUser*) u;

/**
 * Remove a user from the room by name. Not intended for public use.
 * @param	Name of the user to remove.
 * @private
 */
- (void) removeUser:(NSString*) name;

@end