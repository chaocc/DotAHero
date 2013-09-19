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

@property (nonatomic, strong, readonly) NSArray *users; // [0] is self user
@property (nonatomic, strong) NSArray *allHeroIds;      // [0] is selected by self user

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

- (BGGameState)state
{
    switch (_action) {
        case kActionChooseCardToCut:
        case kActionDeckShowAllCuttedCards:
            _state = kGameStateCutting;
            break;
            
        case kActionPlayerUpdateHand:
            _state = kGameStateDrawing;
            break;
            
        case kActionChoseCardToGet:
            _state = kGameStateGetting;
            break;
            
        case kActionChoseCardToGive:
            _state = kGameStateGiving;
            break;
            
        case kActionChooseCardToDiscard:
            _state = kGameStateDiscarding;
            break;
            
        case kActionChooseCardToUse:
            _state = kGameStateChoosing;
            break;
            
        default:
            _state = kGameStatePlaying;
            break;
    }
    
    return _state;
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

- (void)setHandCardCountForOtherPlayers
{
    for (NSUInteger i = 1; i < _allPlayers.count; i++) {
        [_allPlayers[i] setHandCardCount:COUNT_INITIAL_HAND_CARD - 1];
    }
}

- (void)disablePlayerAreaForOtherPlayers
{
    for (NSUInteger i = 1; i < _allPlayers.count; i++) {
        [_allPlayers[i] disablePlayerArea];
        [_allPlayers[i] restoreColor];
    }
}

- (void)setColorWith:(ccColor3B)color ofNode:(CCNode *)node
{
    for (CCNode *subNode in node.children) {
        if ([subNode respondsToSelector:@selector(setColor:)]) {
            [(CCNodeRGBA *)subNode setColor:color];
        }
        if (subNode.children.count > 0) {
            [self setColorWith:color ofNode:subNode];
        }
    }
}

#pragma mark - Playing deck
/*
 * Add playing deck for showing toBeSelectedHeros/used/cutting cards or others
 */
- (void)addPlayingDeck
{
    _playingDeck = [BGPlayingDeck sharedPlayingDeck];
    [self addChild:_playingDeck];
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

#pragma mark - Card movement
/*
 * Move the selected cards on playing deck or other player's hand
 */
- (void)moveCardWithCardMenu:(CCMenu *)menu toTargerPlayer:(BGPlayer *)player block:(void(^)())block
{
    CGPoint targetPos = (player.isSelfPlayer) ? POSITION_HAND_AREA_RIGHT : player.position;
    
    BGActionComponent *ac = [BGActionComponent actionComponentWithNode:menu];
    [ac runEaseMoveWithTarget:targetPos
                     duration:DURATION_CARD_MOVE
                        block:block];
}

- (void)moveCardWithCardMenuItems:(NSArray *)menuItems block:(void(^)(id object))block
{
    [menuItems enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        CGPoint targetPos = [self cardMoveTargetPositionWithIndex:idx];
        
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
- (CGPoint)cardMoveTargetPositionWithIndex:(NSUInteger)idx
{
    CGPoint targetPos;
    CGFloat cardWidth = PLAYING_CARD_WIDTH;
    CGFloat cardHeight = PLAYING_CARD_HEIGHT;
    
    switch (self.state) {
        case kGameStateCutting: {            
            NSUInteger rowCount = ceil((double)_allPlayers.count/COUNT_MAX_DECK_CARD);
            NSUInteger colCount = ceil((double)_allPlayers.count/rowCount);
            CGFloat padding = PADDING_CUTTED_CARD;
            
            CGFloat startPosX = POSITION_DECK_AREA_CENTER.x - (colCount-1)*cardWidth/2;
            CGFloat delta = (idx < colCount) ? idx*(cardWidth+padding) : (idx-colCount)*(cardWidth+padding);
            CGFloat cardPosX = startPosX + delta;
            
            CGFloat startPosY = (1 == rowCount) ? POSITION_DECK_AREA_CENTER.y : POSITION_DECK_AREA_TOP.y;
            CGFloat cardPosY = (idx < colCount) ? startPosY : (POSITION_DECK_AREA_TOP.y-cardHeight-padding);
            
            targetPos = ccp(cardPosX, cardPosY);
            break;
        }
        
        case kGameStateDrawing:
        case kGameStateGetting:
            targetPos = self.currPlayer.position;
            break;
            
        case kGameStateChoosing:
        case kGameStatePlaying:
        case kGameStateDiscarding: {
            NSUInteger addedCardCount = _playingDeck.allCardCount - _playingDeck.existingCardCount;
            NSUInteger factor = (_playingDeck.existingCardCount > 0) ? addedCardCount : addedCardCount-1;
            factor += _playingDeck.existingCardCount;
            CGFloat padding = PLAYING_CARD_PADDING(addedCardCount, COUNT_MAX_DECK_CARD);
            CGPoint basePos = ccpSub(POSITION_DECK_AREA_CENTER, ccp(factor*cardWidth/2, 0.0f));
            
            targetPos = ccpAdd(basePos, ccp((cardWidth+padding)*idx, 0.0f));
            break;
        }
        
//        case kGameStateGetting:
//            targetPos = (self.currPlayer.isSelfPlayer) ? POSITION_HAND_AREA_RIGHT : self.currPlayer.position;
//            if (self.targetPlayer.isSelfPlayer) {   // If is target player, move the drew card to current player
//                targetPos = self.currPlayer.position;
//            }
//            break;
            
        case kGameStateGiving:
            targetPos = (self.targetPlayer.isSelfPlayer) ? POSITION_HAND_AREA_RIGHT : self.targetPlayer.position;
            break;
            
        default:
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
