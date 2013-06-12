#import "EsUser+Internal.h"

@implementation EsUser

@synthesize userName;
@synthesize isMe;
@synthesize isBuddy;
@synthesize isLoggedIn = isLoggedIn_;
@synthesize buddyVariable;

- (id) init {
	if ((self = [super init])) {
		referencesLock_ = [[NSLock alloc] init];
        userVariables_ = [[NSMutableDictionary alloc] init];
	}
	return self;
}


- (EsUserVariable*) userVariableWithName:(NSString*) name {
	return [userVariables_ objectForKey:name];
}

- (NSArray*) userVariables {
	return [userVariables_ allValues];
}

- (EsObject*) buddyVariable {
	if (self.isBuddy) {
		return buddyVariable_;
	}
	else {
		return nil;
	}
}

- (BOOL) isLoggedIn {
	if (self.isBuddy) {
		return isLoggedIn_;
	}
	else {
		return false;
	}
}

///
/// Private
///

- (void) addUserVariable:(EsUserVariable*) userVariable {
	[userVariables_ setObject:userVariable forKey:userVariable.name];
}

- (void) removeUserVariableWithName:(NSString*) name {
	[userVariables_ removeObjectForKey:name];
}

- (int) references {
	return references_;
}

- (int) incrementReferences {
	int references;
	[referencesLock_ lock];
	references_++;
	references = references_;
	[referencesLock_ unlock];
	return references;
}

- (int) decrementReferences {
	int references;
	[referencesLock_ lock];
	references_--;
	references = references_;
	[referencesLock_ unlock];
	return references;
}

@end
