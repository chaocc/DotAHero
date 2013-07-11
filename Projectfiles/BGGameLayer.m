/*
 * Kobold2D™ --- http://www.kobold2d.org
 *
 * Copyright (c) 2010-2011 Steffen Itterheim. 
 * Released under MIT License in Germany (LICENSE-Kobold2D.txt).
 */

#import "BGGameLayer.h"
#import "BGFileConstants.h"
#import "BGDefines.h"
#import "BGDensity.h"
#import "BGFaction.h"
#import "BGGameMenu.h"
#import "BGPlayer.h"
#import "BGMoveComponent.h"

typedef NS_ENUM(NSUInteger, BGPlayerCount) {
    kPlayerCountTwo = 2,
    kPlayerCountThree,
    kPlayerCountFour,
    kPlayerCountFive,
    kPlayerCountSix,
    kPlayerCountSeven,
    kPlayerCountEight
};

@interface BGGameLayer ()

@property (nonatomic, strong) NSArray *toBeSelectedHeroIds;
@property (nonatomic, strong) EsObject *esObject;

@end

@implementation BGGameLayer

static BGGameLayer *instanceOfGameLayer = nil;

+ (BGGameLayer *)sharedGameLayer
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
        
//      Enable pre multiplied alpha for PVR textures to avoid artifacts
        [CCTexture2D PVRImagesHavePremultipliedAlpha:YES];
        
//      Load all of the game's artwork up front
        CCSpriteFrameCache *spriteFrameCache = [CCSpriteFrameCache sharedSpriteFrameCache];
        [spriteFrameCache addSpriteFramesWithFile:kPlistGameArtwork];
        [spriteFrameCache addSpriteFramesWithFile:kPlistHeroCard];
        [spriteFrameCache addSpriteFramesWithFile:kPlistHeroAvatar];
        [spriteFrameCache addSpriteFramesWithFile:kPlistPlayingCard];
        [spriteFrameCache addSpriteFramesWithFile:kPlistEquipmentAvatar];
        [spriteFrameCache addSpriteFramesWithFile:kPlistCardEffect];
        
        _gameArtworkBatch = [CCSpriteBatchNode batchNodeWithFile:kZlibGameArtwork];
        [self addChild:_gameArtworkBatch z:1];
        
        _es = [BGRoomLayer sharedRoomLayer].es;
        _users = _es.managerHelper.userManager.users;
        
        [self addDensity];
        [self addFaction];
        [self addMenu];
        [self addCardPile];
        [self addPlayers];
        
//      Send plugin request to server
        [self sendStartGameRequest];
	}

	return self;
}

- (void)sendStartGameRequest
{
    EsObject *obj = [[EsObject alloc] init];
    [obj setInt:kActionStartGame forKey:kAction];
    [[BGRoomLayer sharedRoomLayer] sendPluginRequestWithObject:obj pluginName:@"GamePlugin" andEventListener:self];
}

- (void)onPluginMessageEvent:(EsPluginMessageEvent *)e
{
    _esObject = e.parameters;
    
    switch ([e.parameters intWithKey:kAction]) {
        case kActionSendSortedPlayerNames:
//            _users = _es.managerHelper.userManager.users;
            
            break;
            
        case kActionDealHeroCards:      // Set to be selected hero ids for current player
            [self dealHeroCards];
            break;
            
        case kActionSendAllHeroIds:     // Send hero id selected by all players
            [self sendAllHeroIds];
            break;
            
        default:
            break;
    }
}

- (void)dealHeroCards
{
    [_players[0] setToBeSelectedHeroIds:[_esObject stringArrayWithKey:kParamToBeSelectedHeroIds]];
}

- (void)sendAllHeroIds
{
    self.allHeroIds = [_esObject stringArrayWithKey:kParamAllHeroIds];
    [self addHeroAreaForOtherPlayers];
}

- (void)setAllHeroIds:(NSArray *)allHeroIds
{
    NSMutableArray *mutableHeroIds = [allHeroIds mutableCopy];
    NSMutableIndexSet *idxSet = [NSMutableIndexSet indexSet];
    
    [mutableHeroIds enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        if ([obj unsignedIntegerValue] == [_players[0] selectedHeroId]) {
            [mutableHeroIds removeObjectsAtIndexes:idxSet];
            [mutableHeroIds addObjectsFromArray:[allHeroIds objectsAtIndexes:idxSet]];
            _allHeroIds = mutableHeroIds;
            return;
        }
        
        [idxSet addIndex:idx];
    }];
}

- (void)addHeroAreaForOtherPlayers
{
    for (NSUInteger i = 1; i < _players.count; i++) {
        [_players[i] addHeroAreaWithHeroId:[_allHeroIds[i] integerValue]];
    }
}

- (void)addDensity
{
    CCSprite *sprite = [CCSprite spriteWithFile:kImageBackground];
    sprite.position = [CCDirector sharedDirector].screenCenter;
    [self addChild:sprite];
}

- (void)addFaction
{
    NSArray *roleIds = [NSArray arrayWithObjects:@(0), @(1), @(2), @(3), @(4), @(5), @(6), @(7), nil];
    BGFaction *faction = [BGFaction factionWithRoleIds:roleIds];
    [self addChild:faction];
}

- (void)addMenu
{
    [self addChild:[BGGameMenu menu]];
}

- (void)addCardPile
{
    CCSprite *sprite = [CCSprite spriteWithSpriteFrameName:kImageCardPile];
    CGSize spriteSize = sprite.contentSize;
    sprite.position = ccp(SCREEN_WIDTH - spriteSize.width*0.6, SCREEN_HEIGHT - spriteSize.height*1.8);
    [_gameArtworkBatch addChild:sprite];
}

- (void)addPlayers
{
//  ...TODO... Capacity should be "_users.count"
    _players = [NSMutableArray arrayWithCapacity:8];
    [self addCurrentPlayer];
    [self addOtherPlayers];
}

- (void)addCurrentPlayer
{    
    BGPlayer *player = [BGPlayer playerWithUserName:[_users[0] userName] isCurrentPlayer:YES];
    [self addChild:player];
    [_players addObject:player];
    
//    [player setToBeSelectedHeroIds:[NSArray arrayWithObjects:@(2), @(3), @(12), nil]];
}

- (void)addOtherPlayers
{    
    for (NSUInteger i = 1; i < _users.count; i++) {
        BGPlayer *player = [BGPlayer playerWithUserName:[_users[i] userName] isCurrentPlayer:NO];
        [self addChild:player];
        [_players addObject:player];
    }
    
    CGSize spriteSize = [[CCSprite spriteWithSpriteFrameName:kImageOtherPlayerArea] contentSize];
    CGFloat spriteWidth = spriteSize.width;
    CGFloat spriteHeight = spriteSize.height;
    
    switch (_users.count) {
        case kPlayerCountTwo:
            [_players[1] setPosition:ccp(SCREEN_WIDTH/2, SCREEN_HEIGHT - spriteHeight/2)];
            break;
            
        case kPlayerCountThree:
            [_players[1] setPosition:ccp(SCREEN_WIDTH*2/3, SCREEN_HEIGHT - spriteHeight/2)];
            [_players[2] setPosition:ccp(SCREEN_WIDTH*1/3, SCREEN_HEIGHT - spriteHeight/2)];
            break;
            
        case kPlayerCountFour:
            [_players[1] setPosition:ccp(SCREEN_WIDTH - spriteWidth/2, SCREEN_HEIGHT*0.6)];
            [_players[2] setPosition:ccp(SCREEN_WIDTH/2, SCREEN_HEIGHT - spriteHeight/2)];
            [_players[3] setPosition:ccp(SCREEN_WIDTH/2, SCREEN_HEIGHT*0.6)];
            break;
            
        case kPlayerCountFive:
            [_players[1] setPosition:ccp(SCREEN_WIDTH - spriteWidth/2, SCREEN_HEIGHT*0.6)];
            [_players[2] setPosition:ccp(SCREEN_WIDTH*0.63, SCREEN_HEIGHT - spriteHeight/2)];
            [_players[3] setPosition:ccp(SCREEN_WIDTH*0.37, SCREEN_HEIGHT - spriteHeight/2)];
            [_players[4] setPosition:ccp(SCREEN_WIDTH/2, SCREEN_HEIGHT*0.6)];
            break;
            
        case kPlayerCountSix:
            [_players[1] setPosition:ccp(SCREEN_WIDTH - spriteWidth/2, SCREEN_HEIGHT*0.6)];
            [_players[2] setPosition:ccp(SCREEN_WIDTH*3/4, SCREEN_HEIGHT - spriteHeight/2)];
            [_players[3] setPosition:ccp(SCREEN_WIDTH*1/2, SCREEN_HEIGHT - spriteHeight/2)];
            [_players[4] setPosition:ccp(SCREEN_WIDTH*1/4, SCREEN_HEIGHT - spriteHeight/2)];
            [_players[5] setPosition:ccp(SCREEN_WIDTH/2, SCREEN_HEIGHT*0.6)];
            break;
            
        case kPlayerCountSeven:
            [_players[1] setPosition:ccp(SCREEN_WIDTH - spriteWidth/2, SCREEN_HEIGHT*0.5)];
            [_players[2] setPosition:ccp(SCREEN_WIDTH - spriteWidth/2, SCREEN_HEIGHT*0.7)];
            [_players[3] setPosition:ccp(SCREEN_WIDTH*0.63, SCREEN_HEIGHT - spriteHeight/2)];
            [_players[4] setPosition:ccp(SCREEN_WIDTH*0.37, SCREEN_HEIGHT - spriteHeight/2)];
            [_players[5] setPosition:ccp(spriteWidth/2, SCREEN_HEIGHT*0.5)];
            [_players[6] setPosition:ccp(spriteWidth/2, SCREEN_HEIGHT*0.7)];
            break;
            
        case kPlayerCountEight:
            [_players[1] setPosition:ccp(SCREEN_WIDTH - spriteWidth/2, SCREEN_HEIGHT*0.5)];
            [_players[2] setPosition:ccp(SCREEN_WIDTH - spriteWidth/2, SCREEN_HEIGHT*0.7)];
            [_players[3] setPosition:ccp(SCREEN_WIDTH*3/4, SCREEN_HEIGHT - spriteHeight/2)];
            [_players[4] setPosition:ccp(SCREEN_WIDTH*1/2, SCREEN_HEIGHT - spriteHeight/2)];
            [_players[5] setPosition:ccp(SCREEN_WIDTH*1/4, SCREEN_HEIGHT - spriteHeight/2)];
            [_players[6] setPosition:ccp(spriteWidth/2, SCREEN_HEIGHT*0.5)];
            [_players[7] setPosition:ccp(spriteWidth/2, SCREEN_HEIGHT*0.7)];
            break;
            
        default:
            break;
    }
}

//// ...TODO...
//// 发手牌给某个玩家
//- (void)dealPlayingCardIds:(NSArray *)cardIds toPlayer:(BGPlayer *)player
//{
//    [player drawPlayingCardIds:cardIds];
//}

- (void)transferRoleCardToNextPlayer
{
//    [[_spriteBatch.children getNSArray] enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
//        CCSprite *nextSprite = nil;
//        if (![obj isEqual:_spriteBatch.children.lastObject]) {
//            nextSprite = [_spriteBatch.children objectAtIndex:idx + 1];
//        } else {
//            nextSprite = [_spriteBatch.children objectAtIndex:0];
//        }
//        
//        BGMoveComponent *moveComp = [BGMoveComponent moveWithTarget:nextSprite.position ofNode:obj];
//        [moveComp runActionEaseMoveScale];
//    }];
}

@end
