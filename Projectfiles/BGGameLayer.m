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
#import "BGActionComponent.h"

@interface BGGameLayer ()

@property (nonatomic, strong) NSArray *users;       // [0] is self user
@property (nonatomic, strong) NSArray *allHeroIds;  // [0] is selected by self user

@property (nonatomic) BOOL isNormalColor;   // Is background normal color

@end

@implementation BGGameLayer

@synthesize state = _state;

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
        [spriteFrameCache addSpriteFramesWithFile:kPlistCardPopup];
        
        _gameArtworkBatch = [CCSpriteBatchNode batchNodeWithFile:kZlibGameArtwork];
        [self addChild:_gameArtworkBatch];
        
        [self addDensity];
        [self addFaction];
        [self addMenu];
        [self addCardPile];
        [self addPlayers];
        [self addPlayingDeck];
        
//      Initialize KKInput
        KKInput *input = [KKInput sharedInput];
        input.multipleTouchEnabled = YES;
        input.gestureDoubleTapEnabled = input.gesturesAvailable;
        input.gestureLongPressEnabled = input.gesturesAvailable;
        input.gesturePanEnabled = input.gesturesAvailable;
}

	return self;
}

- (void)mapActionToGameState
{
    switch (_action) {
        case kActionDeckDealHeros:
            _state = kGameStateStarting;
            break;
            
        case kActionChooseCardToCut:
        case kActionDeckShowAllCuttedCards:
            _state = kGameStateCutting;
            break;
            
        case kActionChooseCardToGet:
        case kActionChoseCardToGet:
        case kActionPlayerGetCard:
        case kActionPlayerGetDeckCard:
            _state = kGameStateGetting;
            break;
            
        case kActionPlayerUpdateHand:
            if ([_reason isEqualToString:@"m_greeded"]) {
                _state = kGameStateLosing;
            }
            break;
            
        case kActionChooseCardToGive:
        case kActionChoseCardToGive:
            _state = kGameStateGiving;
            break;
            
        case kActionDeckShowAssignedCard:
        case kActionAssignCard:
            _state = kGameStateAssigning;
            break;
            
        case kActionPlayCard:
        case kActionUseHandCard:
        case kActionUseHeroSkill:
        case kActionUseEquipment:
            _state = kGameStatePlaying;
            break;
            
        case kActionChooseCardToUse:
        case kActionChoseCardToUse:
            _state = kGameStateChoosing;
            break;
            
        case kActionChooseCardToDiscard:
        case kActionChoseCardToDiscard:
            _state = kGameStateDiscarding;
            break;
            
        default:
//            _state = kGameStateInvalid;
            break;
    }
}

#pragma mark - Density
/*
 * Add density node, game background changes according to different density task.
 */
- (void)addDensity
{
//    [CCTexture2D setDefaultAlphaPixelFormat:kCCTexture2DPixelFormat_RGB565];
    [self addChild:[BGDensity densityWithDensityCardId:1] z:-1];
}

#pragma mark - Faction
/*
 * Add faction node at left up corner
 */
- (void)addFaction
{
    NSArray *roleIds = [NSArray arrayWithObjects:@(0), @(1), @(2), @(3), @(4), @(5), @(6), @(7), nil];
    BGFaction *faction = [BGFaction factionWithRoleIds:roleIds];
    [self addChild:faction];
}

#pragma mark - System menu
/*
 * Add game main menu node at right up corner
 */
- (void)addMenu
{
    [self addChild:[BGGameMenu menu]];
}

#pragma mark - Card pile
/*
 * Add card pile node below game main menu
 */
- (void)addCardPile
{
    [self addChild:[BGCardPile cardPile]];
    self.remainingCardCount = COUNT_TOTAL_CARD;
}

/*
 * Set the remaining card count and let card pile update the count on the UI
 */
- (void)setRemainingCardCount:(NSUInteger)remainingCardCount
{
    if (_remainingCardCount != remainingCardCount) {
        _remainingCardCount = remainingCardCount;
        [_delegate remainingCardCountUpdate:remainingCardCount];
    }
}

#pragma mark - Players
/*
 * Add all players area node
 */
- (void)addPlayers
{
    _allPlayers = [NSMutableArray arrayWithCapacity:_users.count];
    [self addSelfPlayer];
    [self addOtherPlayers];
}

/*
 * Add self player area node
 */
- (void)addSelfPlayer
{
    @try {
//      TEMP
        BGPlayer *player = [BGPlayer playerWithUserName:_users[0] seatIndex:0];
//        BGPlayer *player = [BGPlayer playerWithUserName:[_users[0] userName] seatIndex:0];
        [self addChild:player z:1];
        
        _selfPlayer = player;
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
//          TEMP
            BGPlayer *player = [BGPlayer playerWithUserName:_users[i] seatIndex:i];
//            BGPlayer *player = [BGPlayer playerWithUserName:[_users[i] userName] seatIndex:i];
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
            [_allPlayers[1] setPosition:ccp(SCREEN_WIDTH/2, SCREEN_HEIGHT-spriteHeight/2)];
            break;
            
        case kPlayerCountThree:
            [_allPlayers[1] setPosition:ccp(SCREEN_WIDTH*2/3, SCREEN_HEIGHT-spriteHeight/2)];
            [_allPlayers[2] setPosition:ccp(SCREEN_WIDTH*1/3, SCREEN_HEIGHT-spriteHeight/2)];
            break;
            
        case kPlayerCountFour:
            [_allPlayers[1] setPosition:ccp(SCREEN_WIDTH-spriteWidth/2, SCREEN_HEIGHT*0.6)];
            [_allPlayers[2] setPosition:ccp(SCREEN_WIDTH/2, SCREEN_HEIGHT-spriteHeight/2)];
            [_allPlayers[3] setPosition:ccp(spriteWidth/2, SCREEN_HEIGHT*0.6)];
            break;
            
        case kPlayerCountFive:
            [_allPlayers[1] setPosition:ccp(SCREEN_WIDTH-spriteWidth/2, SCREEN_HEIGHT*0.6)];
            [_allPlayers[2] setPosition:ccp(SCREEN_WIDTH*0.67, SCREEN_HEIGHT-spriteHeight/2)];
            [_allPlayers[3] setPosition:ccp(SCREEN_WIDTH*0.33, SCREEN_HEIGHT-spriteHeight/2)];
            [_allPlayers[4] setPosition:ccp(spriteWidth/2, SCREEN_HEIGHT*0.6)];
            break;
            
        case kPlayerCountSix:
            [_allPlayers[1] setPosition:ccp(SCREEN_WIDTH-spriteWidth/2, SCREEN_HEIGHT*0.6)];
            [_allPlayers[2] setPosition:ccp(SCREEN_WIDTH*3/4, SCREEN_HEIGHT-spriteHeight/2)];
            [_allPlayers[3] setPosition:ccp(SCREEN_WIDTH*1/2, SCREEN_HEIGHT-spriteHeight/2)];
            [_allPlayers[4] setPosition:ccp(SCREEN_WIDTH*1/4, SCREEN_HEIGHT-spriteHeight/2)];
            [_allPlayers[5] setPosition:ccp(spriteWidth/2, SCREEN_HEIGHT*0.6)];
            break;
            
        case kPlayerCountSeven:
            [_allPlayers[1] setPosition:ccp(SCREEN_WIDTH-spriteWidth/2, SCREEN_HEIGHT*0.49)];
            [_allPlayers[2] setPosition:ccp(SCREEN_WIDTH-spriteWidth/2, SCREEN_HEIGHT*0.69)];
            [_allPlayers[3] setPosition:ccp(SCREEN_WIDTH*0.63, SCREEN_HEIGHT-spriteHeight/2)];
            [_allPlayers[4] setPosition:ccp(SCREEN_WIDTH*0.37, SCREEN_HEIGHT-spriteHeight/2)];
            [_allPlayers[5] setPosition:ccp(spriteWidth/2, SCREEN_HEIGHT*0.49)];
            [_allPlayers[6] setPosition:ccp(spriteWidth/2, SCREEN_HEIGHT*0.69)];
            break;
            
        case kPlayerCountEight:
            [_allPlayers[1] setPosition:ccp(SCREEN_WIDTH-spriteWidth/2, SCREEN_HEIGHT*0.49)];
            [_allPlayers[2] setPosition:ccp(SCREEN_WIDTH-spriteWidth/2, SCREEN_HEIGHT*0.69)];
            [_allPlayers[3] setPosition:ccp(SCREEN_WIDTH*3/4, SCREEN_HEIGHT-spriteHeight/2)];
            [_allPlayers[4] setPosition:ccp(SCREEN_WIDTH*1/2, SCREEN_HEIGHT-spriteHeight/2)];
            [_allPlayers[5] setPosition:ccp(SCREEN_WIDTH*1/4, SCREEN_HEIGHT-spriteHeight/2)];
            [_allPlayers[6] setPosition:ccp(spriteWidth/2, SCREEN_HEIGHT*0.49)];
            [_allPlayers[7] setPosition:ccp(spriteWidth/2, SCREEN_HEIGHT*0.69)];
            break;
            
        default:
            break;
    }
    
//  Add progress bar for other players
    [self addProgressBarForOtherPlayers];
}

- (void)addProgressBarForOtherPlayers
{
    for (NSUInteger i = 1; i < _allPlayers.count; i++) {
        [_allPlayers[i] addProgressBar];
    }
}

- (void)removeProgressBarForOtherPlayers
{
    for (NSUInteger i = 1; i < _allPlayers.count; i++) {
        [_allPlayers[i] removeProgressBar];
    }
}

- (void)enablePlayerAreaForOtherPlayers
{
    for (NSUInteger i = 1; i < _allPlayers.count; i++) {
        [_allPlayers[i] enablePlayerArea];
    }
}

- (void)disablePlayerAreaForOtherPlayers
{
    if (_isNormalColor) {
        for (NSUInteger i = 1; i < _allPlayers.count; i++) {
            [_allPlayers[i] disablePlayerAreaWithNormalColor];
        }
    }
}

#pragma mark - Node Color
- (void)setColorWith:(ccColor3B)color ofNode:(CCNode *)node
{
    for (CCNode *subNode in node.children) {
        if ([subNode respondsToSelector:@selector(setColor:)]) {
            CCNodeRGBA *nodeRGBA = (CCNodeRGBA *)subNode;
            if (color.r != nodeRGBA.color.r ||
                color.g != nodeRGBA.color.g ||
                color.b != nodeRGBA.color.b) {
                nodeRGBA.color = color;
            }
        }
        if (subNode.children.count > 0) {
            [self setColorWith:color ofNode:subNode];
        }
    }
}

- (void)makeBackgroundColorToDark
{
    _isNormalColor = NO;
    [self setColorWith:COLOR_DISABLED ofNode:self];
}

- (void)makeBackgroundColorToNormal
{
    _isNormalColor = YES;
    [self setColorWith:ccWHITE ofNode:self];
}

#pragma mark - Playing deck
/*
 * Add playing deck for showing toBeSelectedHeros/used/cutting cards or others
 */
- (void)addPlayingDeck
{
    _playingDeck = [BGPlayingDeck sharedPlayingDeck];
    [self addChild:_playingDeck z:2];
}

#pragma mark - Selected heros
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
    
    [self removeProgressBarForOtherPlayers];
}

/*
 * Adjust the hero id's index, put the hero id of self player selected as first one.
 */
- (void)setAllHeroIds:(NSArray *)allHeroIds
{
    NSMutableArray *mutableHeroIds = [allHeroIds mutableCopy];
    NSMutableIndexSet *idxSet = [NSMutableIndexSet indexSet];
    NSUInteger idx = 0;
    
    for (id obj in allHeroIds) {
        if ([obj integerValue] == _selfPlayer.selectedHeroId) {
            [mutableHeroIds removeObjectsAtIndexes:idxSet];
            [mutableHeroIds addObjectsFromArray:[allHeroIds objectsAtIndexes:idxSet]];
            _allHeroIds = mutableHeroIds;
            break;
        }
        [idxSet addIndex:idx]; idx++;
    }
}

#pragma mark - Player and name
- (BGPlayer *)currPlayer
{
    for (BGPlayer *player in _allPlayers) {
        if ([player.playerName isEqualToString:_currPlayerName]) {
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

- (NSArray *)targetPlayers
{
    NSMutableArray *players = [NSMutableArray arrayWithCapacity:_targetPlayerNames.count];
    [_targetPlayerNames enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        [players addObject:[self playerWithName:obj]];
    }];
    
    return players;
}

- (BGPlayer *)targetPlayer
{
    return (_targetPlayerNames.count == 1) ? self.targetPlayers.lastObject : nil;
}

- (NSUInteger)playerCount
{
    return _allPlayers.count;
}

#pragma mark - Card movement
/*
 * Move the selected cards on playing deck or other player's hand
 */
- (void)moveCardWithCardMenu:(CCMenu *)menu toTargerPlayer:(BGPlayer *)player block:(void(^)())block
{    
    BGActionComponent *ac = [BGActionComponent actionComponentWithNode:menu];
    [ac runEaseMoveWithTarget:player.position
                     duration:DURATION_CARD_MOVE
                        block:block];
}

- (void)moveCardWithCardMenuItems:(NSArray *)menuItems block:(void(^)(id object))block
{
    [menuItems enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        CGPoint targetPos = [self cardMoveTargetPositionWithIndex:idx count:menuItems.count];
        
        BGActionComponent *ac = [BGActionComponent actionComponentWithNode:obj];
        [ac runEaseMoveWithTarget:targetPos
                         duration:DURATION_CARD_MOVE
                           object:obj
                            block:block];
    }];
}

/*
 * Determine target position of selected card movement
 * Set card move target positon according to different game state
 * (Move card to playing deck or other player)
 */
- (CGPoint)cardMoveTargetPositionWithIndex:(NSUInteger)idx count:(NSUInteger)count
{
    NSLog(@"Game state: %i and action: %i", self.state, self.action);
    
    CGPoint targetPos = CGPointZero;
    CGFloat cardWidth = PLAYING_CARD_WIDTH;
//    CGFloat cardHeight = PLAYING_CARD_HEIGHT;
    
    switch (self.state) {
        case kGameStateCutting:
            targetPos = [_playingDeck cardPositionWithIndex:idx];
            break;
            
        case kGameStatePlaying:
        case kGameStateChoosing:
        case kGameStateDiscarding:
            targetPos = [_playingDeck cardPositionWithIndex:idx count:count];
            break;
            
        case kGameStateLosing:
            targetPos = self.targetPlayer.position;
            break;
            
        case kGameStateGetting:
            targetPos = (self.currPlayer.isSelfPlayer) ?
                ccpSub(_selfPlayer.handArea.rightMostPosition, ccp((count-idx-1)*cardWidth/2, 0.0f)) :
//                ccpSub(POSITION_HAND_AREA_RIGHT, ccp((count-idx-1)*cardWidth/2, 0.0f)) :
                ccpAdd(self.currPlayer.position, ccp((idx+1-count+idx)*cardWidth/4, 0.0f));
            break;
            
        case kGameStateGiving: {
            // Current player A's target is player B, the player B's target is player A.
            targetPos = (self.targetPlayer.isCurrPlayer) ?
                ccpSub(_selfPlayer.handArea.rightMostPosition, ccp((count-idx-1)*cardWidth/2, 0.0f)) :
                ccpAdd(self.targetPlayer.position, ccp((idx+1-count+idx)*cardWidth/4, 0.0f));
            break;
        }
            
        default:
            NSLog(@"Invalid game state: %i and action: %i", self.state, self.action);
            break;
    }
    
    return targetPos;
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
