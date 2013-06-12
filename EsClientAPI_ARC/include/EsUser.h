#import <Foundation/Foundation.h>
#import "EsObject.h"
#import "EsUserVariable.h"


/**
 * This class represents a user on the server. It stores information about that 
 * user such as their name and user variables. Some information is only tracked 
 * and updated if you are in a room with that user and have the appropriate 
 * subscriptions. For example, you will only know about user variables for users 
 * in your room if you specified receivingUserVariableUpdates when joining that 
 * room - which is 'true' by default.
 */
@interface EsUser : NSObject {
	NSMutableDictionary* userVariables_;
	EsObject* buddyVariable_;
	int references_;
	NSLock* referencesLock_;
	BOOL isLoggedIn_;
}

/**
 * The userName of this user.
 */
@property(strong, readonly) NSString* userName;

/**
 * True if this EsUser object represents you.
 */
@property(readonly) BOOL isMe;

/**
 * True if this EsUser object is in your buddy list.
 */
@property(readonly) BOOL isBuddy;

/**
 * True if this EsUser is a buddy of yours and they are currently logged in.
 */
@property(nonatomic, readonly) BOOL isLoggedIn;

/**
 * Optional buddy variable set when the buddy was added.
 */
@property(nonatomic, strong, readonly) EsObject* buddyVariable;

/**
 * Gets a user variable by its name and returns it.
 * @param Name of the variable to get.
 * @return The UserVariable object
 */
- (EsUserVariable*) userVariableWithName:(NSString*) name;

/**
 * Gets the list of user variables.
 */
- (NSArray*) userVariables;
@end
