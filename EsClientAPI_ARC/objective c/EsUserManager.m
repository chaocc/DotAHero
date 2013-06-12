#import "EsUserManager+Internal.h"
#import "EsUser+Internal.h"
#import "DLOG.h"


@implementation EsUserManager

@synthesize me = me_;

- (id) init {
	if (self = [super init]) {
		usersByName_ = [[NSMutableDictionary alloc] init];
	}
	return self;
}

- (EsUser*) userByName:(NSString*) userName {
	return [usersByName_ objectForKey:userName];
}

- (NSArray*) users {
	return [usersByName_ allValues];
}

- (NSArray*) buddies {
	return nil;
}

/// 
/// (Internal)
///

- (BOOL) doesUserExist:(NSString*) userName {
	return [usersByName_ objectForKey:userName] != nil;
}

- (EsUser*) addBuddy:(EsUser*) u {
	u.isBuddy = true;
	u.isLoggedIn = true;
	u = [self addUser:u];
    return u;
}

- (void) removeBuddy:(EsUser*) u {
	u.isBuddy = false;
	[self removeUser:u.userName];
}

- (EsUser*) addUser:(EsUser*) u {
	DLOG(@"addUser");
	if (u.isMe) {
		me_ = u;
	}
	
	NSString* userName = u.userName;
	
	if ([self doesUserExist:userName]) {
		u = [self userByName:userName];
	}
	else {
		[usersByName_ setObject:u forKey:userName];
	}
	
	[u incrementReferences];
	
	return u;
}

- (void) removeUser:(NSString*) userName {
	if ([self doesUserExist:userName]) {
		EsUser* u = [self userByName:userName];
		int references = [u decrementReferences];
		
		if (references <= 0 && !u.isMe && !u.isBuddy) {
			[self reallyRemoveUser:u];
		}
		else {
			//            //trace("removeUser called for " + userName + ", but user wasn't found.");
		}
	}
}

- (void) reallyRemoveUser:(EsUser*) u {
	DLOG("reallyRemoveUser");
	[usersByName_ removeObjectForKey:u.userName];
}


@end

