/*
 * Kobold2D™ --- http://www.kobold2d.org
 *
 * Copyright (c) 2010-2011 Steffen Itterheim. 
 * Released under MIT License in Germany (LICENSE-Kobold2D.txt).
 */

#import "BGGameLayer.h"
#import "BGClient.h"
#import "BGFileConstants.h"
#import "BGDefines.h"
#import "BGDensity.h"
#import "BGFaction.h"
#import "BGGameMenu.h"
#import "BGCardPile.h"

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

@property (nonatomic, strong) NSArray *users;         // [0] is current user
@property (nonatomic, strong) NSArray *allHeroIds;    // [0] is selected by current user

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
        _targetPlayerNames = [NSMutableArray array];
        
//      All users in the same room
        _users = [BGClient sharedClient].users;
        
//      Enable pre multiplied alpha for PVR textures to avoid artifacts
        [CCTexture2D PVRImagesHavePremultipliedAlpha:YES];
        
//      Load all of the game's artwork up front
        CCSpriteFrameCache *spriteFrameCache = [CCSpriteFrameCache sharedSpriteFrameCache];
        [spriteFrameCache addSpriteFramesWithFile:kPlistBackground];
        [spriteFrameCache addSpriteFramesWithFile:kPlistGameArtwork];
        [spriteFrameCache addSpriteFramesWithFile:kPlistHeroCard];
        [spriteFrameCache addSpriteFramesWithFile:kPlistHeroAvatar];
        [spriteFrameCache addSpriteFramesWithFile:kPlistPlayingCard];
        [spriteFrameCache addSpriteFramesWithFile:kPlistEquipmentAvatar];
        
        _gameArtworkBatch = [CCSpriteBatchNode batchNodeWithFile:kZlibGameArtwork];
        [self addChild:_gameArtworkBatch];
        
        [self addDensity];
        [self addFaction];
        [self addMenu];
        [self addCardPile];
        [self addPlayers];
        [self addPlayingDeck];
        
//      TEMP
        [_playingDeck updatePlayingDeckWithHeroIds:[NSArray arrayWithObjects:@(2), @(17), @(21), nil]];
}

	return self;
}

/*
 * Add density node, game background changes according to different density task.
 */
- (void)addDensity
{
//    [CCTexture2D setDefaultAlphaPixelFormat:kCCTexture2DPixelFormat_RGB565];
    [self addChild:[BGDensity densityWithDensityCardId:1] z:-1];
}

/*
 * Add faction node at left up corner
 */
- (void)addFaction
{
    NSArray *roleIds = [NSArray arrayWithObjects:@(0), @(1), @(2), @(3), @(4), @(5), @(6), @(7), nil];
    BGFaction *faction = [BGFaction factionWithRoleIds:roleIds];
    [self addChild:faction];
}

/*
 * Add game main menu node at right up corner
 */
- (void)addMenu
{
    [self addChild:[BGGameMenu menu]];
}

/*
 * Add card pile node below game main menu
 */
- (void)addCardPile
{
    [self addChild:[BGCardPile cardPile]];
    self.remainingCardCount = TOTAL_CARD_COUNT;
}

/*
 * Set the remaining card count and let card pile update the count on the UI
 */
- (void)setRemainingCardCount:(NSUInteger)remainingCardCount
{
    _remainingCardCount = remainingCardCount;
    [_delegate remainingCardCountUpdate:remainingCardCount];
}

/*
 * Add all players area node
 */
- (void)addPlayers
{
    _allPlayers = [NSMutableArray arrayWithCapacity:_users.count];
    [self addCurrentPlayer];
    [self addOtherPlayers];
}

/*
 * Add current player area node
 */
- (void)addCurrentPlayer
{
    @try {
        BGPlayer *player = [BGPlayer playerWithUserName:[_users[0] userName] isCurrentPlayer:YES];
        [self addChild:player];
        
        _currentPlayer = player;
        [_allPlayers addObject:player];
    }
    @catch (NSException *exception) {
        NSLog(@"Exception: %@ in selector %@", exception.description, NSStringFromSelector(_cmd));
    }
}

/*
 * Add other players area node, set different position for each player according to player count.
 */
- (void)addOtherPlayers
{
    @try {
        for (NSUInteger i = 1; i < _users.count; i++) {
            BGPlayer *player = [BGPlayer playerWithUserName:[_users[i] userName] isCurrentPlayer:NO];
            [self addChild:player];
            [_allPlayers addObject:player];
        }
    }
    @catch (NSException *exception) {
        NSLog(@"Exception: %@ in selector %@", exception.description, NSStringFromSelector(_cmd));
    }
    
    CGSize spriteSize = [[CCSprite spriteWithSpriteFrameName:kImageOtherPlayerArea] contentSize];
    CGFloat spriteWidth = spriteSize.width;
    CGFloat spriteHeight = spriteSize.height;
    
    switch (_users.count) {
        case kPlayerCountTwo:
            [_allPlayers[1] setPosition:ccp(SCREEN_WIDTH/2, SCREEN_HEIGHT - spriteHeight/2)];
            break;
            
        case kPlayerCountThree:
            [_allPlayers[1] setPosition:ccp(SCREEN_WIDTH*2/3, SCREEN_HEIGHT - spriteHeight/2)];
            [_allPlayers[2] setPosition:ccp(SCREEN_WIDTH*1/3, SCREEN_HEIGHT - spriteHeight/2)];
            break;
            
        case kPlayerCountFour:
            [_allPlayers[1] setPosition:ccp(SCREEN_WIDTH - spriteWidth/2, SCREEN_HEIGHT*0.6)];
            [_allPlayers[2] setPosition:ccp(SCREEN_WIDTH/2, SCREEN_HEIGHT - spriteHeight/2)];
            [_allPlayers[3] setPosition:ccp(spriteWidth/2, SCREEN_HEIGHT*0.6)];
            break;
            
        case kPlayerCountFive:
            [_allPlayers[1] setPosition:ccp(SCREEN_WIDTH - spriteWidth/2, SCREEN_HEIGHT*0.6)];
            [_allPlayers[2] setPosition:ccp(SCREEN_WIDTH*0.63, SCREEN_HEIGHT - spriteHeight/2)];
            [_allPlayers[3] setPosition:ccp(SCREEN_WIDTH*0.37, SCREEN_HEIGHT - spriteHeight/2)];
            [_allPlayers[4] setPosition:ccp(spriteWidth/2, SCREEN_HEIGHT*0.6)];
            break;
            
        case kPlayerCountSix:
            [_allPlayers[1] setPosition:ccp(SCREEN_WIDTH - spriteWidth/2, SCREEN_HEIGHT*0.6)];
            [_allPlayers[2] setPosition:ccp(SCREEN_WIDTH*3/4, SCREEN_HEIGHT - spriteHeight/2)];
            [_allPlayers[3] setPosition:ccp(SCREEN_WIDTH*1/2, SCREEN_HEIGHT - spriteHeight/2)];
            [_allPlayers[4] setPosition:ccp(SCREEN_WIDTH*1/4, SCREEN_HEIGHT - spriteHeight/2)];
            [_allPlayers[5] setPosition:ccp(spriteWidth/2, SCREEN_HEIGHT*0.6)];
            break;
            
        case kPlayerCountSeven:
            [_allPlayers[1] setPosition:ccp(SCREEN_WIDTH - spriteWidth/2, SCREEN_HEIGHT*0.49)];
            [_allPlayers[2] setPosition:ccp(SCREEN_WIDTH - spriteWidth/2, SCREEN_HEIGHT*0.69)];
            [_allPlayers[3] setPosition:ccp(SCREEN_WIDTH*0.63, SCREEN_HEIGHT - spriteHeight/2)];
            [_allPlayers[4] setPosition:ccp(SCREEN_WIDTH*0.37, SCREEN_HEIGHT - spriteHeight/2)];
            [_allPlayers[5] setPosition:ccp(spriteWidth/2, SCREEN_HEIGHT*0.49)];
            [_allPlayers[6] setPosition:ccp(spriteWidth/2, SCREEN_HEIGHT*0.69)];
            break;
            
        case kPlayerCountEight:
            [_allPlayers[1] setPosition:ccp(SCREEN_WIDTH - spriteWidth/2, SCREEN_HEIGHT*0.49)];
            [_allPlayers[2] setPosition:ccp(SCREEN_WIDTH - spriteWidth/2, SCREEN_HEIGHT*0.69)];
            [_allPlayers[3] setPosition:ccp(SCREEN_WIDTH*3/4, SCREEN_HEIGHT - spriteHeight/2)];
            [_allPlayers[4] setPosition:ccp(SCREEN_WIDTH*1/2, SCREEN_HEIGHT - spriteHeight/2)];
            [_allPlayers[5] setPosition:ccp(SCREEN_WIDTH*1/4, SCREEN_HEIGHT - spriteHeight/2)];
            [_allPlayers[6] setPosition:ccp(spriteWidth/2, SCREEN_HEIGHT*0.49)];
            [_allPlayers[7] setPosition:ccp(spriteWidth/2, SCREEN_HEIGHT*0.69)];
            break;
            
        default:
            break;
    }
}

/*
 * Add playing deck for showing toBeSelectedHeros/used/cutting cards or others
 */
- (void)addPlayingDeck
{
    _playingDeck = [BGPlayingDeck sharedPlayingDeck];
    [self addChild:_playingDeck];
}

/*
 * Render the selected hero for other players
 */
- (void)renderOtherPlayersHeroWithHeroIds:(NSArray *)heroIds
{
    self.allHeroIds = heroIds;
    
    for (NSUInteger i = 1; i < _allPlayers.count; i++) {
        @try {
            [_allPlayers[i] renderHeroWithHeroId:[_allHeroIds[i] integerValue]];
        }
        @catch (NSException *exception) {
            NSLog(@"Exception: %@ in selector %@", exception.description, NSStringFromSelector(_cmd));
        }
    }
}

/*
 * Adjust the hero id's index, put the hero id of current player selected as first one.
 */
- (void)setAllHeroIds:(NSArray *)allHeroIds
{
//    NSMutableArray *mutableHeroIds = [allHeroIds mutableCopy];
//    NSMutableIndexSet *idxSet = [NSMutableIndexSet indexSet];
//    
//    [allHeroIds enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
//        if ([obj integerValue] == [_currentPlayer selectedHeroId]) {
//            [mutableHeroIds removeObjectsAtIndexes:idxSet];
//            [mutableHeroIds addObjectsFromArray:[allHeroIds objectsAtIndexes:idxSet]];
//            _allHeroIds = mutableHeroIds;
//            return;
//        }
//        
//        [idxSet addIndex:idx];
//    }];
}

- (BGPlayer *)sourcePlayer
{
    for (BGPlayer *player in _allPlayers) {
        if ([player.playerName isEqualToString:_sourcePlayerName]) {
            return player;
        }
    }
    return nil;
}

- (BGPlayer *)playerWithName:(NSString *)playerName
{
    for (BGPlayer *player in _allPlayers) {
        if ([player.playerName isEqualToString:playerName]) {
            return player;
        }
    }
    return nil;
}

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
