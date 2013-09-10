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

- (void)setPosition:(CGPoint)position
{
    _position = position;
    
    CCNode *playerArea = [_gameLayer.gameArtworkBatch getChildByTag:(kPlayerTagPlayerArea+_seatIndex)];
    playerArea.position = position;
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
 * Update(Draw/Got/Lost) hand card for self player or hand card count for other player
 */
- (void)updateHandCardWithCardIds:(NSArray *)cardIds cardCount:(NSUInteger)count
{
    if (_isSelfPlayer) {
        [_handArea updateHandCardWithCardIds:cardIds];
    } else {
        [self updateHandCardWithCardCount:count];
    }
}

- (void)enableHandCardWithCardIds:(NSArray *)cardIds selectableCardCount:(NSUInteger)count
{
    [_handArea enableHandCardWithCardIds:cardIds];
    _handArea.selectableCardCount = count;
}

- (void)updateHandCardWithCardCount:(NSUInteger)count
{
    NSMutableArray *frameNames = [NSMutableArray arrayWithCapacity:count-_handCardCount];
    for (NSUInteger i = 0; i < count-_handCardCount; i++) {
        [frameNames addObject:kImagePlayingCardBack];
    }
    BGMenuFactory *mf = [BGMenuFactory menuFactory];
    CCMenu *menu = [mf createMenuWithSpriteFrameNames:frameNames];
    menu.enabled = NO;
    menu.position = POSITION_DECK_AREA_CENTER;
    [menu alignItemsHorizontallyWithPadding:[menu.children.lastObject contentSize].width/2];
    [self addChild:menu];
    
    BGActionComponent *ac = [BGActionComponent actionComponentWithNode:menu];
    [ac runEaseMoveWithTarget:_gameLayer.currPlayer.position
                     duration:DURATION_DREW_CARD_MOVE
                        block:^{
                            [menu removeFromParent];
                            self.handCardCount = count;
                        }];
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
    countLabel.position = ccp(_position.x-self.size.width*0.07, _position.y-self.size.height*0.23);
    [self addChild:countLabel z:1 tag:kPlayerTagHandCardCount];
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
    
    BGActionComponent *ac = [BGActionComponent actionComponentWithNode:timer];
    [ac runProgressBarWithDuration:10.0f block:block];
}

- (void)addProgressBar
{
    CGPoint barPosition = (_isSelfPlayer) ? POSITION_PLYAING_PROGRESS_BAR : ccp(0.0f, -_contentSize.height/2);
    
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
