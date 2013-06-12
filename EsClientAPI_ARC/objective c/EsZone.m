#import "EsZone+Internal.h"


@implementation EsZone

@synthesize zoneId = zoneId_;
@synthesize name = name_;

- (id) init {
	if (self = [super init]) {
		roomsById_ = [[NSMutableDictionary alloc] init];
		roomsByName_ = [[NSMutableDictionary alloc] init];
        joinedRooms_ = [[NSMutableArray alloc] init];
	}
	return self;
}

- (EsRoom*) roomByName:(NSString*) roomName {
	return [roomsByName_ objectForKey:roomName];
}

- (EsRoom*) roomById:(int) roomId {
	return [roomsById_ objectForKey:[NSNumber numberWithInt:roomId]];
}

- (NSArray*) rooms {
	return [roomsById_ allValues];
}

- (void) addRoom:(EsRoom*) room {
	room.zoneId = self.zoneId;
	[roomsById_ setObject:room forKey:[NSNumber numberWithInt:room.roomId]];
	[roomsByName_ setObject:room forKey:room.name];
}

- (void) removeRoom:(int) roomId {
	EsRoom* r = [self roomById:roomId];
	if (r != nil) {
		[roomsById_ removeObjectForKey:[NSNumber numberWithInt:roomId]];
		[roomsByName_ removeObjectForKey:r.name];
	}
}

- (void) addJoinedRoom:(EsRoom*) room {
    if (![joinedRooms_ containsObject:room]) {
        [joinedRooms_ addObject:room];
    }
}

- (void) removeJoinedRoom:(EsRoom*) room {
    if ([joinedRooms_ containsObject:room]) {
        [joinedRooms_ removeObject:room];
    }
}

- (NSArray*) joinedRooms {
    return joinedRooms_;
}


@end
