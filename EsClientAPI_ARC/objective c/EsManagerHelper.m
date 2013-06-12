#import "EsManagerHelper+Internal.h"
#import "ElectroServer.h"
#import "EsUser+Internal.h"
#import "EsZoneManager+Internal.h"
#import "EsUserManager+Internal.h"
#import "EsRoom+Internal.h"
#import "EsZone+Internal.h"
#import "DLOG.h"


@implementation EsManagerHelper

@synthesize userManager = userManager_;
@synthesize zoneManager = zoneManager_;


- (id) initWithElectroServer:(ElectroServer*) es {
	if ((self = [super init])) {
		// assign
		es_ = es;
		userManager_ = [[EsUserManager alloc] init];
		zoneManager_ = [[EsZoneManager alloc] init];
		[self registerListeners];
	}
	return self;
}

- (void) registerListeners {
	[es_.engine addEventListenerWithTarget:self 
		action:@selector(onLoginResponse:) 
		eventIdentifier:EsMessageType_LoginResponse 
		priority:EsEventDispatcher_MaxPriority];
	[es_.engine addEventListenerWithTarget:self 
		action:@selector(onJoinRoomEvent:) 
		eventIdentifier:EsMessageType_JoinRoomEvent 
		priority:EsEventDispatcher_MaxPriority];
	[es_.engine addEventListenerWithTarget:self 
		action:@selector(onLeaveRoomEvent:) 
		eventIdentifier:EsMessageType_LeaveRoomEvent 
		priority:EsEventDispatcher_MaxPriority];
	[es_.engine addEventListenerWithTarget:self 
		action:@selector(onRoomUserUpdateEvent:) 
		eventIdentifier:EsMessageType_UserUpdateEvent 
		priority:EsEventDispatcher_MaxPriority];
	[es_.engine addEventListenerWithTarget:self 
		action:@selector(onUpdateRoomDetailsEvent:) 
		eventIdentifier:EsMessageType_UpdateRoomDetailsEvent 
		priority:EsEventDispatcher_MaxPriority];
	[es_.engine addEventListenerWithTarget:self 
		action:@selector(onJoinZoneEvent:) 
		eventIdentifier:EsMessageType_JoinZoneEvent 
		priority:EsEventDispatcher_MaxPriority];
	[es_.engine addEventListenerWithTarget:self 
		action:@selector(onLeaveZoneEvent:) 
		eventIdentifier:EsMessageType_LeaveZoneEvent 
		priority:EsEventDispatcher_MaxPriority];
	[es_.engine addEventListenerWithTarget:self 
		action:@selector(onZoneUpdateEvent:) 
		eventIdentifier:EsMessageType_ZoneUpdateEvent 
		priority:EsEventDispatcher_MaxPriority];
	[es_.engine addEventListenerWithTarget:self 
		action:@selector(onRoomVariableUpdateEvent:) 
		eventIdentifier:EsMessageType_RoomVariableUpdateEvent 
		priority:EsEventDispatcher_MaxPriority];
	[es_.engine addEventListenerWithTarget:self 
		action:@selector(onUserVariableUpdateEvent:) 
		eventIdentifier:EsMessageType_UserVariableUpdateEvent 
		priority:EsEventDispatcher_MaxPriority];
	[es_.engine addEventListenerWithTarget:self 
		action:@selector(onBuddyStatusUpdatedEvent:) 
		eventIdentifier:EsMessageType_BuddyStatusUpdatedEvent 
		priority:EsEventDispatcher_MaxPriority];
}

- (void) onLoginResponse:(EsLoginResponse*) e {
	if (e.successful) {
		DLOG(@"onLoginResponse");
		EsUser* u = [[EsUser alloc] init];
		u.userName = e.userName;
		u.isMe = true;
		
		for (NSString* name in [e.userVariables allKeys]) {
			EsObject* obr = [e.userVariables objectForKey:name];
			EsUserVariable* uv = [[EsUserVariable alloc] init];
			uv.name = name;
			uv.value = obr;
			[u addUserVariable:uv];
		}
		
		[userManager_ addUser:u];
	}
}

- (void) onJoinRoomEvent:(EsJoinRoomEvent*) e {
	DLOG(@"");
	EsZone* z = [zoneManager_ zoneById:e.zoneId];
	// we assume that zoneManager will have the zone
	DLOG(@"zone %@", z);
	
	EsRoom* r = [z roomById:e.roomId];
	if (r == nil) {
		r = [[EsRoom alloc] init];
		r.roomId = e.roomId;
		r.name = e.roomName;
		[z addRoom:r];
	}
	
	r.roomDescription = e.roomDescription;
	r.hasPassword = e.hasPassword;
	r.capacity = e.capacity;
	r.isHidden = e.hidden;
	
	for (EsRoomVariable* rve in e.roomVariables) {
		[r addRoomVariable:rve];
	}
	
	for (EsUserListEntry* entry in e.users) {
        EsUser *u = [[EsUser alloc] init];
        u.userName = entry.userName;
        u = [userManager_ addUser:u];
        u = [self mergeUserListEntry:entry toUser:u];
        [r addUser:u];
	}
    
    [z addJoinedRoom:r];
}

- (EsUser*) mergeUserListEntry:(EsUserListEntry*) entry toUser:(EsUser*) user {
    [self parseUserVariables:user list:entry.userVariables];
    return user;
}

- (void) parseUserVariables:(EsUser*) user list:(NSArray*) list {
	DLOG(@"");
	for (EsUserVariable* uve in list) {
		[user addUserVariable:uve];
	}
}

- (void) parseAndAddRoom:(EsRoomListEntry*) room zone:(EsZone*) zone {
	DLOG(@"");
	EsRoom* r = [[EsRoom alloc] init];
	
	r.roomId = room.roomId;
	r.name = room.roomName;
	r.roomDescription = room.roomDescription;
	r.capacity = room.capacity;
	r.userCount = room.userCount;
	r.hasPassword = room.hasPassword;
	
	[zone addRoom:r];
}

- (void) onLeaveRoomEvent:(EsLeaveRoomEvent*) e {
	DLOG(@"");
	EsZone* z = [zoneManager_ zoneById:e.zoneId];
    if (nil == z) {
        return;
    }
    
	EsRoom* r = [z roomById:e.roomId];
    if (nil == r) {
        return;
    }
	
	//after you leave, this is the number of users in that room
	int numUsers = [r.users count];
	
	//decrement the reference to each user in the user manager
	for (EsUser* u in r.users) {
		[userManager_ removeUser:u.userName];
	}
	
	//remove all user objects from room
	[r purgeUsers];
	[r purgeRoomVariables];
	
	//even though we aren't tracking the user objects, we want to keep track of the number of users
	r.userCount = numUsers;
	
	//Note: we don't remove the room because the room may still exist even though we're not in it. 
	//Rely on the ZoneUpdateEvent or LeaveZoneEvent to remove the room
    
    [z removeJoinedRoom:r];
}


- (void) onRoomUserUpdateEvent:(EsUserUpdateEvent*) e {
	DLOG(@"");
	EsUser* u = [userManager_ userByName:e.userName];
	EsZone* z = [zoneManager_ zoneById:e.zoneId];
	EsRoom* r = [z roomById:e.roomId];
	
	if (u == nil) {
		u = [[EsUser alloc] init];
		u.userName = e.userName;
	}

    [self parseUserVariables:u list:e.userVariables];
	
	switch (e.action) {
		case EsUserUpdateAction_AddUser:
			u = [userManager_ addUser:u];
			[r addUser:u];
			break;
		case EsUserUpdateAction_DeleteUser:
			[userManager_ removeUser:u.userName];
			[r removeUser:e.userName];
			break;
			
//			case SendingVideoStream:
//				//flag that user is sending a video stream, and set the name of it
//				u.setIsSendingVideo(true);
//				u.setVideoStreamName(e.getVideoStreamName());
//				break;
//			case StoppingVideoStream:
//				//flag that the user is not sending a video stream, and clean up the stream name
//				u.setIsSendingVideo(false);
//				u.setVideoStreamName(null);
//				break;
//			case OperatorGranted:
//				//TODO: remove or use in some way. jira ticket ESV-19
//				break;
//			case OperatorRevoked:
//				//TODO: remove or use in some way. jira ticket ESV-19
//				break;
	}
}

- (void) onUpdateRoomDetailsEvent:(EsUpdateRoomDetailsEvent*) e {
	DLOG(@"");
	EsZone* z = [zoneManager_ zoneById:e.zoneId];
	EsRoom* r = [z roomById:e.roomId];
	
	if (e.capacityUpdated) {
		r.capacity = e.capacity;
	}
	
	if (e.roomDescriptionUpdated) {
		r.roomDescription = e.roomDescription;
	}
	
	if (e.hiddenUpdated) {
		r.isHidden = e.hidden;
	}
	
	if (e.hasPasswordUpdated) {
		r.hasPassword = e.hasPassword;
	}
	
	if (e.roomNameUpdated) {
		r.name = e.roomName;
		[z removeRoom:r.roomId];
		[z addRoom:r];
	}
}

- (void) onJoinZoneEvent:(EsJoinZoneEvent*) e {
	DLOG(@"");
	EsZone* z = [zoneManager_ zoneById:e.zoneId];
	
	if (z == nil) {
		z = [[EsZone alloc] init];
		z.zoneId = e.zoneId;
		z.name = e.zoneName;
		[zoneManager_ addZone:z];
	}
	
	for (EsRoomListEntry* rle in e.rooms) {
		[self parseAndAddRoom:rle zone:z];
	}
}

- (void) onLeaveZoneEvent:(EsLeaveZoneEvent*) e {
	DLOG(@"");
	[zoneManager_ removeZone:e.zoneId];
}

- (void) onZoneUpdateEvent:(EsZoneUpdateEvent*) e {
	DLOG(@"");
	EsZone* z = [zoneManager_ zoneById:e.zoneId];
    EsRoom* r = [z roomById:e.roomId];
	
	switch (e.action) {
		case EsZoneUpdateAction_AddRoom:
			[self parseAndAddRoom:e.roomListEntry zone:z];
			break;
		case EsZoneUpdateAction_DeleteRoom:
			[z removeRoom:e.roomId];
			break;
		case EsZoneUpdateAction_UpdateRoom:
            if (nil != e.roomListEntry) {
                r.userCount = e.roomListEntry.userCount;
            } else {
                r.userCount = e.roomCount;
            }
            
			break;
	}
}

- (void) onRoomVariableUpdateEvent:(EsRoomVariableUpdateEvent*) e {
	DLOG(@"");
	EsZone* z = [zoneManager_ zoneById:e.zoneId];
	EsRoom* r = [z roomById:e.roomId];
	
	EsRoomVariable* rv = [r roomVariableByName:e.name];
	if (rv == nil) {
		rv = [[EsRoomVariable alloc] init];
	}
	
	switch (e.action) {
		case EsRoomVariableUpdateAction_VariableCreated:
			rv.name = e.name;
			rv.value = e.value;
			rv.locked = e.locked;
			rv.persistent = e.persistent;
			[r addRoomVariable:rv];
			break;
		case EsRoomVariableUpdateAction_VariableDeleted:
			[r removeRoomVariable:e.name];
			break;
		case EsRoomVariableUpdateAction_VariableUpdated:
			if (e.lockStatusChanged) {
				rv.locked = e.locked;
			}
			if (e.valueChanged) {
				rv.value = e.value;
			}
			break;
	}
	
}

- (void) onUserVariableUpdateEvent:(EsUserVariableUpdateEvent*) e {
	DLOG(@"");
	EsUser* u = [userManager_ userByName:e.userName];
	
	EsUserVariable* uvFromEvent = e.variable;
	EsUserVariable* uv = [u userVariableWithName:uvFromEvent.name];
	if (uv == nil) {
		uv = uvFromEvent;
        if (e.action == EsUserVariableUpdateAction_VariableUpdated) {
            e.action = EsUserVariableUpdateAction_VariableCreated;
        }
	}
	
	switch (e.action) {
		case EsUserVariableUpdateAction_VariableCreated:
			[u addUserVariable:uv];
			break;
		case EsUserVariableUpdateAction_VariableDeleted:
			[u removeUserVariableWithName:uv.name];
			break;
		case EsUserVariableUpdateAction_VariableUpdated:
			uv.value = uvFromEvent.value;
			break;
	}
}

- (void) onBuddyStatusUpdatedEvent:(EsBuddyStatusUpdateEvent*) e {
	DLOG(@"");
	EsUser* u = [userManager_ userByName:e.userName];
	
	if (u == nil) {
		u = [[EsUser alloc] init];
		u.userName = e.userName;
	}
	
	if (!u.isBuddy) {
		u = [userManager_ addBuddy:u];
	}
	
	switch (e.action) {
		case EsBuddyStatusUpdateAction_LoggedIn:
			u.isLoggedIn = true;
			u.buddyVariable = e.esObject;
			break;
		case EsBuddyStatusUpdateAction_LoggedOut:
			u.isLoggedIn = false;
            if (e.esObject != nil) {
                u.buddyVariable = e.esObject;
            }            
			break;
	}
	
}

- (void) dealloc {
	DLOG(@"");
}

@end

