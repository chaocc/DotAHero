#import <Foundation/Foundation.h>
#import "EsUserManager.h"

/**
 * Internal methods for EsUserManager. Not intended for public use.
 */
@interface EsUserManager()

/**
 * Returns 'true' if a user is being tracked with the name passed in.
 * @param	Username to check for.
 * @return Boolean, true if the user is being tracked
 */
- (BOOL) doesUserExist:(NSString*) userName;

/**
 * Adds a new buddy to track. Not intended for public use.
 * @private
 */
- (EsUser*) addBuddy:(EsUser*) u;

/**
 * Removes a user as your buddy. Not intended for public use.
 * @private
 */
- (void) removeBuddy:(EsUser*) u;

/**
 * Adds a new user to be tracked. Not intended for public use.
 * @private
 */
- (EsUser*) addUser:(EsUser*) u;

/**
 * Decrement the number of references to this user. If the number is 0, then 
 * truly remove (unless it is a buddy or you). Not intended for public use.
 * @private
 */
- (void) removeUser:(NSString*) userName;

/**
 * Truly removes a User object that has no references left.
 * @param	The User object to remove.
 */
- (void) reallyRemoveUser:(EsUser*) u;
@end
