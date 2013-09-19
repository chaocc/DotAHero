//
//  BGLoginLayer.m
//  DotAHero
//
//  Created by Killua Liu on 6/19/13.
//
//

#import "BGLoginLayer.h"
#import "BGClient.h"
#import "BGRoomListLayer.h"
#import "BGRoomLayer.h"

@implementation BGLoginLayer

static BGLoginLayer *instanceOfLoginLayer = nil;

+ (id)sharedLoginLayer
{
    NSAssert(instanceOfLoginLayer != nil, @"LoginLayer instance not yet initialized!");
	return instanceOfLoginLayer;
}

-(id) init
{
	if ((self = [super init]))
	{
        instanceOfLoginLayer = self;
        [[BGClient sharedClient] conntectServer];
	}
    
	return self;
}

- (NSString *)userName
{
    srandom(time(NULL));
    
    if ([CCDirector sharedDirector].currentDeviceIsIPad) {
        return [NSString stringWithFormat:@"iPad%li", lrint(1000 * random())];
    } else if ([CCDirector sharedDirector].currentDeviceIsSimulator) {
        return [NSString stringWithFormat:@"Simulator%li", lrint(1000 * random())];
    }
    return [NSString stringWithFormat:@"Killua%li", lrint(1000 * random())];
}

/*
 * Show room list layer after receive login successful response
 */
- (void)showRoomListLayer
{
    [self addChild:[BGRoomListLayer scene]];
//	[[CCDirector sharedDirector] replaceScene:transitionScene];
}

@end
