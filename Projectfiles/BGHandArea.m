//
//  BGHandArea.m
//  DotAHero
//
//  Created by Killua Liu on 6/14/13.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

#import "BGHandArea.h"
#import "BGGameLayer.h"
#import "BGFileConstants.h"
#import "BGDefines.h"
#import "BGActionComponent.h"
#import "BGAnimationComponent.h"
#import "BGPluginConstants.h"

@interface BGHandArea ()

@property (nonatomic, weak) BGGameLayer *gameLayer;
@property (nonatomic, weak) BGPlayer *player;

@property (nonatomic, strong) BGActionComponent *actionComp;
@property (nonatomic, strong) BGMenuFactory *menuFactory;
@property (nonatomic, strong) CCMenu *cardMenu;
@property (nonatomic, strong) NSMutableArray *selectedMenuItems;

@property (nonatomic) CGFloat cardWidth;
@property (nonatomic) CGFloat cardHeight;
@property (nonatomic) CGPoint rightMostPosition;        // 手中卡牌的最右边
@property (nonatomic) NSUInteger facedDownCardCount;    // 暗置的牌数
@property (nonatomic) NSUInteger movedCardCount;        // Alignment card count

@end

@implementation BGHandArea

- (id)initWithPlayer:(BGPlayer *)player andCardIds:(NSArray *)cardIds
{
    if (self = [super init]) {
        _gameLayer = [BGGameLayer sharedGameLayer];
        _player = player;
        
        _actionComp = [BGActionComponent actionComponentWithNode:self];
        
        _handCards = [NSMutableArray array];
        _selectedCards = [NSMutableArray array];
        _selectedMenuItems = [NSMutableArray array];
        
        [self initializeHandCardsWithCardIds:cardIds];
    }
    return self;
}

+ (id)handAreaWithPlayer:(BGPlayer *)player andCardIs:(NSArray *)cardIds
{
    return [[self alloc] initWithPlayer:player andCardIds:cardIds];
}

/*
 * Initialize and render hand cards
 */
- (void)initializeHandCardsWithCardIds:(NSArray *)cardIds
{
    NSArray *cards = [BGPlayingCard playingCardsByCardIds:cardIds];
    [_handCards addObjectsFromArray:cards];
    
    _menuFactory = [BGMenuFactory menuFactory];
    _cardMenu = [_menuFactory createMenuWithCards:cards];
    _cardMenu.position = CGPointZero;
    [self addChild:_cardMenu];
    _menuFactory.delegate = self;
    
    _cardWidth = PLAYING_CARD_WIDTH;
    _cardHeight = PLAYING_CARD_HEIGHT;
    
    [self makeHandCardLeftAlignment];
}

#pragma mark - Buffer handling
/*
 * Remove hand cards for updating buffer
 */
- (void)updateHandCardBuffer
{
    [_handCards removeObjectsInArray:_selectedCards];
}

- (void)clearSelectedCardBuffer
{
    [_selectedCards removeAllObjects];
    [_selectedMenuItems removeAllObjects];
}

#pragma mark - Hand cards updating
/*
 * Update(Draw/Lost) hand card with card id list
 * 
 */
- (void)updateHandCardWithCardIds:(NSArray *)cardIds
{
//  Add or Remove hand card. If the card id is contained in hand cards, need remove it.
    NSMutableArray *addedCards = [NSMutableArray array];
    NSMutableArray *removedCards = [NSMutableArray array];
    NSArray *cards = [BGPlayingCard playingCardsByCardIds:cardIds];
    [cards enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        if ([_handCards containsObject:obj]) {
            [removedCards addObject:obj];
        } else {
            [addedCards addObject:obj];
        }
    }];
    
    if (addedCards.count > 0) {
        [self addHandCardWithCards:addedCards];
    }
    if (removedCards.count > 0) {
        [self removeHandCardWithCards:removedCards];
    }
}

/*
 * Add(Got) hand card from deck or target player
 */
- (void)addHandCardWithCardMenuItems:(NSArray *)menuItems
{
    __block NSInteger zOrder = [_cardMenu.children.lastObject zOrder] + 1;
    
    [menuItems enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        BGPlayingCard *card = [BGPlayingCard cardWithCardId:[obj tag]];
        [_handCards addObject:card];    // Add to card buffer
        
        CCMenuItem *menuItem = [_menuFactory createMenuItemWithPlayingCard:card];
        menuItem.position = [obj position];
        [_cardMenu addChild:menuItem z:zOrder++];
    }];
    
    [self makeHandCardLeftAlignment];
    
//    [self disableAllHandCardsWithDarkColor];
}

/*
 * Add hand card - check if there are faced down cards first
 */
- (void)addHandCardWithCards:(NSArray *)cards
{
    _updateType = kHandCardUpdateTypeAdd;
    [_handCards addObjectsFromArray:cards]; // Add to card buffer
    
//  If there is faced down cards, need face up them by flipping.
    if (_facedDownCardCount > 0) {
        [self faceUpCardWithCards:cards];
    }
    else {
        if (kGameStateGetting == _gameLayer.state) {
            [self getCardFromOtherPlayerWithCards:cards];
        } else {
            [self drawCardFromDeckWithCards:cards];
        }
    }
}

- (void)drawCardFromDeckWithCards:(NSArray *)cards
{
    [_menuFactory addMenuItemsWithCards:cards toMenu:_cardMenu];
//    [self disableAllHandCardsWithDarkColor];
    [self makeHandCardLeftAlignment];
}

/*
 * If self player is target player, the "fromOtherPlayer" is current player.
 */
- (void)getCardFromOtherPlayerWithCards:(NSArray *)cards
{
    NSArray *menuItems = [_menuFactory createMenuItemsWithCards:cards];
    __block NSInteger zOrder = [_cardMenu.children.lastObject zOrder] + 1;
    [menuItems enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        CGPoint pos = (_gameLayer.targetPlayer.isSelfPlayer) ?
            _gameLayer.currPlayer.position : _gameLayer.targetPlayer.position;
        [obj setPosition:CARD_MOVE_POSITION(pos, idx, menuItems.count)];
        [_cardMenu addChild:obj z:zOrder++];
    }];
    
    [_gameLayer moveCardWithCardMenuItems:menuItems block:^(id object) {
        [self disableAllHandCardsWithNormalColor];
        [self makeHandCardLeftAlignment];
    }];
}

- (void)faceUpCardWithCards:(NSArray *)cards
{
//  ...TEMP...
    [_actionComp runDelayWithDuration:DURATION_HAND_CARD_MOVE block:^{
        for (NSUInteger i = 0; i < _facedDownCardCount; i++) {
            NSUInteger idx = _handCards.count - _facedDownCardCount + i;
            CCMenuItem *cardBack = [_cardMenu.children objectAtIndex:idx];
            
            [_menuFactory addMenuItemsWithCards:[NSArray arrayWithObject:cards[i]] toMenu:_cardMenu];
            CCMenuItem *newCard = _cardMenu.children.lastObject;
            newCard.visible = NO;
            newCard.position = cardBack.position;
            
            BGActionComponent *ac = [BGActionComponent actionComponentWithNode:cardBack];
            [ac runFlipFromLeftWithDuration:DURATION_CARD_FLIP toNode:newCard block:^{
                _facedDownCardCount--;
            }];
        }
    }];
}

/*
 * Remove hand card: Is drew/discarded or used by server(time up)
 */
- (void)removeHandCardWithCards:(NSArray *)cards
{
    _updateType = kHandCardUpdateTypeRemove;
    _cardMenu.enabled = NO;
    [self clearSelectedCardBuffer];
    
    [cards enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        for (CCMenuItem *item in _cardMenu.children) {
            if ([obj cardId] == item.tag) {
                [_selectedMenuItems addObject:item];
                NSUInteger idx = [_cardMenu.children indexOfObject:item];
                [_selectedCards addObject:_handCards[idx]];
                break;
            }
        }
    }];
    
    if (kGameStateGetting == _gameLayer.state) {
        [self moveSelectedCardToOtherPlayer];
    } else {
        [self moveSelectedCardToPlayingDeck];
    }
    
    [self updateHandCardBuffer];
    [self clearSelectedCardBuffer];
    [self makeHandCardLeftAlignment];
}

/*
 * Make all hand cards left aligment
 * If one card move multiple times at the same time, need wait one by one(by sequence).
 */
- (void)makeHandCardLeftAlignment
{
    if (0 == _handCards.count) {
        _rightMostPosition = POSITION_HAND_AREA_LEFT;
        return;
    }
    
    void(^block)() = ^() {
        NSMutableArray *actions = [NSMutableArray array];
        _movedCardCount = 0;
        
//      If card count is great than 6(No overlap), need narrow the padding. But the first card's position unchanged.
        CGFloat padding = PLAYING_CARD_PADDING(_cardMenu.children.count, COUNT_MAX_HAND_CARD);
        padding = (padding > -_cardWidth) ? padding : -_cardWidth;
        
        [[_cardMenu.children getNSArray] enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            CCMenuItem *menuItem = obj;
            if (CGPointEqualToPoint(menuItem.position, CGPointZero)) {
                menuItem.position = POSITION_HAND_AREA_RIGHT;
            }
            
            // Can't exceed hand area's width(Not overlap with equipment area)
            CGPoint targetPos = ccpAdd(POSITION_HAND_AREA_LEFT, ccp((_cardWidth+padding)*idx, 0.0f));
            targetPos = (targetPos.x < POSITION_HAND_AREA_RIGHT.x) ? targetPos : POSITION_HAND_AREA_RIGHT;
            
            if (stop) _rightMostPosition = targetPos;
            if (CGPointEqualToPoint(menuItem.position, targetPos)) return;  // No need move
            
            [actions addObject:[CCCallBlock actionWithBlock:^{
                BGActionComponent *ac = [BGActionComponent actionComponentWithNode:menuItem];
                [ac runEaseMoveWithTarget:targetPos
                                 duration:DURATION_HAND_CARD_MOVE
                                    block:nil];
            }]];
            
            _movedCardCount++;
        }];
        
        if (block) [actions addObject:[CCCallBlock actionWithBlock:block]];
        if (actions.count > 0) [self runAction:[CCSequence actionWithArray:actions]];
    };
    
//  If has card movement action is running, need wait until finished, then run next.
//  The waiting time is calculated by "DURATION_HAND_CARD_MOVE*_movedCardCount"
    if (self.numberOfRunningActions > 0) {
        [_actionComp runDelayWithDuration:DURATION_HAND_CARD_MOVE*_movedCardCount block:block];
    } else {
        [self runAction:[CCCallBlock actionWithBlock:block]];
    }
}

#pragma mark - Hand cards availability
/*
 * Enable hand card by receiving available card id list from server
 */
- (void)enableHandCardWithCardIds:(NSArray *)cardIds
{
    _cardMenu.enabled = YES;
    
    NSArray *cards = [BGPlayingCard playingCardsByCardIds:cardIds];
    [_handCards enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        CCMenuItemSprite *menuItem = (CCMenuItemSprite *)[_cardMenu getChildByTag:[obj cardId]];
//      Check if hand card id is contained in available card id list
        menuItem.isEnabled = ([cards containsObject:obj]);
        
        ccColor3B cardColor;
        if (menuItem.isEnabled) {
            cardColor = ccWHITE;                // Restore to normal color
        } else {
            cardColor = COLOR_DISABLED_CARD;    // Make card figure and suits to gray
        }
        [_gameLayer setColorWith:cardColor ofNode:menuItem];
    }];
}

/*
 * Need enable all hand cards menu while discarding
 */
- (void)enableAllHandCards
{
    _cardMenu.enabled = YES;
    
    for (CCMenuItem *menuItem in _cardMenu.children) {
        if (!menuItem.isEnabled) {
            menuItem.isEnabled = YES;
            [_gameLayer setColorWith:ccWHITE ofNode:menuItem];
        }
    }
}

/*
 * Need disable all hand cards menu after use/discard card is over
 */
- (void)disableAllHandCardsWithNormalColor
{
    _cardMenu.enabled = NO;
    
    for (CCMenuItem *menuItem in _cardMenu.children) {
        if (!menuItem.isEnabled) {
            [_gameLayer setColorWith:ccWHITE ofNode:menuItem];
        }
    }
}

- (void)disableAllHandCardsWithDarkColor
{
    _cardMenu.enabled = NO;
    
    for (CCMenuItem *menuItem in _cardMenu.children) {
        if (menuItem.isEnabled) {
            [_gameLayer setColorWith:COLOR_DISABLED_CARD ofNode:menuItem];
        }
    }
}

#pragma mark - Hand cards selection
/*
 * Menu delegate method is called while selecting a hand card
 */
- (void)menuItemTouched:(CCMenuItem *)menuItem
{
    NSAssert(_selectedCards, @"_selectedCards Nil in %@", NSStringFromSelector(_cmd));
    NSAssert(_selectedMenuItems, @"_selectedMenuItems Nil in %@", NSStringFromSelector(_cmd));
    
    BGPlayingCard *card = _handCards[[_cardMenu.children indexOfObject:menuItem]];
    
//  Need move up/down while a card is selected/deselected
    CGPoint targetPos;
    CGFloat cardPosY = POSITION_HAND_AREA_LEFT.y;
    CGFloat moveHeight = _player.contentSize.height*0.12;
    
    card.isSelected = !card.isSelected;
    if (card.isSelected) {
        targetPos = ccp(menuItem.position.x, cardPosY+moveHeight);
        [_selectedMenuItems addObject:menuItem];
        [_selectedCards addObject:card];
        _player.selectableTargetCount = card.targetCount;
    }
    else {
        targetPos = ccp(menuItem.position.x, cardPosY);
        [_selectedMenuItems removeObject:menuItem];
        [_selectedCards removeObject:card];
        _player.selectableTargetCount = 0;
    }
    
//  Move card while selecting one. Call below block after movement
//  If selected cards count great than maximum, deselect and remove the first selected card.    
    BGActionComponent *ac = [BGActionComponent actionComponentWithNode:menuItem];
    [ac runEaseMoveWithTarget:targetPos duration:DURATION_SELECTED_CARD_MOVE block:^{
        if (_selectedCards.count > _selectableCardCount) {
            @try {
                for (CCMenuItem *item in _cardMenu.children) {
                    if (item.tag == [_selectedCards[0] cardId]) {
                        [_selectedCards[0] setIsSelected:NO];
                        item.position = ccp(item.position.x, cardPosY);
                        break;
                    }
                }
                [_selectedMenuItems removeObjectAtIndex:0];
                [_selectedCards removeObjectAtIndex:0];
            }
            @catch (NSException *exception) {
                NSLog(@"Exception: %@ in selector %@", exception.description, NSStringFromSelector(_cmd));
            }
        }
        
        [_player addTextPrompt];
        [self checkPlayingMenuAvailabilityWithSelectedCard:card];
        [self checkTargetPlayerSelectivityWithSelectedCard:card];
    }];
}

#pragma mark - Playing menu enablement
/*
 * Check playing menu item availability while selecting a hand card
 */
- (void)checkPlayingMenuAvailabilityWithSelectedCard:(BGPlayingCard *)card
{
    CCMenuItem *okayMenu = [_player.playingMenu menuItemByTag:kPlayingMenuItemTagOkay];
    CCMenuItem *strenMenu;

//  Card is selected, check if only has one "Okay" menu
    if (1 == _player.playingMenu.menuItemCount) {
        okayMenu.isEnabled = (card.isSelected || _selectedCards.count > 0);
        return;
    }
    
//  No card selected
    if (!card.isSelected && 0 == _selectedCards.count) {
        okayMenu.isEnabled = NO;
        [_gameLayer.targetPlayerNames removeAllObjects];    // Remove selected target player
        
        if (_player.playingMenu.isStrengthening) {
            [_player.playingMenu removeFromParent];
            [_player addPlayingMenu];
        }
        return;
    }

    if (card.canBeStrengthened && _player.heroArea.angerPoint > 0) {
        // The last card is greed, can't strengthen.
        if ((kPlayingCardGreed == card.cardEnum) && (1 == _handCards.count)) return; 
        
        [_player.playingMenu removeFromParent];
        [_player addPlayingMenuOfStrengthen];
        okayMenu = [_player.playingMenu menuItemByTag:kPlayingMenuItemTagOkay];
        strenMenu = [_player.playingMenu menuItemByTag:kPlayingMenuItemTagStrengthen];
    }

    if (card.needSpecifyTarget) {
        okayMenu.isEnabled = (_gameLayer.targetPlayerNames.count == card.targetCount);
    } else {
        okayMenu.isEnabled = YES;
    }
    
    if (strenMenu) {
        strenMenu.isEnabled = okayMenu.isEnabled;
    }
}

#pragma mark - Target player selection
/*
 * Check which player can be selected as target while selecting a hand card
 */
- (void)checkTargetPlayerSelectivityWithSelectedCard:(BGPlayingCard *)card
{
    if (kGameStatePlaying != _gameLayer.state) return;
    
    if (!card.isSelected) {
        [_gameLayer disablePlayerAreaForOtherPlayers];
        return;
    }
    
    switch (card.cardEnum) {
        case kPlayingCardNormalAttack:
        case kPlayingCardFlameAttack:
        case kPlayingCardChaosAttack:
            [self checkTargetPlayerOfAttack];
            break;
            
        case kPlayingCardDisarm:
            [self checkTargetPlayerOfDisarm];
            break;
            
        case kPlayingCardMislead:
            [self checkTargetPlayerOfMislead];
            break;
            
        case kPlayingCardGreed:
            [self checkTargetPlayerOfGreed];
            break;
            
        case kPlayingCardLagunaBlade:
        case kPlayingCardViperRaid:
        case kPlayingCardElunesArrow:
            [_gameLayer enablePlayerAreaForOtherPlayers];
            break;
            
        default:
            [_gameLayer disablePlayerAreaForOtherPlayers];
            break;
    }
}

/*
 * Check by attack range and distance
 */
- (void)checkTargetPlayerOfAttack
{
    for (NSUInteger i = 1; i < _gameLayer.playerCount; i++) {
        BGPlayer *player = _gameLayer.allPlayers[i];
        NSUInteger halfCount = floor(_gameLayer.playerCount/2.0);
        NSInteger distance = (i < halfCount) ? player.positiveDistance+i-1 : player.positiveDistance+_gameLayer.playerCount-i-1;
        
        if ((NSInteger)_player.attackRange >= distance) {
            [player enablePlayerArea];
        } else {
            [player disablePlayerAreaWithDarkColor];
        }
    }
}

/*
 * Target player's equipment card count must be great than 0
 */
- (void)checkTargetPlayerOfDisarm
{    
    for (NSUInteger i = 1; i < _gameLayer.playerCount; i++) {
        BGPlayer *player = _gameLayer.allPlayers[i];
        
        if (player.canBeDisarmed) {
            [player enablePlayerArea];
        } else {
            [player disablePlayerAreaWithDarkColor];
        }
    }
}

/*
 * Target player A's anger point must be great than 0
 * Target player B is checked while selecting the player A(in BGHeroArea)
 */
- (void)checkTargetPlayerOfMislead
{
    for (NSUInteger i = 0; i < _gameLayer.playerCount; i++) {
        BGPlayer *player = _gameLayer.allPlayers[i];
        
        if (player.heroArea.angerPoint > 0) {
            [player enablePlayerArea];
        } else {
            [player disablePlayerAreaWithDarkColor];
        }
    }
}

/*
 * The greed card can't be last one card for current player
 * Target player hand&equipment card count can't be all empty
 */
- (void)checkTargetPlayerOfGreed
{
    [_gameLayer enablePlayerAreaForOtherPlayers];
    
    if (1 == _handCards.count) {
        for (NSUInteger i = 1; i < _gameLayer.playerCount; i++) {
            BGPlayer *player = _gameLayer.allPlayers[i];
            if (!player.canBeGreeded) {
                [player disablePlayerAreaWithDarkColor];
            }
        }
    }
}

#pragma mark - Hand card using
/*
 * 1. Use hand card/equip equipment with effect animation(Yes/No)
 * 2. Set selected hand card ids by self player
 */
- (void)useHandCardWithAnimation:(BOOL)isRun block:(void (^)())block
{
    _cardMenu.enabled = NO;
    
    if (isRun) {
        BGAnimationComponent *aniComp = [BGAnimationComponent animationComponentWithNode:self];
        [aniComp runWithCard:_selectedCards.lastObject atPosition:POSITION_CARD_ANIMATION];
    }
    
    _player.selectedCardIds = [BGPlayingCard playingCardIdsByCards:_selectedCards];
    
    if (kGameStatePlaying == _gameLayer.state && 1 == _selectableCardCount &&
        [_selectedCards.lastObject isEquipment]) {  // 装备牌
        [self equipEquipmentCard];
    }
    else {
        if (kGameStateGiving == _gameLayer.state) {
            [self moveSelectedCardToOtherPlayer];
        } else {
            [self moveSelectedCardToPlayingDeck];
        }
    }
    
    [self updateHandCardBuffer];
    [self clearSelectedCardBuffer];
    [self makeHandCardLeftAlignment];
    
    [_actionComp runDelayWithDuration:DURATION_CARD_MOVE block:block];
}

- (void)useHandCardAfterTimeIsUp
{
    [self clearSelectedCardBuffer];
    
    for (NSUInteger i = 0; i < _selectableCardCount; i++) {
        [_selectedMenuItems addObject:[_cardMenu.children objectAtIndex:i]];
        [_selectedCards addObject:_handCards[i]];
    }
    
    [self useHandCardWithAnimation:NO block:nil];
}

- (void)moveSelectedCardToPlayingDeck
{
    [_selectedMenuItems enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        [obj removeFromParent];
    }];
    
    [_gameLayer.playingDeck showUsedCardWithCardMenuItems:_selectedMenuItems];
}

- (void)moveSelectedCardToOtherPlayer
{
    [_selectedMenuItems enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        [obj removeFromParent];
    }];
    
    CCMenu *menu = [CCMenu menuWithArray:_selectedMenuItems];
    menu.enabled = NO;
    menu.position = CGPointZero;
    [self addChild:menu];
    
    [_gameLayer moveCardWithCardMenuItems:_selectedMenuItems block:^(id object) {
        [menu removeFromParent];
    }];
}

/*
 * Select a equipment card to equip
 */
- (void)equipEquipmentCard
{
    [_player.equipmentArea updateEquipmentWithCard:_selectedCards.lastObject];
    [_selectedMenuItems.lastObject removeFromParent];
}

/*
 * Add an drew(抽到的) hand card or equipment into hand and face down it
 */
- (void)addAndFaceDownOneDrewCardWith:(CCMenuItem *)menuItem
{
    menuItem.isEnabled = NO;
    NSInteger zOrder = [_cardMenu.children.lastObject zOrder] + 1;
    [_cardMenu addChild:menuItem z:zOrder];
    _facedDownCardCount += 1;
}

#pragma mark - Card move position
- (CGPoint)cardMoveTargetPositionWithIndex:(NSUInteger)idx count:(NSUInteger)count
{
    CGPoint targetPos = ccpAdd(_rightMostPosition, ccp((idx+1)*_cardWidth, 0.0f));
    if (targetPos.x > POSITION_HAND_AREA_RIGHT.x) {
        targetPos = ccpSub(_rightMostPosition, ccp((count-idx-1)*_cardWidth/2, 0.0f));
    }
    
    return targetPos;
}

@end
