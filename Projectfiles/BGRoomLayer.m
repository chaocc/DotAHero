//
//  BGRoomLayer.m
//  DotAHero
//
//  Created by Killua Liu on 6/14/13.
//
//

#import "BGRoomLayer.h"
#import "BGClient.h"
#import "BGGameLayer.h"
#import "BGDefines.h"

@interface BGRoomLayer ()

@end

@implementation BGRoomLayer

static BGRoomLayer *instanceOfRoomLayer = nil;

+ (BGRoomLayer *)sharedRoomLayer
{
    NSAssert(instanceOfRoomLayer, @"RoomListLayer instance not yet initialized!");
	return instanceOfRoomLayer;
}

+ (id)scene
{
	CCScene* scene = [CCScene node];
	CCLayer* layer = [BGRoomLayer node];
	[scene addChild:layer];
    
	return scene;
}

- (id)init
{
    if (self = [super init]) {
        instanceOfRoomLayer = self;
        
//      ...TEMP...
        CCLabelTTF *label = [CCLabelTTF labelWithString:@"Wait for another player joining the game..."
                                               fontName:@"Arial"
                                               fontSize:30.0f];
        CGSize screenSize = [CCDirector sharedDirector].winSize;
        label.position = ccp(screenSize.width/2, screenSize.height*0.6);
        [self addChild:label];
        
        CCMenuItemFont *item = [CCMenuItemFont itemWithString:@"Single Player Test" block:^(id sender) {
            [self readyStartGame];
        }];
        CCMenu *menu = [CCMenu menuWithItems:item, nil];
        menu.position = ccp(screenSize.width/2, screenSize.height*0.4);
        [self addChild:menu];
    }
    return self;
}

/*
 * Prepare stat game after receive readyStatGame action
 */
- (void)readyStartGame
{
    [self removeAllChildrenWithCleanup:YES];
    
    [[BGClient sharedClient] addGamePluginMessageEventListener];
    
//  ...TEMP...
    if (_isRoomOwner)
    {
        CCMenuItemFont *item = [CCMenuItemFont itemWithString:@"Start Game" block:^(id sender) {
            [[self getChildByTag:1000] removeFromParentAndCleanup:YES];
            [[BGClient sharedClient] sendStartGameRequest];
        }];
        CCMenu *menu = [CCMenu menuWithItems:item, nil];
        [self addChild:menu z:0 tag:1000];
    }
    else
    {
        CCLabelTTF *label = [CCLabelTTF labelWithString:@"Wait for starting game..."
                                               fontName:@"Arial"
                                               fontSize:30.0f];
        label.position = [CCDirector sharedDirector].screenCenter;
        [self addChild:label];
    }
}

/*
 * Show game layer after receive start game public message
 */
- (void)showGameLayer
{
    [self removeAllChildrenWithCleanup:YES];
    
    CCScene *scene = [BGGameLayer scene];
    CCTransitionSlideInR *transitionScene = [CCTransitionSlideInR transitionWithDuration:DURATION_GAMELAYER_TRANSITION
                                                                                   scene:scene];
    [[CCDirector sharedDirector] replaceScene:transitionScene];
}

@end
