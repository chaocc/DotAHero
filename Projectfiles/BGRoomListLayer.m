//
//  BGRoomListLayer.m
//  DotAHero
//
//  Created by Killua Liu on 6/19/13.
//
//

#import "BGRoomListLayer.h"
#import "BGClient.h"
#import "BGRoomLayer.h"

@interface BGRoomListLayer ()



@end

@implementation BGRoomListLayer 

static BGRoomListLayer *instanceOfRoomListLayer = nil;

+ (BGRoomListLayer *)sharedRoomListLayer
{
    NSAssert(instanceOfRoomListLayer, @"RoomListLayer instance not yet initialized!");
	return instanceOfRoomListLayer;
}

+ (id)scene
{
	CCScene* scene = [CCScene node];
	CCLayer* layer = [BGRoomListLayer node];
	[scene addChild:layer];
    
	return scene;
}

- (id)init
{
    if (self = [super init]) {
        instanceOfRoomListLayer = self;
        [[BGClient sharedClient] sendCreateRoomRequest];
    }
    return self;
}

/*
 * Show room layer after create a new room or join existing room
 */
- (void)showRoomLayer
{
    [[CCDirector sharedDirector] replaceScene:[BGRoomLayer scene]];
}

// ...TODO...
// showRoomList
// joinExistingRoom

@end
