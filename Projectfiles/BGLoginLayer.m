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
        if ([BGClient sharedClient].isSingleMode) {
//          ...TEMP...
            CCMenuItemFont *item = [CCMenuItemFont itemWithString:@"Single Mode" block:^(id sender) {
                if ([BGClient sharedClient].isSingleMode) {
                    [self showRoomListLayer];
                    [[BGRoomLayer sharedRoomLayer] showGameLayer];
                }
            }];
            CCMenu *menu = [CCMenu menuWithItems:item, nil];
            menu.position = [CCDirector sharedDirector].screenCenter;
            [self addChild:menu];
        } else {
            [[BGClient sharedClient] conntectServer];
        }
	}
    
	return self;
}

- (NSString *)userName
{
    srandom(time(NULL));
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
