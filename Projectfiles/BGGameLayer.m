/*
 * Kobold2D™ --- http://www.kobold2d.org
 *
 * Copyright (c) 2010-2011 Steffen Itterheim. 
 * Released under MIT License in Germany (LICENSE-Kobold2D.txt).
 */

#import "BGGameLayer.h"
#import "BGDensity.h"
#import "BGFaction.h"
#import "BGMenu.h"
#import "BGCurrentPlayer.h"
#import "BGOtherPlayer.h"
#import "BGMoveComponent.h"

typedef NS_ENUM(NSUInteger, BGOtherPlayerCount) {
    kOneOtherPlayer = 1,
    kTwoOtherPlayers,
    kThreeOtherPlayers,
    kFourOtherPlayers,
    kFiveOtherPlayers,
    kSixOtherPlayers,
    kSevenOtherPlayers
};

@interface BGGameLayer ()

@property (nonatomic, strong) CCSpriteBatchNode *spriteBatch;

@end

@implementation BGGameLayer

static BGGameLayer *instanceOfGameLayer = nil;

+ (id)sharedGameLayer
{
    NSAssert(instanceOfGameLayer, @"GameLayer instance not yet initialized!");
	return instanceOfGameLayer;
}

+ (id)scene
{
	CCScene* scene = [CCScene node];
	CCLayer* layer = [BGGameLayer node];
	[scene addChild:layer];
    
	return scene;
}

- (id)init
{
	if ((self = [super init]))
	{
        instanceOfGameLayer = self;
        
        [CCTexture2D PVRImagesHavePremultipliedAlpha:YES];
        
        CCSpriteFrameCache *spriteFrameCache = [CCSpriteFrameCache sharedSpriteFrameCache];
        [spriteFrameCache addSpriteFramesWithFile:@"GameBackground.plist"];
        [spriteFrameCache addSpriteFramesWithFile:@"GameImage.plist"];
        
        self.spriteBatch = [CCSpriteBatchNode batchNodeWithFile:@"GameImage.pvr.ccz"];
        [self addChild:_spriteBatch];
        
//        [self addBackground];
        [self addFaction];
        [self addDensity];
        [self addMenu];
        [self addCardPile];
        [self addPlayers];
        
//      ...TODO...
//      监听Server端发送的Event，可以获得所有Player及其所选择的HeroId
	}

	return self;
}

- (void)addBackground
{
    CCSprite *sprite = [CCSprite spriteWithSpriteFrameName:@"Background.png"];
    sprite.position = [CCDirector sharedDirector].screenCenter;
    [self addChild:sprite z:-1];
}

- (void)addFaction
{
    BGFaction *faction = [BGFaction factionWithSentinelCount:3 scourgeCount:3 andNeutralCount:2];
    [self addChild:faction];
}

- (void)addDensity
{
    
}

- (void)addMenu
{
    [self addChild:[BGMenu menu]];
}

- (void)addCardPile
{
    CCSprite *sprite = [CCSprite spriteWithSpriteFrameName:@"CardPile.png"];
    CGSize winSize = [[CCDirector sharedDirector] winSize];
    sprite.position = ccp(winSize.width - sprite.contentSize.width*0.6, winSize.height - sprite.contentSize.height*1.8);
    [self addChild:sprite];
}

- (void)addPlayers
{
    [self addOtherPlayers];
    [self addCurrentPlayer];
}

- (void)addCurrentPlayer
{
    NSArray *heroCards = [NSArray arrayWithObjects:@(2), @(3), @(5), @(12), nil];
    
    BGCurrentPlayer *player = [BGCurrentPlayer playerWithName:[(EsUser *)_players[0] userName]
                                                 andHeroCards:heroCards];
    [self addChild:player];
}

- (void)addOtherPlayers
{
    NSMutableArray *otherPlayers = [NSMutableArray arrayWithCapacity:7]; // (_players.count - 1)
    
//    [_players enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
//        if (idx > 0) {
//            BGOtherPlayer *player = [BGOtherPlayer otherPlayerWithName:[(EsUser *)obj userName]
//                                                           andHeroCard:_heroIds[idx]];
//            [otherPlayers addObject:player];
//            [self addChild:player];
//        }
//    }];
    
    for (NSUInteger i = 0; i < 7; i++) {
        BGOtherPlayer *player = [BGOtherPlayer otherPlayerWithName:nil andHeroCard:i];
        [otherPlayers addObject:player];
        [self addChild:player];
    }
    
    CGSize winSize = [[CCDirector sharedDirector] winSize];
    CGSize spriteSize = [[CCSprite spriteWithSpriteFrameName:@"OtherPlayerArea.png"] contentSize];
    
    switch (7) {
        case kOneOtherPlayer:
            [otherPlayers[0] setPosition:ccp(winSize.width/2, winSize.height - spriteSize.height/2)];
            break;
            
        case kTwoOtherPlayers:
            [otherPlayers[0] setPosition:ccp(winSize.width*2/3, winSize.height - spriteSize.height/2)];
            [otherPlayers[1] setPosition:ccp(winSize.width*1/3, winSize.height - spriteSize.height/2)];
            break;
            
        case kThreeOtherPlayers:
            [otherPlayers[0] setPosition:ccp(winSize.width - spriteSize.width/2, winSize.height*0.6)];
            [otherPlayers[1] setPosition:ccp(winSize.width/2, winSize.height - spriteSize.height/2)];
            [otherPlayers[2] setPosition:ccp(spriteSize.width/2, winSize.height*0.6)];
            break;
            
        case kFourOtherPlayers:
            [otherPlayers[0] setPosition:ccp(winSize.width - spriteSize.width/2, winSize.height*0.6)];
            [otherPlayers[1] setPosition:ccp(winSize.width*0.63, winSize.height - spriteSize.height/2)];
            [otherPlayers[2] setPosition:ccp(winSize.width*0.37, winSize.height - spriteSize.height/2)];
            [otherPlayers[3] setPosition:ccp(spriteSize.width/2, winSize.height*0.6)];
            break;
            
        case kFiveOtherPlayers:
            [otherPlayers[0] setPosition:ccp(winSize.width - spriteSize.width/2, winSize.height*0.6)];
            [otherPlayers[1] setPosition:ccp(winSize.width*3/4, winSize.height - spriteSize.height/2)];
            [otherPlayers[2] setPosition:ccp(winSize.width*1/2, winSize.height - spriteSize.height/2)];
            [otherPlayers[3] setPosition:ccp(winSize.width*1/4, winSize.height - spriteSize.height/2)];
            [otherPlayers[4] setPosition:ccp(spriteSize.width/2, winSize.height*0.6)];
            break;
            
        case kSixOtherPlayers:
            [otherPlayers[0] setPosition:ccp(winSize.width - spriteSize.width/2, winSize.height*0.5)];
            [otherPlayers[1] setPosition:ccp(winSize.width - spriteSize.width/2, winSize.height*0.7)];
            [otherPlayers[2] setPosition:ccp(winSize.width*0.63, winSize.height - spriteSize.height/2)];
            [otherPlayers[3] setPosition:ccp(winSize.width*0.37, winSize.height - spriteSize.height/2)];
            [otherPlayers[4] setPosition:ccp(spriteSize.width/2, winSize.height*0.5)];
            [otherPlayers[5] setPosition:ccp(spriteSize.width/2, winSize.height*0.7)];
            break;
            
        case kSevenOtherPlayers:
            [otherPlayers[0] setPosition:ccp(winSize.width - spriteSize.width/2, winSize.height*0.5)];
            [otherPlayers[1] setPosition:ccp(winSize.width - spriteSize.width/2, winSize.height*0.7)];
            [otherPlayers[2] setPosition:ccp(winSize.width*3/4, winSize.height - spriteSize.height/2)];
            [otherPlayers[3] setPosition:ccp(winSize.width*1/2, winSize.height - spriteSize.height/2)];
            [otherPlayers[4] setPosition:ccp(winSize.width*1/4, winSize.height - spriteSize.height/2)];
            [otherPlayers[5] setPosition:ccp(spriteSize.width/2, winSize.height*0.5)];
            [otherPlayers[6] setPosition:ccp(spriteSize.width/2, winSize.height*0.7)];
            break;
            
        default:
            break;
    }
}

- (void)transferRoleCardToNextPlayer
{
    [[_spriteBatch.children getNSArray] enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        CCSprite *nextSprite = nil;
        if (![obj isEqual:_spriteBatch.children.lastObject]) {
            nextSprite = [_spriteBatch.children objectAtIndex:idx + 1];
        } else {
            nextSprite = [_spriteBatch.children objectAtIndex:0];
        }
        
        BGMoveComponent *moveComp = [BGMoveComponent moveWithTarget:nextSprite.position ofNode:obj];
        [moveComp runActionEaseMoveScale];
    }];
}

@end
