#import <Foundation/Foundation.h>
#import "EsUser.h"


/**
 * This class keeps track of all users that you should know about. Those are users 
 * that are in rooms that you are in, the user that represents you, and users that 
 * represent your buddies. 
 * Convenient methods are available for looking up users.
 * It is not intended that you would create a new instance of this class. It is 
 * instantiated and used by the ElectroServer class. You can access it through 
 * an ElectroServer class instance.
 */
@interface EsUserManager : NSObject {
	@private
	EsUser* __weak me_;
	NSMutableDictionary* usersByName_;
}

/**
 * The EsUser object that represents you.
 */
@property(weak, readonly) EsUser* me;

/**
 * Gets a user by name.
 * @param	The name of the user to find. Returns null if there is no user with that name being tracked.
 * @return User object with the name passed in.
 */
- (EsUser*) userByName:(NSString*) userName;

/**
 * Gets the list of all users being tracked.
 */
- (NSArray*) users;

/**
 * Gets the list of all buddies.
 */
- (NSArray*) buddies;
@end
