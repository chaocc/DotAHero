#import <Foundation/Foundation.h>
#import "EsUserManager+Internal.h"
#import "EsZoneManager.h"
#import "EsApi.h"
#import "EsUser.h"
#import "esZone.h"

@class ElectroServer;

/**
 * This class listens for many ElectroServer events so that it can manage the 
 * state of some useful things for you to conveniently
 * access. It manages zones, rooms, users, buddies (and their online/offline status), 
 * user variables, and room variables.
 * 
 * Look at the documentation for the ZoneManager and UserManager for more 
 * information about what is tracked and when.
 */
@interface EsManagerHelper : NSObject {
	@private
	ElectroServer* es_;
	EsUserManager* userManager_;
	EsZoneManager* zoneManager_;
}

@property(readonly) EsUserManager* userManager;
@property(readonly) EsZoneManager* zoneManager;

@end

