#import "EsRoom+Internal.h"


@implementation EsRoom

@synthesize roomId;
@synthesize name;
@synthesize zoneId;
@synthesize hasPassword;
@synthesize roomDescription;
@synthesize capacity;
@synthesize isHidden;
@synthesize password;
@synthesize isJoined;
@synthesize userCount;

- (id) init {
	if (self = [super init]) {
		roomVariablesByName_ = [[NSMutableDictionary alloc] init];
		usersByName_ = [[NSMutableDictionary alloc] init];
		self.capacity = -1;
	}
	return self;
}

- (EsRoomVariable*) roomVariableByName:(NSString*) n {
	return [roomVariablesByName_ objectForKey:n];
}

- (NSArray*) users {
	return [usersByName_ allValues];
}
		

- (NSArray*) roomVariables {
	return [roomVariablesByName_ allValues];
}

///
/// Private
///

- (void) purgeUsers {
	[usersByName_ removeAllObjects];
	self.isJoined = false;
}

- (void) purgeRoomVariables {
	[roomVariablesByName_ removeAllObjects];
}

- (void) addRoomVariable:(EsRoomVariable*) rv {
	[roomVariablesByName_ setObject:rv forKey:rv.name];
}

- (void) removeRoomVariable:(NSString*) n {
	[roomVariablesByName_ removeObjectForKey:n];
}

- (void) addUser:(EsUser*) u {
	[usersByName_ setObject:u forKey:u.userName];
	if (u.isMe) {
		self.isJoined = true;
	}
}

- (void) removeUser:(NSString*) n {
	EsUser* u = [usersByName_ objectForKey:n];
	if (u.isMe) {
		self.isJoined = false;
	}
	[usersByName_ removeObjectForKey:n];
}

// Original method looked like this. No idea why it's jumping through
// these hoops.
//    public int getUserCount() {
//        if (usersByName != null && !usersByName.isEmpty()) {
//            return usersByName.size();
//        } else {
//            return userCount;
//        }
//    }
- (int) userCount {
	return [usersByName_ count];
}



@end
