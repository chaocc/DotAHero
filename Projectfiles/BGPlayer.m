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
#import "BGActionComponent.h"

typedef NS_ENUM(NSInteger, BGPlayerTag) {
    kPlayerTagPlayerArea = 100,
    kPlayerTagHandCardCount = 110
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
        
        _positiveDistance = 1;
        _negativeDistance = -1;
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

- (void)setPosition:(CGPoint)position
{
    _position = position;
    
    CCNode *playerArea = [_gameLayer.gameArtworkBatch getChildByTag:(kPlayerTagPlayerArea+_seatIndex)];
    playerArea.position = position;
}

- (NSUInteger)attackRange
{
    return (_attackRange - _negativeDistance - 1);
}

#pragma mark - Buffer handling
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
    self.contentSize = sprite.contentSize;
    sprite.anchorPoint = (_isSelfPlayer) ? CGPointZero : sprite.anchorPoint;
    [_gameLayer.gameArtworkBatch addChild:sprite z:0 tag:(kPlayerTagPlayerArea+_seatIndex)];
    
//  Add hero and equipment area for all players
    _heroArea = [BGHeroArea heroAreaWithPlayer:self];
    [self addChild:_heroArea];
    
    _equipmentArea = [BGEquipmentArea equipmentAreaWithPlayer:self];
    [self addChild:_equipmentArea];
}

- (void)enablePlayerArea
{
    [_heroArea enableHero];
}

- (void)disablePlayerArea
{
    [_heroArea disableHero];
}

- (void)setDisabledColor
{
    if (!_isSelfPlayer) {
        CCSprite *sprite = (CCSprite *)[_gameLayer.gameArtworkBatch getChildByTag:kPlayerTagPlayerArea+_seatIndex];
        sprite.color = COLOR_DISABLED;
        
        [_gameLayer setColorWith:COLOR_DISABLED ofNode:_heroArea];
        [_gameLayer setColorWith:COLOR_DISABLED ofNode:_equipmentArea];
    }
}

- (void)restoreColor
{
    if (!_isSelfPlayer) {
        CCSprite *sprite = (CCSprite *)[_gameLayer.gameArtworkBatch getChildByTag:kPlayerTagPlayerArea+_seatIndex];
        sprite.color = ccWHITE;
        
        [_gameLayer setColorWith:ccWHITE ofNode:_heroArea];
        [_gameLayer setColorWith:ccWHITE ofNode:_equipmentArea];
    }
}

#pragma mark - Hero area
/*
 * Render hero avatar/blood/anger with selected hero card
 */
- (void)renderHeroWithHeroId:(NSInteger)heroId
{
    [_gameLayer setColorWith:ccWHITE ofNode:_gameLayer];
    
    _selectedHeroId = heroId;
    [_heroArea renderHeroWithHeroId:heroId];
    
    if (!_isSelfPlayer) {
        self.handCardCount = COUNT_INITIAL_HAND_CARD;   // 5 cards for each player, use 1 for cutting.
    }
}

/*
 * Update hero blood and anger point
 */
- (void)updateHeroWithBloodPoint:(NSInteger)bloodPoint angerPoint:(NSInteger)angerPoint
{
    [_heroArea updateBloodPointWithCount:bloodPoint];
    [_heroArea updateAngerPointWithCount:angerPoint];
}

#pragma mark - Hand area
/*
 * Initialize hand cards with dealing cards for self player
 */
- (void)addHandAreaWithCardIds:(NSArray *)cardIds
{
    if (cardIds) {
        _handArea = [BGHandArea handAreaWithPlayer:self andCardIs:cardIds];
        _handArea.selectableCardCount = 1;
        [self addChild:_handArea];
    }
}

/*
 * Update(Draw/Got/Used) hand card for self player
 */
- (void)updateHandCardWithCardIds:(NSArray *)cardIds
{
    if (_isSelfPlayer) {
        [_handArea updateHandCardWithCardIds:cardIds];
    } else {
        [_gameLayer.playingDeck updateWithCardIds:cardIds];
    }
}

/*
 * Update hand card count for other player
 */
- (void)updateHandCardWithCardCount:(NSInteger)count
{
    if (kGameStateDrawing == _gameLayer.state) {    // 摸牌
        NSMutableArray *frameNames = [NSMutableArray arrayWithCapacity:count];
        for (NSInteger i = 0; i < count; i++) {
            [frameNames addObject:kImagePlayingCardBack];
        }
        BGMenuFactory *mf = [BGMenuFactory menuFactory];
        CCMenu *menu = [mf createMenuWithSpriteFrameNames:frameNames];
        menu.enabled = NO;
        menu.position = POSITION_DECK_AREA_CENTER;
        [menu alignItemsHorizontallyWithPadding:[menu.children.lastObject contentSize].width/2];
        [self addChild:menu];
        
        [_gameLayer moveCardWithCardMenu:menu
                          toTargerPlayer:self
                                   block:^{
                                       [menu removeFromParent];
                                       self.handCardCount += count;
                                   }];
    } else {
        BGActionComponent *ac = [BGActionComponent actionComponentWithNode:self];
        [ac runDelayWithDuration:DURATION_CARD_MOVE
                       WithBlock:^{
                           self.handCardCount += count;
                       }];
    }
}

/*
 * Update(Give) hand card count for other player after gave target player's cards
 */
- (void)updateHandCardWithCardIds:(NSArray *)cardIds cardCount:(NSUInteger)count
{
//  Target player hand card update is informed by sever
    if (_gameLayer.targetPlayer.isSelfPlayer) {
        return;
    }
    
//  给牌(明置)
    [self moveCardWithCardIds:cardIds
                 fromPosition:self.position
               toTargetPlayer:_gameLayer.targetPlayer];
    
//  给牌(暗置)
    [self moveCardWithCardCount:count
                   fromPosition:self.position
                 toTargetPlayer:_gameLayer.targetPlayer];
}

/*
 * Update(Get) hand card count for other player after got target player's cards
 * Current player hand card count increased, target player reduced.
 */
- (void)updateHandCardWithEquipments:(NSArray *)cardIds cardIdxes:(NSArray *)cardIdxes
{
//  Target player hand card update is informed by sever
    if (_gameLayer.targetPlayer.isSelfPlayer) {
        return;
    }
    
//  抽取装备
    [_gameLayer.targetPlayer.equipmentArea updateEquipmentWithCardId:[cardIds.lastObject integerValue]];
    [self moveCardWithCardIds:cardIds
                 fromPosition:_gameLayer.targetPlayer.position
               toTargetPlayer:self];
//  抽取手牌
    [self moveCardWithCardCount:cardIdxes.count
                   fromPosition:_gameLayer.targetPlayer.position
                 toTargetPlayer:self];
}

- (void)moveCardWithCardIds:(NSArray *)cardIds fromPosition:(CGPoint)fromPos toTargetPlayer:(BGPlayer *)player
{
    if (cardIds.count <= 0) return;
    
    NSArray *cards = [BGPlayingCard playingCardsWithCardIds:cardIds];
    CCMenu *menu = [[BGMenuFactory menuFactory] createMenuWithCards:cards];
    menu.enabled = NO;
    menu.position = fromPos;
    [menu alignItemsHorizontallyWithPadding:[menu.children.lastObject contentSize].width/2];
    [self addChild:menu];
    
    [_gameLayer moveCardWithCardMenu:menu
                      toTargerPlayer:player
                               block:^{
                                   [menu removeFromParent];
                               }];
}

- (void)moveCardWithCardCount:(NSUInteger)count fromPosition:(CGPoint)fromPos toTargetPlayer:(BGPlayer *)player
{
    if (count <= 0) return;
    
    NSMutableArray *frameNames = [NSMutableArray arrayWithCapacity:count];
    for (NSUInteger i = 0; i < count; i++) {
        [frameNames addObject:kImagePlayingCardBack];
    }
    
    CCMenu *menu = [[BGMenuFactory menuFactory] createMenuWithSpriteFrameNames:frameNames];
    menu.enabled = NO;
    menu.position = fromPos;
    [menu alignItemsHorizontallyWithPadding:[menu.children.lastObject contentSize].width/2];
    [self addChild:menu];
    
    [_gameLayer moveCardWithCardMenu:menu
                      toTargerPlayer:player
                               block:^{
                                   [menu removeFromParent];
                               }];
}

/*
 * Make hand card can be selected to use
 */
- (void)enableHandCardWithCardIds:(NSArray *)cardIds selectableCardCount:(NSUInteger)count
{
    [_handArea enableHandCardWithCardIds:cardIds];
    _handArea.selectableCardCount = count;
}

#pragma mark - Equipment area
- (void)updateEquipmentWithCardIds:(NSArray *)cardIds
{
    [_equipmentArea updateEquipmentWithCardId:[cardIds.lastObject integerValue]];
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
    countLabel.position = ccp(-_contentSize.width*0.08, -_contentSize.height*0.24);
    [self addChild:countLabel z:0 tag:kPlayerTagHandCardCount];
}

#pragma mark - Playing menu
/*
 * Add playing menu items according to different action
 * Add progress bar
 */
- (void)addPlayingMenu
{
    [self removePlayingMenu];
    
    switch (_gameLayer.action) {
        case kActionPlayCard:               // 主动使用
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
            
        case kActionChooseColor:            // 选择卡牌颜色
            _playingMenu = [BGPlayingMenu playingMenuWithMenuType:kPlayingMenuTypeCardColor];
            break;
            
        case kActionChooseSuits:            // 选择卡牌花色
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

- (void)removePlayingMenu
{
    [_playingMenu removeFromParent];
}

#pragma mark - Progress bar
- (void)addProgressBarWithPosition:(CGPoint)position
{
    [self removeProgressBar];
    
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
    
//  Run progress bar. If time is up, execute corresponding operation.
    void(^block)() = ^{
        if (kGameStateCutting == _gameLayer.state) {
            [_handArea useHandCardAfterTimeIsUp];
            _comparedCardId = [_selectedCardIds.lastObject integerValue];
            [[BGClient sharedClient] sendChoseCardToCutRequest];
        }
        
        [self removePlayingMenu];
        [self removeProgressBar];
    };
    
    BGActionComponent *ac = [BGActionComponent actionComponentWithNode:timer];
    [ac runProgressBarWithDuration:10.0f
                             block:block];
}

- (void)addProgressBar
{
    CGPoint barPosition = (_isSelfPlayer) ? POSITION_PLYAING_PROGRESS_BAR : ccp(0.0f, -_contentSize.height/2);
    [self addProgressBarWithPosition:barPosition];
}

- (void)removeProgressBar
{
    [_progressBar removeFromParent];
}

@end
