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
#import "BGAnimationComponent.h"

typedef NS_ENUM(NSInteger, BGPlayerTag) {
    kPlayerTagPlayerArea = 100,
    kPlayerTagHandCardCount = 110
};


@interface BGPlayer ()

@property (nonatomic, weak) BGGameLayer *gameLayer;
@property (nonatomic) NSUInteger seatIndex;

@property (nonatomic, strong) BGActionComponent *actionComp;
@property (nonatomic, strong) CCSprite *progressBar;
@property (nonatomic, strong) CCLabelBMFont *textPrompt;

@end

@implementation BGPlayer

@synthesize handCardCount = _handCardCount;
@synthesize usedCard = _usedCard;

- (id)initWithUserName:(NSString *)name seatIndex:(NSUInteger)seatIndex
{
    if (self = [super init]) {
        _gameLayer = [BGGameLayer sharedGameLayer];
        _playerName = name;
        _seatIndex = seatIndex;
        _isSelf = (0 == seatIndex); // First index is self player
        
        _positiveDistance = 1;
        _negativeDistance = -1;
        _attackRange = 1;
        
        _selectedHeroId = kHeroCardInvalid;
        _selectedCardIds = [NSMutableArray array];
        _selectedCardIdxes = [NSMutableArray array];
        _selectedSkillId = kHeroSkillInvalid;
        
        _actionComp = [BGActionComponent actionComponentWithNode:self];
        
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

- (BOOL)isTurnOwner
{
    return [self isEqual:_gameLayer.turnOwner];
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

- (BOOL)canBeDisarmed
{
    return (_equipmentArea.equipmentCards.count > 0);
}

- (BOOL)canBeGreeded
{
    return (self.handCardCount > 0 || _equipmentArea.equipmentCards.count > 0);
}

#pragma mark - Buffer handling
- (void)clearSelectedObjectBuffer
{
    _selectedCardIds = nil;
    [_selectedCardIdxes removeAllObjects];
    _selectedColor = kCardColorInvalid;
    _selectedSuits = kCardSuitsInvalid;
    _selectedEquipment = kPlayingCardInvalid;
    _selectedSkillId = kHeroSkillInvalid;
    
    _selectableCardCount = 0;
    _selectableTargetCount = 0;
    _isStrengthened = NO;
    _isOptionalDiscard = NO;
}

- (void)resetAndRemoveNodes
{
    [self removePlayingMenu];
    [self removeProgressBar];
    [self removeTextPrompt];
    
    if (_isSelf) {
        [_handArea makeHandCardLeftAlignment];  // 选中了卡牌，但点了取消/弃牌按钮，卡牌需要重新排列
        [_handArea disableAllHandCardsWithNormalColor];
        
        [self disablePlayerAreaWithNormalColor];
        [_gameLayer disablePlayerAreaForOtherPlayers];
    }
}

#pragma mark - Player area
/*
 * 1. Self player's position is (0,0) and its sprite anchor point is also (0,0)
 * 2. Other player's position is setted in class BGGameLayer
 */
- (void)renderPlayerArea
{
    NSString *spriteFrameName = (_isSelf) ? kImageSelfPlayerArea : kImageOtherPlayerArea;
    CCSprite *sprite = [CCSprite spriteWithSpriteFrameName:spriteFrameName];
    self.contentSize = sprite.contentSize;
    sprite.anchorPoint = (_isSelf) ? CGPointZero : sprite.anchorPoint;
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
    [self setColorWith:ccWHITE];
}

- (void)disablePlayerAreaWithNormalColor
{
    [_heroArea disableHero];
    [self setColorWith:ccWHITE];
}

- (void)disablePlayerAreaWithDarkColor
{
    [_heroArea disableHero];
    [self setColorWith:COLOR_DISABLED];
}

- (void)setColorWith:(ccColor3B)color
{
    if (!_isSelf) {
        CCSprite *sprite = (CCSprite *)[_gameLayer.gameArtworkBatch getChildByTag:kPlayerTagPlayerArea+_seatIndex];
        sprite.color = color;
        
        [_gameLayer setColorWith:color ofNode:_heroArea];
        [_gameLayer setColorWith:color ofNode:_equipmentArea];
    }
}

#pragma mark - Hero area
/*
 * Render hero avatar/blood/anger with selected hero card
 */
- (void)renderHeroWithHeroId:(NSInteger)heroId
{
    [_gameLayer makeBackgroundColorToNormal];
    
    _selectedHeroId = heroId;
    [_heroArea renderHeroWithHeroId:heroId];
    
    if (!_isSelf) {
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
 * Update(Draw/Used) hand card for self player
 */
- (void)updateHandCardWithCardIds:(NSArray *)cardIds
{
    [_handArea updateHandCardWithCardIds:cardIds];
}

/*
 * Draw card animation for turn owner that is not self player
 */
- (void)drawCardWithCardCount:(NSInteger)count
{
    CCMenu *menu = [[BGMenuFactory menuFactory] createCardBackMenuWithCount:count];
    menu.enabled = NO;
    menu.position = POSITION_DECK_AREA_CENTER;
    [menu alignItemsHorizontallyWithPadding:-PLAYING_CARD_WIDTH/2];
    [_gameLayer addChild:menu];
    
    [_gameLayer moveCardWithCardMenu:menu toTargerPlayer:_gameLayer.turnOwner block:^{
        [menu removeFromParent];
    }];
}

/*
 * Get hand card from playing deck for turn owner
 */
- (void)getCardFromDeckWithCardIds:(NSArray *)cardIds
{
//  Make the deck card with dark color
    NSMutableArray *menuItems = [NSMutableArray arrayWithCapacity:cardIds.count];
    [cardIds enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        for (CCMenuItem *menuItem in _gameLayer.playingDeck.cardMenu.children) {
            if ([obj integerValue] == menuItem.tag) {
                [_gameLayer setColorWith:COLOR_DISABLED_CARD ofNode:menuItem];
                [menuItems addObject:menuItem];
            }
        }
    }];
    
    if (_isSelf) {
        [_handArea addHandCardWithCardMenuItems:menuItems];
    } else {
        CCMenu *menu = [CCMenu menuWithArray:menuItems];
        menu.enabled = NO;
        menu.position = CGPointZero;
        [_gameLayer addChild:menu];
        
        [_gameLayer moveCardWithCardMenu:menu toTargerPlayer:_gameLayer.turnOwner block:^{
            [menu removeFromParent];
        }];
    }
}

/*
 * Draw(抽取) faced down/up card from target player
 * Turn owner hand card count increased, target player reduced.
 */
- (void)drawCardFromTargetPlayerWithCardIds:(NSArray *)cardIds cardCount:(NSUInteger)count
{
//  Target player hand card update is informed by sever(receive update action)
    if (_gameLayer.targetPlayer.isSelf) return;
    
//  抽取装备
    if (cardIds) {
        [_gameLayer.targetPlayer.equipmentArea updateEquipmentWithCardId:[cardIds.lastObject integerValue]];
        [self moveCardWithCardIds:cardIds
                     fromPosition:_gameLayer.targetPlayer.position
                   toTargetPlayer:_gameLayer.turnOwner];
    }
//  抽取手牌
    if (count > 0) {
        [self moveCardWithCardCount:count
                       fromPosition:_gameLayer.targetPlayer.position
                     toTargetPlayer:_gameLayer.turnOwner];
    }
}

/*
 * Give faced down/up hand card to target player
 */
- (void)giveCardToTargetPlayerWithCardIds:(NSArray *)cardIds cardCount:(NSUInteger)count
{
//  Target player hand card update is informed by sever
    if (_gameLayer.targetPlayer.isSelf) return;
    
//  给牌(明置)
    [self moveCardWithCardIds:cardIds
                 fromPosition:_gameLayer.turnOwner.position
               toTargetPlayer:_gameLayer.targetPlayer];
    
//  给牌(暗置)
    [self moveCardWithCardCount:count
                   fromPosition:_gameLayer.turnOwner.position
                 toTargetPlayer:_gameLayer.targetPlayer];
}

- (void)moveCardWithCardIds:(NSArray *)cardIds fromPosition:(CGPoint)fromPos toTargetPlayer:(BGPlayer *)player
{
    if (cardIds.count <= 0) return;
    
    NSArray *cards = [BGPlayingCard playingCardsByCardIds:cardIds];
    CCMenu *menu = [[BGMenuFactory menuFactory] createMenuWithCards:cards];
    menu.enabled = NO;
    menu.position = fromPos;
    [menu alignItemsHorizontallyWithPadding:-PLAYING_CARD_WIDTH/2];
    [_gameLayer addChild:menu];
    
    [_gameLayer moveCardWithCardMenu:menu toTargerPlayer:player block:^{
       [menu removeFromParent];
    }];
}

- (void)moveCardWithCardCount:(NSUInteger)count fromPosition:(CGPoint)fromPos toTargetPlayer:(BGPlayer *)player
{
    if (count <= 0) return;
    
    CCMenu *menu = [[BGMenuFactory menuFactory] createCardBackMenuWithCount:count];
    menu.enabled = NO;
    menu.position = fromPos;
    [menu alignItemsHorizontallyWithPadding:-PLAYING_CARD_WIDTH/2];
    [_gameLayer addChild:menu];
    
    [_gameLayer moveCardWithCardMenu:menu toTargerPlayer:player block:^{
        [menu removeFromParent];
    }];
}

/*
 * Remove hand/equipment card of target player(e.g. Disarm)
 */
- (void)removeCardToDeckWithCardIds:(NSArray *)cardIds
{
    BGPlayingCard *card = [BGPlayingCard cardWithCardId:[cardIds.lastObject integerValue]];
    if ([_gameLayer.targetPlayer.equipmentArea.equipmentCards containsObject:card]) {
        [_gameLayer.targetPlayer.equipmentArea updateEquipmentWithCard:card];
    } else {
        [_gameLayer.playingDeck showUsedCardWithCardIds:cardIds];
    }
}

/*
 * Make hand card can be selected to use
 */
- (void)enableHandCardWithCardIds:(NSArray *)cardIds selectableCardCount:(NSUInteger)count
{
    [self addProgressBar];
    [self addTextPrompt];
    [self addPlayingMenu];
    
    [_handArea enableHandCardWithCardIds:cardIds];
    _handArea.selectableCardCount = count;
}

- (void)enableAllHandCardsWithSelectableCount:(NSUInteger)count
{
    [self addProgressBar];
    [self addTextPrompt];
    [self addPlayingMenu];
    
    [_handArea enableAllHandCards];
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
    if (!_isSelf) {
        [self renderHandCardCount];
    }
}

- (NSUInteger)handCardCount
{
    return (_isSelf) ? _handArea.handCards.count : _handCardCount;
}

/*
 * Display hand card count at right corner of hero avatar(Only for other player)
 */
- (void)renderHandCardCount
{
    [[self getChildByTag:kPlayerTagHandCardCount] removeFromParent];
    
    CCLabelBMFont *countLabel = [CCLabelBMFont labelWithString:@(_handCardCount).stringValue
                                                       fntFile:kFontHandCardCount];
    countLabel.position = ccp(-_contentSize.width*0.08, -_contentSize.height*0.24);
    [self addChild:countLabel z:0 tag:kPlayerTagHandCardCount];
}

#pragma mark - Use hand card
/*
 * Turn owner(self player) use hand card
 */
- (void)useHandCard
{
    BOOL isRunAnimation = (kGameStatePlaying == _gameLayer.state && 1 == _handArea.selectedCards.count);
    
    [_handArea useHandCardWithAnimation:isRunAnimation block:^{
        switch (_gameLayer.state) {
            case kGameStateCutting:
                _comparedCardId = [_selectedCardIds.lastObject integerValue];
                [[BGClient sharedClient] sendChoseCardToCutRequest];
                break;
                
            case kGameStatePlaying:
                [[BGClient sharedClient] sendUseHandCardRequest];
                break;
                
            case kGameStateChoosingCard:
                [[BGClient sharedClient] sendChoseCardToUseRequest];
                break;
                
            case kGameStateGiving:
                [[BGClient sharedClient] sendChoseCardToGiveRequest];
                break;
                
            case kGameStateDiscarding:
                [[BGClient sharedClient] sendChoseCardToDiscardRequest];
                break;
                
            default:
                break;
        }
    }];
}

- (void)useHandCardWithHeroSkill
{
    [_handArea useHandCardWithAnimation:NO block:^{
        [[BGClient sharedClient] sendUseHeroSkillRequest];
    }];
}

/*
 * Turn owner(not self) use hand card
 */
- (void)useHandCardWithCardIds:(NSArray *)cardIds isStrengthened:(BOOL)isStrengthened
{
    _selectedCardIds = cardIds;
    _isStrengthened = isStrengthened;
    
    NSArray *cards = [BGPlayingCard playingCardsByCardIds:cardIds];
    if (kGameStatePlaying == _gameLayer.state && 1 == cardIds.count) {
        BGAnimationComponent *aniComp = [BGAnimationComponent animationComponentWithNode:self];
        [aniComp runWithCard:cards.lastObject atPosition:ccp(0.0f, -_contentSize.height/2)];
    }
    
    if (1 == cards.count && [cards.lastObject isEquipment]) {   // 穿装备
        [_equipmentArea updateEquipmentWithCard:cards.lastObject];
    } else {
        [_gameLayer.playingDeck showUsedCardWithCardIds:cardIds];
    }
}

- (BGPlayingCard *)usedCard
{
    if (_selectedCardIds) {
        NSArray *cards = [BGPlayingCard playingCardsByCardIds:_selectedCardIds];
        _usedCard = cards.lastObject;
    }
    return _usedCard;
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
            
        case kActionChooseCardToCut:        // 切牌
        case kActionChooseCardToGive:       // 交给其他玩家
        case kActionChooseCardToDiscard:    // 弃牌
            if (_isOptionalDiscard) {
                _playingMenu = [BGPlayingMenu playingMenuWithMenuType:kPlayingMenuTypeChoosing];
            } else {
                _playingMenu = [BGPlayingMenu playingMenuWithMenuType:kPlayingMenuTypeOkay];
            }
            break;
            
        case kActionChooseColor:            // 选择卡牌颜色
            _playingMenu = [BGPlayingMenu playingMenuWithMenuType:kPlayingMenuTypeCardColor];
            break;
            
        case kActionChooseSuits:            // 选择卡牌花色
            _playingMenu = [BGPlayingMenu playingMenuWithMenuType:kPlayingMenuTypeCardSuits];
            break;
            
        case kActionDeckShowAssignedCard:
            _playingMenu = [BGPlayingMenu playingMenuWithMenuType:kPlayingMenuTypeOkay];
            break;
            
        default:
            break;
    }
    
    [self addChild:_playingMenu];
    [self clearSelectedObjectBuffer];
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
    
    NSString *frameImageName = (_isSelf) ? kImageProgressBarFrameBig : kImageProgressBarFrame;
    _progressBar = [CCSprite spriteWithSpriteFrameName:frameImageName];
    _progressBar.position = position;
    [self addChild:_progressBar];
    
    NSString *barImageName = (_isSelf) ? kImageProgressBarBig : kImageProgressBar;
    CCSprite *bar = [CCSprite spriteWithSpriteFrameName:barImageName];
    CCProgressTimer *timer = [CCProgressTimer progressWithSprite:bar];
    timer.type = kCCProgressTimerTypeBar;
    timer.midpoint = ccp(0.0f, 0.0f);       // Setup for a bar starting from the left since the midpoint is 0 for the x
    timer.barChangeRate = ccp(1.0f, 0.0f);  // Setup for a horizontal bar since the bar change rate is 0 for y meaning no vertical change
    timer.anchorPoint = CGPointZero;
    [_progressBar addChild:timer];
    
//  Run progress bar. If time is up, execute corresponding operation.    
    BGActionComponent *ac = [BGActionComponent actionComponentWithNode:timer];
    [ac runProgressBarWithDuration:10.0f block:^{
        if (_isSelf) {
            [self handlingAfterTimeIsUp];
        }
        [self resetAndRemoveNodes];
    }];
}

- (void)addProgressBar
{
    CGPoint barPosition = (_isSelf) ? POSITION_PLYAING_PROGRESS_BAR : ccp(0.0f, -_contentSize.height/2);
    [self addProgressBarWithPosition:barPosition];
}

- (void)removeProgressBar
{
    [_progressBar removeFromParent];
}

#pragma mark - Time is up
- (void)handlingAfterTimeIsUp
{
    BGPlayingDeck *playingDeck = _gameLayer.playingDeck;
    
    switch (_gameLayer.state) {
        case kGameStateStarting:
            [playingDeck selectHeroByTouchingMenuItem:[playingDeck.heroMenu.children objectAtIndex:0]];
            break;
            
        case kGameStateCutting:
            [_handArea useHandCardAfterTimeIsUp];
            _comparedCardId = [_selectedCardIds.lastObject integerValue];
            [[BGClient sharedClient] sendChoseCardToCutRequest];
            break;
            
        case kGameStatePlaying:
            [_handArea makeHandCardLeftAlignment];
            [[BGClient sharedClient] sendDiscardRequest];
            break;
            
        case kGameStateChoosingCard:
            [[BGClient sharedClient] sendCancelRequest];
            break;
            
        case kGameStateChoosingColor:
            _selectedColor = kCardColorRed;
            [[BGClient sharedClient] sendChoseColorRequest];
            break;
            
        case kGameStateChoosingSuits:
            _selectedSuits = kCardSuitsHearts;
            [[BGClient sharedClient] sendChoseSuitsRequest];
            break;
            
        case kGameStateGetting:
            [self drawCardFromTargetPlayer];
            break;
            
        case kGameStateGiving:
            [_handArea useHandCardAfterTimeIsUp];
            [[BGClient sharedClient] sendChoseCardToGiveRequest];
            break;
            
        case kGameStateAssigning:
            [_gameLayer.playingDeck assignCardToEachPlayer];
            break;
            
        case kGameStateDiscarding:
            if (_isOptionalDiscard) {
                [[BGClient sharedClient] sendCancelRequest];
            } else {
                [_handArea useHandCardAfterTimeIsUp];
                [[BGClient sharedClient] sendChoseCardToDiscardRequest];
            }
            break;
            
        default:
            break;
    }
}

- (void)drawCardFromTargetPlayer
{
    if (0 == _selectableCardCount) return;
    
    NSMutableArray *menuItems = [NSMutableArray array];
    
    if (_gameLayer.targetPlayer.handCardCount > 0) {
        for (NSUInteger i = 0; i < _selectableCardCount-_selectedCardIdxes.count; i++) {
            [menuItems addObject:[_gameLayer.playingDeck.handMenu.children objectAtIndex:i]];
        }
        [_gameLayer.playingDeck drawHandCardWithMenuItems:menuItems];
    } else {
        [menuItems addObject:[_gameLayer.playingDeck.equipMenu.children objectAtIndex:0]];
        [_gameLayer.playingDeck drawEquipmentWithMenuItems:menuItems];
    }
}

#pragma mark - Text prompt
/*
 * 1. Add text prompt for selected card while playing
 * 2. Add text prompt according to different game state(action)
 * (If "kGameStateChoosingCard", add text according to the used card/skill by turn owner)
 */
- (void)addTextPrompt
{
    NSString *path = [[NSBundle mainBundle] pathForResource:kPlistTextPrompt ofType:kFileTypePlist];
    NSArray *array = [NSArray arrayWithContentsOfFile:path];
    
    switch (_gameLayer.state) {
        case kGameStatePlaying:
            if (_handArea.selectedCards.count > 0) {
                [self addTextPromptForSelectedCard];
            } else {
                [self addTextPromptLabelWithString:array[_gameLayer.state]];
            }
            break;
            
        case kGameStateChoosingCard:
            [self addTextPromptAccordingToUsedCard];
            break;
            
        case kGameStateDying: {
            BGPlayer *player = _gameLayer.turnOwner;
            NSUInteger count = abs(player.heroArea.bloodPoint);  // 需要几张治疗药膏
            NSArray *parameters = [NSArray arrayWithObjects:player.heroArea.heroCard.cardText, @(count), nil];
            NSString *text = array[_gameLayer.state];
            [self addTextPromptLabelWithString:[BGPlayingCard tipTextWith:text parameters:parameters]];
            break;
        }
            
        default:
            [self addTextPromptLabelWithString:array[_gameLayer.state]];
            break;
    }
}

/*
 * Add text prompt while player selecting a card
 */
- (void)addTextPromptForSelectedCard
{
    NSString *text = nil;
    NSArray *parameters = nil;
    
    BGPlayingCard *card = _handArea.selectedCards.lastObject;
    switch (card.cardEnum) {
        case kPlayingCardEnergyTransport:
            parameters = [NSArray arrayWithObject:@(_gameLayer.playerCount).stringValue];
            break;
            
        default:
            break;
    }
    
    text = [BGPlayingCard tipTextWith:card.tipText parameters:parameters];
    [self addTextPromptLabelWithString:text];
}

- (void)addTextPromptLabelWithString:(NSString *)string
{
    if (string) {
        [_textPrompt removeFromParent];
        
        _textPrompt = [CCLabelBMFont labelWithString:string fntFile:kFontTextPrompt];
        _textPrompt.position = POSITION_TEXT_PROMPT;
        [self addChild:_textPrompt];
    }
}

/*
 * Add text prompt while the player is specified as target(by attack/magic)
 * (According to the used card or skill by turn owner)
 */
- (void)addTextPromptAccordingToUsedCard
{
    BGPlayer *turnOwner = _gameLayer.turnOwner;
    NSString *heroName = turnOwner.heroArea.heroCard.cardText;
    NSMutableArray *parameters = [NSMutableArray arrayWithObject:heroName];
    NSString *tipText = turnOwner.usedCard.dispelTipText;  // Used card of turn owner
    
    switch (turnOwner.usedCard.cardEnum) {
        case kPlayingCardMislead: {
            BGPlayer *playerA = _gameLayer.targetPlayers[0];
            BGPlayer *playerB = _gameLayer.targetPlayers[1];
            [parameters addObject:playerA.heroArea.heroCard.cardText];
            [parameters addObject:playerB.heroArea.heroCard.cardText];
            break;
        }
        
        case kPlayingCardDisarm:
        case kPlayingCardGreed:
            [parameters addObject:_gameLayer.targetPlayer.heroArea.heroCard.cardText];
            break;
            
        case kPlayingCardElunesArrow:
            if (_isWaitingDispel) {     // dispel text prompt
                [parameters addObject:_gameLayer.targetPlayer.heroArea.heroCard.cardText];
            } else {                    // target text prompt
                NSString *text = (turnOwner.isStrengthened) ?
                [BGPlayingCard suitsTextByCardSuits:turnOwner.selectedSuits] : // 花色
                [BGPlayingCard colorTextByCardColor:turnOwner.selectedColor];  // 颜色
                [parameters addObject:text];
                tipText = turnOwner.usedCard.targetTipText;
            }
            break;
            
        default:    // 使用不能被驱散的牌时的文字提示
            tipText = turnOwner.usedCard.targetTipText;
            break;
    }
    
    tipText = [BGPlayingCard tipTextWith:tipText parameters:parameters];
    [self addTextPromptLabelWithString:tipText];
}

- (void)removeTextPrompt
{
    [_textPrompt removeFromParent];
}

@end
