#import "EsManagerHelper.h"

@interface EsManagerHelper()

- (id) initWithElectroServer:(ElectroServer *)es;

/*
 * Add event listeners for everything needed to manage the state of things.
 * We give the event listeners the highest priority so that the events are received here before anywhere else.
 * @private
 */
- (void) registerListeners;

/**
 * Invoked when the client login attempt has been responded to. Creates a new User instance, tells it that it is you
 * and adds it to the UserManager. If any user variables came in on the login response, then add those to the User too.
 * @param	LoginResponse event object
 * @private
 */
- (void) onLoginResponse:(EsLoginResponse*) e;

/**
 * Invoked when you have joined a room. 
 * @param	The JoinRoomEvent object
 * @private
 */
- (void) onJoinRoomEvent:(EsJoinRoomEvent*) e;

/**
 * Takes a UserListEntry and map it to a User object, and return it.
 * @param	UserListEntry object
 * @return User object
 */
//- (EsUser*) userListEntryToUser:(EsUserListEntry*) entry;


- (EsUser*) mergeUserListEntry:(EsUserListEntry*) entry toUser:(EsUser*) user;

/**
 * Takes an array of UserVariable objects and adds each one individually to the User passed in.
 * @param	User that owns the variables
 * @param	Array of UserVariables
 */
- (void) parseUserVariables:(EsUser*) user list:(NSArray*) list;

/**
 * Invoked when you have left a room. Purges cached users from the room. 
 * Decrements each user's reference from that room in the user manager.
 * @param	The LeaveRoomEvent object
 * @private
 */
- (void) onLeaveRoomEvent:(EsLeaveRoomEvent*) e;

/**
 * Fired when a user joins or leaves the room, 
 * starts or stops sending a video stream (Flash only), 
 * or if their Operator status changes
 * @param	The RoomUserUpdateEvent object
 * @private
 */
- (void) onRoomUserUpdateEvent:(EsUserUpdateEvent*) e;

/**
 * This is called when certain room properties are updated, 
 * such as the allowable capacity, its description, whether it 
 * is hidden or not, if it has a password, etc
 * @param	The UpdateRoomDetailsEvent object
 * @private
 */
- (void) onUpdateRoomDetailsEvent:(EsUpdateRoomDetailsEvent*) e;

/**
 * Called when you have joined your first room in a zone.
 * @param	The JoinZoneEvent object.
 * @private
 */
- (void) onJoinZoneEvent:(EsJoinZoneEvent*) e;

/**
 * If you leave a room and are no longer in any rooms in that zone, 
 * then this event occurs.
 * @param	The LeaveRoomEvent object
 * @private
 */
- (void) onLeaveZoneEvent:(EsLeaveZoneEvent*) e;

/**
 * If you belong to a room *and* you are subscribed to receive zone 
 * update events (which you are by default), then this event occurs 
 * when a room is added, removed, or its public information is updated.
 * @param	The zoneUpdateEvent object
 * @private
 */
- (void) onZoneUpdateEvent:(EsZoneUpdateEvent*) e;

/**
 * Converts a RoomListEntry object into a Room object, and adds it to the zone specified.
 * @param	The zone in which to add the Room
 * @param	The RoomListEntry object to be converted
 * @private
 */
- (void) parseAndAddRoom:(EsRoomListEntry*) room zone:(EsZone*) zone;

/**
 * When a room variable for a room that you belong to is created, 
 * removed, or updated, this event occurs. You must also be 
 * subscribed to receive these events, which you are by default.
 * @param	The RoomVariableUpdateEvent object
 * @private
 */
- (void) onRoomVariableUpdateEvent:(EsRoomVariableUpdateEvent*) e;

/**
 * Called when a user variable for you or someone in one of your rooms has been created, removed, 
 * or updated. You must also be subscribed to receive user variable update events, 
 * which you are by default.
 * @param	The UserVariableUpdateEvent
 * @private
 */
- (void) onUserVariableUpdateEvent:(EsUserVariableUpdateEvent*) e;

/**
 * Invoked when the online/offline status of one of your buddies changes. It is also invoked if you just added a new buddy, informing you of that buddies online/offline status.
 * @param	The BuddyStatusUpdateEvent
 * @private
 */
- (void) onBuddyStatusUpdatedEvent:(EsBuddyStatusUpdateEvent*) e;

@end
