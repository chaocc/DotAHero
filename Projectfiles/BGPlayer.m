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
    kPlayerTagHandCardCount
};


@interface BGPlayer ()

@property (nonatomic, strong) CCSprite *progressBar;

@end

@implementation BGPlayer

@synthesize handCardCount = _handCardCount;

- (id)initWithUserName:(NSString *)name isCurrentPlayer:(BOOL)isCurrentPlayer
{
    if (self = [super init]) {
        _playerName = name;
        _isCurrentPlayer = isCurrentPlayer;
        
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

+ (id)playerWithUserName:(NSString *)name isCurrentPlayer:(BOOL)isCurrentPlayer
{
    return [[self alloc] initWithUserName:name isCurrentPlayer:isCurrentPlayer];
}

- (void)clearBuffer
{
    [self clearSelectedObjectBuffer];
    [[BGGameLayer sharedGameLayer].targetPlayerNames removeAllObjects];
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
 * 1. Current player's position is (0,0) and its sprite positon is the "Center" of the player area
 * 2. Other player's position is setted in class BGGameLayer and its sprite position is (0,0)
 */
- (void)renderPlayerArea
{
    NSString *spriteFrameName = (_isCurrentPlayer) ? kImageCurrentPlayerArea : kImageOtherPlayerArea;
    CCSprite *sprite = [CCSprite spriteWithSpriteFrameName:spriteFrameName];
    _playerAreaSize = sprite.contentSize;
    if (_isCurrentPlayer) {
        sprite.position = ccp(_playerAreaSize.width/2, _playerAreaSize.height/2);
//        self.position = sprite.position;
        _playerAreaPosition = sprite.position;
    }
    [[BGGameLayer sharedGameLayer].gameArtworkBatch addChild:sprite];
    
//  Add hero and equipment area for all players
    [self addHeroArea];
    [self addEquipmentArea];
    
//  Only add hand area for current player
    if (_isCurrentPlayer) {
        [self addHandArea];
    } else {
        self.handCardCount = INITIAL_HAND_CARD_COUND;   // 5 cards for each player, use 1 for cutting.
    }
}

/*
 * Add hero(avatar) area node
 */
- (void)addHeroArea
{
    _heroArea = [BGHeroArea heroAreaWithPlayer:self];
    [self addChild: _heroArea];
}

/*
 * Add hand area node
 */
- (void)addHandArea
{
    _handArea = [BGHandArea handAreaWithPlayer:self];
    [self addChild:_handArea];
}

/*
 * Add equipment area for showing equipment cards
 */
- (void)addEquipmentArea
{
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
- (void)renderHandCardWithCardIds:(NSArray *)cardIds
{
    CCDelayTime *delay = [CCDelayTime actionWithDuration:0.2f];
    CCCallBlock *block = [CCCallBlock actionWithBlock:^{
        [_handArea updateHandCardWithCardIds:cardIds];
        _handArea.selectableCardCount = 1;
    }];
    
    [self runAction:[CCSequence actions:delay, block, nil]];
}

/*
 * Update(Draw/Got/Lost) hand card with card id list and update other properties
 */
- (void)updateHandCardWithCardIds:(NSArray *)cardIds selectableCardCount:(NSUInteger)count
{
    [_handArea updateHandCardWithCardIds:cardIds];
    _handArea.selectableCardCount = count;
//    _handArea.removeOption = 1;
}

- (void)enableHandCardWithCardIds:(NSArray *)cardIds
{
    [_handArea enableHandCardWithCardIds:cardIds];
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
    if (!_isCurrentPlayer) {
        [self renderHandCardCount];
    }
}

- (NSUInteger)handCardCount
{
    return (_isCurrentPlayer) ? _handArea.handCards.count : _handCardCount;
}

/*
 * Display hand card count at right corner of hero avatar(Only for other player)
 */
- (void)renderHandCardCount
{
    [[self getChildByTag:kPlayerTagHandCardCount] removeFromParentAndCleanup:YES];
    
    CCLabelTTF *countLabel = [CCLabelTTF labelWithString:@(_handCardCount).stringValue
                                                fontName:@"Arial"
                                                fontSize:22.0f];
    countLabel.position = ccp(-_playerAreaSize.width*0.07, -_playerAreaSize.height*0.23);
    [self addChild:countLabel z:1 tag:kPlayerTagHandCardCount];
}

#pragma mark - Playing menu
/*
 * Add playing menu items according to different action
 */
- (void)addPlayingMenu
{
    switch (_action) {
        case kActionPlayingCard:            // 主动使用
            _playingMenu = [BGPlayingMenu playingMenuWithMenuType:kPlayingMenuTypePlaying];
            break;
            
        case kActionChooseCardToUse:        // 被动使用
            _playingMenu = [BGPlayingMenu playingMenuWithMenuType:kPlayingMenuTypeChoosing];
            break;
            
        case kActionChooseCardToCompare:    // 确定拼点
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
    _progressBar = [CCSprite spriteWithSpriteFrameName:kImageProgressBarFrameBig];
    _progressBar.position = position;
    [self addChild:_progressBar];
    
    CCSprite *bar = [CCSprite spriteWithSpriteFrameName:kImageProgressBarBig];
    CCProgressTimer *timer = [CCProgressTimer progressWithSprite:bar];
    timer.type = kCCProgressTimerTypeBar;
    timer.midpoint = ccp(0.0f, 0.0f);       // Setup for a bar starting from the left since the midpoint is 0 for the x
    timer.barChangeRate = ccp(1.0f, 0.0f);  // Setup for a horizontal bar since the bar change rate is 0 for y meaning no vertical change
    timer.anchorPoint = CGPointZero;
    [_progressBar addChild:timer];
    
    CCProgressFromTo *progress = [CCProgressFromTo actionWithDuration:10.0f from:100.0f to:0.0f];
    CCCallBlock *callBlock = [CCCallBlock actionWithBlock:block];
    [timer runAction:[CCSequence actions:progress, callBlock, nil]];
}

- (void)removeProgressBar
{
    [_progressBar removeFromParentAndCleanup:YES];
}

@end
