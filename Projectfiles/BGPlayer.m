//
//  BGPlayer.m
//  DotAHero
//
//  Created by Killua Liu on 7/2/13.
//
//

#import "BGPlayer.h"
#import "BGClient.h"
#import "BGGameLayer.h"
#import "BGFileConstants.h"
#import "BGDefines.h"
#import "BGMoveComponent.h"

typedef NS_ENUM(NSInteger, BGPlayerTag) {
    kPlayerTagPlayerArea = 100,
    kPlayerTagHandCardCount
};


@interface BGPlayer ()

@property (nonatomic, weak) BGGameLayer *gameLayer;
@property (nonatomic) NSUInteger seatIndex;
@property (nonatomic, strong) CCSprite *progressBar;

@end

@implementation BGPlayer

@synthesize handCardCount = _handCardCount;

- (id)initWithUserName:(NSString *)name seatIndex:(NSUInteger)seatIndex
{
    if (self = [super init]) {
        _gameLayer = [BGGameLayer sharedGameLayer];
        _playerName = name;
        _seatIndex = seatIndex;
        _isSelfPlayer = (seatIndex == 0);   // First index is self player
        
        _distance = 1;
        _attackRange = 1;
        
        _selectedHeroId = kHeroCardInvalid;
        _selectedCardIds = [NSMutableArray array];
        _selectedCardIdxes = [NSMutableArray array];
        _selectedSkillId = kHeroSkillInvalid;
        
        [self renderPlayerArea];
    }
    return self;
}

+ (id)playerWithUserName:(NSString *)name seatIndex:(NSUInteger)seatIndex
{
    return [[self alloc] initWithUserName:name seatIndex:seatIndex];
}

- (BOOL)isEqual:(id)object
{
    return [_playerName isEqual:[object playerName]];
}

- (void)setAreaPosition:(CGPoint)areaPosition
{
    _areaPosition = areaPosition;
    
    CCNode *playerArea = [_gameLayer.gameArtworkBatch getChildByTag:(kPlayerTagPlayerArea+_seatIndex)];
    playerArea.position = areaPosition;
}

- (void)clearBuffer
{
    [self clearSelectedObjectBuffer];
    [_gameLayer.targetPlayerNames removeAllObjects];
}

- (void)clearSelectedObjectBuffer
{
    _selectedCardIds = nil;
    [_selectedCardIdxes removeAllObjects];
    _selectedColor = kCardColorInvalid;
    _selectedSuits = kCardSuitsInvalid;
    _selectedSkillId = kHeroSkillInvalid;
}

#pragma mark - Player area
/*
 * 1. Self player's position is (0,0) and its sprite anchor point is also (0,0)
 * 2. Other player's position is setted in class BGGameLayer
 */
- (void)renderPlayerArea
{
    NSString *spriteFrameName = (_isSelfPlayer) ? kImageSelfPlayerArea : kImageOtherPlayerArea;
    CCSprite *sprite = [CCSprite spriteWithSpriteFrameName:spriteFrameName];
    _areaSize = sprite.contentSize;
    sprite.anchorPoint = (_isSelfPlayer) ? CGPointZero : sprite.anchorPoint;
    [_gameLayer.gameArtworkBatch addChild:sprite z:0 tag:(kPlayerTagPlayerArea+_seatIndex)];
    
//  Add hero and equipment area for all players
    _heroArea = [BGHeroArea heroAreaWithPlayer:self];
    [self addChild:_heroArea];
    
    _equipmentArea = [BGEquipmentArea equipmentAreaWithPlayer:self];
    [self addChild:_equipmentArea];
}

#pragma mark - Hero area
/*
 * Initialize hero avatar/blood/anger with selected hero card
 */
- (void)renderHeroWithHeroId:(NSInteger)heroId
{
    _selectedHeroId = heroId;
    [_heroArea renderHeroWithHeroId:heroId];
    
    if (!_isSelfPlayer) {
        self.handCardCount = COUNT_INITIAL_HAND_CARD;   // 5 cards for each player, use 1 for cutting.
    }
}

/*
 * Update hero blood and anger point
 */
- (void)updateHeroWithBloodPoint:(NSInteger)bloodPoint angerPoint:(NSUInteger)angerPoint
{
    [_heroArea updateBloodPointWithCount:bloodPoint];
    [_heroArea updateAngerPointWithCount:angerPoint];
}

#pragma mark - Hand area
/*
 * Initialize hand cards with dealing cards
 */
- (void)addHandAreaWithCardIds:(NSArray *)cardIds
{
    if (cardIds) {
        _handArea = [BGHandArea handAreaWithPlayer:self andCardIs:cardIds];
        _handArea.selectableCardCount = 2;
        [self addChild:_handArea];
    }
}

/*
 * Update(Draw/Got/Lost) hand card with card id list and update other properties
 */
- (void)updateHandCardWithCardIds:(NSArray *)cardIds
{
    [_handArea updateHandCardWithCardIds:cardIds];
}

- (void)enableHandCardWithCardIds:(NSArray *)cardIds selectableCardCount:(NSUInteger)count
{
    [_handArea enableHandCardWithCardIds:cardIds];
    _handArea.selectableCardCount = count;
}

#pragma mark - Equipment area
- (void)updateEquipmentWithCardIds:(NSArray *)cardIds
{
    NSArray *cards = [BGHandArea playingCardsWithCardIds:cardIds];
    [_equipmentArea updateEquipmentWithCard:cards.lastObject];
}

#pragma mark - Hand card count
- (void)setHandCardCount:(NSUInteger)handCardCount
{
    _handCardCount = handCardCount;
    if (!_isSelfPlayer) {
        [self renderHandCardCount];
    }
}

- (NSUInteger)handCardCount
{
    return (_isSelfPlayer) ? _handArea.handCards.count : _handCardCount;
}

/*
 * Display hand card count at right corner of hero avatar(Only for other player)
 */
- (void)renderHandCardCount
{
    [[self getChildByTag:kPlayerTagHandCardCount] removeFromParent];
    
    CCLabelTTF *countLabel = [CCLabelTTF labelWithString:@(_handCardCount).stringValue
                                                fontName:@"Arial"
                                                fontSize:22.0f];
    countLabel.position = ccp(_areaPosition.x-_areaSize.width*0.07, _areaPosition.y-_areaSize.height*0.23);
    [self addChild:countLabel z:1 tag:kPlayerTagHandCardCount];
}

#pragma mark - Card movement
/*
 * Move the selected cards to playing deck or other player's hand
 */
- (void)moveSelectedCardWithMenuItems:(NSArray *)menuItems block:(void (^)())block
{
//  Check if need clear playing deck
    NSUInteger deckCardCount = _gameLayer.playingDeck.cardCount;
    NSUInteger selectedCount = menuItems.count;
    if (_gameLayer.playingDeck.isNeedClearDeck || deckCardCount+selectedCount > COUNT_MAX_DECK_CARD_NO_OVERLAP) {
//        [_gameLayer.playingDeck clearUsedCardOnDeck];
        _gameLayer.playingDeck.isNeedClearDeck = NO;
//        deckCardCount = 0;
    }
    
//  Determine movement target position and check if need narrow the card padding
    __block CGPoint targetPos = [self cardMoveTargetPosition];
    NSUInteger count = (0 != deckCardCount) ? selectedCount : selectedCount-1;
    CGFloat cardPadding = [_handArea cardPaddingWithCardCount:selectedCount maxCount:COUNT_MAX_DECK_CARD_NO_OVERLAP];
    targetPos = ccpSub(targetPos, ccp((deckCardCount+count)*_handArea.cardWidth/2, 0.0f));
    
//  Card movement
    [menuItems enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        BGMoveComponent *moveComp = [BGMoveComponent moveWithNode:obj];
        [moveComp runActionEaseMoveWithTarget:targetPos
                                     duration:DURATION_USED_CARD_MOVE
                                       object:[NSValue valueWithCGPoint:targetPos]
                                       blockO:^(id object) {
                                           [obj removeFromParent];
                                           [obj setPosition:[object CGPointValue]];
                                       }];
        
        targetPos = ccpAdd(targetPos, ccp((_handArea.cardWidth+cardPadding)*(idx+1), 0.0f));
    }];
    
//  Run after card movement is finished
    if ([self isNeedUpdateDeck]) {
        [self runActionDelayWithBlock:^{
            [_gameLayer.playingDeck updatePlayingDeckWithCardMenuItems:menuItems];
        }];
    }
    [self runActionDelayWithBlock:block];
}

/*
 * Determine target position of selected card movement
 */
- (CGPoint)cardMoveTargetPosition
{
    CGPoint targetPos;
    
    switch (_gameLayer.action) {
        case kActionChooseCardToCut:
        case kActionUpdateDeckCuttedCard: {
            CGFloat cardPadding = PADDING_CUTTED_CARD;
            NSUInteger rowCount = ceil((double)_gameLayer.allPlayers.count/COUNT_MAX_DECK_CARD_NO_OVERLAP);
            NSUInteger colCount = ceil((double)_gameLayer.allPlayers.count/rowCount);
            
            CGFloat cardPosY = (1 == rowCount) ? POSITION_DECK_AREA_CENTER.y : POSITION_DECK_AREA_TOP.y;
            break;
        }
            
        case kActionUpdatePlayerHandExtracted:
        case kActionUpdatePlayerEquipmentExtracted: {
            BGPlayer *targetPlayer = [_gameLayer playerWithName:_gameLayer.targetPlayerNames.lastObject];
            BGPlayer *player = ([self isEqual:_gameLayer.currPlayer]) ? targetPlayer : _gameLayer.currPlayer;
            targetPos = player.areaPosition;
            break;
        }
            
        default:
            targetPos = POSITION_DECK_AREA_CENTER;
            break;
    }
    
    return targetPos;
}

- (BOOL)isNeedUpdateDeck
{
    return (kActionUpdatePlayerHandExtracted != _gameLayer.action &&
            kActionUpdatePlayerEquipmentExtracted != _gameLayer.action);
}

- (void)runActionDelayWithBlock:(void (^)())block
{
    if (block) {
        CCDelayTime *delay = [CCDelayTime actionWithDuration:DURATION_USED_CARD_MOVE];
        CCCallBlock *callBlock = [CCCallBlock actionWithBlock:block];
        [self runAction:[CCSequence actions:delay, callBlock, nil]];
    }
}

#pragma mark - Playing menu
/*
 * Add playing menu items according to different action
 * Add progress bar
 */
- (void)addPlayingMenu
{
    switch (_gameLayer.action) {
        case kActionPlayingCard:            // 主动使用
            _playingMenu = [BGPlayingMenu playingMenuWithMenuType:kPlayingMenuTypePlaying];
            break;
            
        case kActionChooseCardToUse:        // 被动使用
            _playingMenu = [BGPlayingMenu playingMenuWithMenuType:kPlayingMenuTypeChoosing];
            break;
            
        case kActionChooseCardToCut:        // 确定切牌
        case kActionChooseCardToGive:       // 交给其他玩家
        case kActionChooseCardToDiscard:    // 确定弃牌
            _playingMenu = [BGPlayingMenu playingMenuWithMenuType:kPlayingMenuTypeOkay];
            break;
            
        case kActionChoosingColor:          // 选择卡牌颜色
            _playingMenu = [BGPlayingMenu playingMenuWithMenuType:kPlayingMenuTypeCardColor];
            break;
            
        case kActionChoosingSuits:          // 选择卡牌花色
            _playingMenu = [BGPlayingMenu playingMenuWithMenuType:kPlayingMenuTypeCardSuits];
            break;
            
        default:
            break;
    }
    
    [self addChild:_playingMenu];
}

- (void)addPlayingMenuOfStrengthen
{
    _playingMenu = [BGPlayingMenu playingMenuWithMenuType:kPlayingMenuTypeStrengthening];
    [self addChild:_playingMenu];
}

#pragma mark - Progress bar
- (void)addProgressBarWithPosition:(CGPoint)position block:(void (^)())block
{
    NSString *frameImageName = (_isSelfPlayer) ? kImageProgressBarFrameBig : kImageProgressBarFrame;
    _progressBar = [CCSprite spriteWithSpriteFrameName:frameImageName];
    _progressBar.position = position;
    [self addChild:_progressBar];
    
    NSString *barImageName = (_isSelfPlayer) ? kImageProgressBarBig : kImageProgressBar;
    CCSprite *bar = [CCSprite spriteWithSpriteFrameName:barImageName];
    CCProgressTimer *timer = [CCProgressTimer progressWithSprite:bar];
    timer.type = kCCProgressTimerTypeBar;
    timer.midpoint = ccp(0.0f, 0.0f);       // Setup for a bar starting from the left since the midpoint is 0 for the x
    timer.barChangeRate = ccp(1.0f, 0.0f);  // Setup for a horizontal bar since the bar change rate is 0 for y meaning no vertical change
    timer.anchorPoint = CGPointZero;
    [_progressBar addChild:timer];
    
    CCProgressFromTo *progress = [CCProgressFromTo actionWithDuration:10.0f from:100.0f to:0.0f];
    CCCallBlock *callBlock = (block) ? [CCCallBlock actionWithBlock:block] : nil;
    [timer runAction:[CCSequence actions:progress, callBlock, nil]];
}

- (void)addProgressBar
{
    CGPoint barPosition = (_isSelfPlayer) ? POSITION_PLYAING_PROGRESS_BAR : ccp(_areaPosition.x, _areaPosition.y - _areaSize.height/2);
    
    __weak BGPlayer *player = self;
    [player addProgressBarWithPosition:barPosition
                                 block:^{
                                     [_playingMenu removeFromParent];
                                     [self removeProgressBar];
                                 }];
}

- (void)removeProgressBar
{
    [_progressBar removeFromParent];
}

@end
