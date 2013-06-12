#import "EsUser.h"

@interface EsUser()

/**
 * The userName of this user.
 */
@property(strong) NSString* userName;

/**
 * True if this EsUser object represents you.
 */
@property BOOL isMe;

/**
 * True if this EsUser object is in your buddy list.
 */
@property BOOL isBuddy;

/**
 * True if this EsUser is a buddy of yours and they are currently logged in.
 */
@property BOOL isLoggedIn;

/**
 * Optional buddy variable set when the buddy was added.
 */
@property(strong) EsObject* buddyVariable;

/**
 * Adds a new user variable to the user. Not intended for public use.
 * @param The user variable to add
 * @private
 */
- (void) addUserVariable:(EsUserVariable*) userVariable;

/**
 * Removes a user variable from a user. Not intended for public use.
 * @param Name of the variable to remove
 * @private
 */
- (void) removeUserVariableWithName:(NSString*) name;

/**
 * Gets the number of references for this user. Not intended for public use.
 * @private
 */
- (int) references;

/**
 * Increments the number of references for this user. Not intended for public use.
 * @private
 */
- (int) incrementReferences;

/**
 * Decrements the number of references for this user. Not intended for public use.
 * @private
 */
- (int) decrementReferences;

@end