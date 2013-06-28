//
//  BGRoomLayer.m
//  DotAHero
//
//  Created by Killua Liu on 6/14/13.
//
//

#import "BGRoomLayer.h"
#import "ElectroServer.h"
#import "BGLoginLayer.h"
#import "BGGameLayer.h"

@interface BGRoomLayer ()

@property (weak, nonatomic) ElectroServer *es;

@end

@implementation BGRoomLayer

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
        self.es = [[BGLoginLayer sharedLoginScene] es];
        self.players = [_es.managerHelper.userManager users];
        
        CCScene *scene = [BGGameLayer node];
        
        CCMenuItemFont *item = [CCMenuItemFont itemWithString:@"Start Game" block:^(id sender) {
//            CCScene *scene = [BGGameLayer node];
            CCTransitionSlideInR *transitionScene = [CCTransitionSlideInR transitionWithDuration:0.5f scene:scene];
            [[CCDirector sharedDirector] replaceScene:transitionScene];
        }];
        CCMenu *menu = [CCMenu menuWithItems:item, nil];
        [self addChild:menu];
    }
    return self;
}

// ...TODO...
// checkRoomOwner
// if yes, display start game button

@end
