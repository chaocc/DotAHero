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
@property (nonatomic) NSUInteger facedDownCardCount;    // 暗置的牌数

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
    NSArray *cards = [BGPlayingCard playingCardsWithCardIds:cardIds];
    [_handCards addObjectsFromArray:cards];
    
    _menuFactory = [BGMenuFactory menuFactory];
    _cardMenu = [_menuFactory createMenuWithCards:cards];
    _cardMenu.position = CGPointZero;
    [self addChild:_cardMenu];
    _menuFactory.delegate = self;
    
    _cardWidth = [_cardMenu.children.lastObject contentSize].width;
    _cardHeight = [_cardMenu.children.lastObject contentSize].height;
    
    [self makeHandCardLeftAlignment];
}

#pragma mark - Buffer handling
/*
 * Remove hand cards for updating buffer
 */
- (void)updateHandCardBuffer
{
    [_handCards removeObjectsInArray:_selectedCards];
    [_selectedCards removeAllObjects];
}

- (void)clearSelectedCardBuffer
{
    [_selectedCards removeAllObjects];
    [_selectedMenuItems removeAllObjects];
}

#pragma mark - Hand cards updating
/*
 * Update(Draw/Got/Lost) hand card with card id list
 * 
 */
- (void)updateHandCardWithCardIds:(NSArray *)cardIds
{
//  Add or Remove hand card. If the card id is contained in hand cards, need remove it.
    NSMutableArray *addedCards = [NSMutableArray array];
    NSMutableArray *removedCards = [NSMutableArray array];
    [[BGPlayingCard playingCardsWithCardIds:cardIds] enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
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
 * Add hand card - check if there are faced down cards first
 */
- (void)addHandCardWithCards:(NSArray *)cards
{
    [_handCards addObjectsFromArray:cards];
    
//  If there is faced down cards, need face up them by flipping.
    if (0 != _facedDownCardCount) {
        for (NSUInteger i = 0; i < _facedDownCardCount; i++) {
            NSUInteger count = _cardMenu.children.count - _facedDownCardCount;
            CCMenuItem *cardBack = [_cardMenu.children objectAtIndex:count+i];
            
            [_menuFactory addMenuItemsWithCards:cards[i] toMenu:_cardMenu];
            CCMenuItem *newCard = _cardMenu.children.lastObject;
            newCard.visible = NO;
            newCard.position = cardBack.position;
            
            BGActionComponent *actionComp = [BGActionComponent actionComponentWithNode:cardBack];
            [actionComp runFlipFromLeftWithDuration:DURATION_CARD_FLIP toNode:newCard];
        }
        
        _facedDownCardCount = 0;
        return;
    }
    
    [_menuFactory addMenuItemsWithCards:cards toMenu:_cardMenu];
    [self makeHandCardLeftAlignment];
}

/*
 * Remove hand card: Is extracted/discarded or used by server(time out)
 */
- (void)removeHandCardWithCards:(NSArray *)cards
{
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
    
    [self updateHandCardBuffer];
    
    if (kGameStatePlaying == _gameLayer.state || kGameStateCutting == _gameLayer.state) {
        [self moveSelectedCardToPlayingDeck];
    } else {
        [self moveSelectedCardToTargetPlayer];
    }
}

/*
 * Make all hand cards left aligment
 */
- (void)makeHandCardLeftAlignment
{
    NSMutableArray *actions = [NSMutableArray arrayWithCapacity:_cardMenu.children.count];
    
//  If card count is great than 6(No overlap), need narrow the padding. But the first card's position unchanged.
    CGFloat padding = PLAYING_CARD_PADDING(_cardMenu.children.count, COUNT_MAX_HAND_CARD);
    padding = (padding > -_cardWidth) ? padding : -_cardWidth;
    
    [[_cardMenu.children getNSArray] enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        CCMenuItem *menuItem = obj;
        if (0.0f == menuItem.position.x && 0.0f == menuItem.position.y) {
            menuItem.position = POSITION_HAND_AREA_RIGHT;
        }
        
        CGPoint cardPosition = ccpAdd(POSITION_HAND_AREA_LEFT, ccp((_cardWidth+padding)*idx, 0.0f));
//      Can't exceed hand area's width(Not overlap with equipment area)
        cardPosition = (cardPosition.x < POSITION_HAND_AREA_RIGHT.x) ? cardPosition : POSITION_HAND_AREA_RIGHT;
        
        [actions addObject:[CCCallBlock actionWithBlock:^{
            BGActionComponent *ac = [BGActionComponent actionComponentWithNode:menuItem];
            [ac runEaseMoveWithTarget:cardPosition
                             duration:DURATION_HAND_CARD_MOVE
                                block:^{
                                    menuItem.position = cardPosition;
                                }];
        }]];
    }];

    [self runAction:[CCSequence actionWithArray:actions]];
}

#pragma mark - Hand cards availability
/*
 * Enable hand card by receiving available card id list from server
 */
- (void)enableHandCardWithCardIds:(NSArray *)cardIds
{
    _cardMenu.enabled = YES;
    
    NSArray *cards = [BGPlayingCard playingCardsWithCardIds:cardIds];
    [_handCards enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        CCMenuItemSprite *menuItem = (CCMenuItemSprite *)[_cardMenu getChildByTag:[obj cardId]];
//      Check if hand card id is contained in available card id list
        menuItem.isEnabled = ([cards containsObject:obj]);
        
        ccColor3B cardColor;
        if (menuItem.isEnabled) {
            cardColor = ccWHITE;                // Restore to bright color
        } else {
            cardColor = COLOR_DISABLED_CARD;    // Make card figure and suits to gray
        }
        [self setCardColorWithColor:cardColor ofMenuItem:menuItem];
    }];
}

- (void)setCardColorWithColor:(ccColor3B)color ofMenuItem:(CCMenuItemSprite *)menuItem
{
    menuItem.normalImage.color = color;
    
    for (CCSprite *sprite in menuItem.children) {
        sprite.color = color;
    }
}

/*
 * Need enable all hand cards menu while discarding
 */
- (void)enableAllHandCards
{
    _cardMenu.enabled = YES;
    
    for (CCMenuItemSprite *item in _cardMenu.children) {
        if (!item.isEnabled) {
            item.isEnabled = YES;
            [self setCardColorWithColor:ccWHITE ofMenuItem:item];
        }
    }
}

/*
 * Need disable all hand cards menu after use/discard card is over
 */
- (void)disableAllHandCards
{
    _cardMenu.enabled = NO;
    
    for (CCMenuItemSprite *item in _cardMenu.children) {
        if (!item.isEnabled) {
            [self setCardColorWithColor:ccWHITE ofMenuItem:item];
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
    
    NSUInteger idx = [_cardMenu.children indexOfObject:menuItem];
    BGPlayingCard *card = _handCards[idx];
    
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
    void (^block)() = ^{
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
        
        [self checkPlayingMenuAvailabilityWithSelectedCard:card];
        [self checkTargetPlayerSelectivityWithSelectedCard:card];
    };
    
    BGActionComponent *ac = [BGActionComponent actionComponentWithNode:menuItem];
    [ac runEaseMoveWithTarget:targetPos
                     duration:DURATION_SELECTED_CARD_MOVE
                        block:block];
    
}

/*
 * Check playing menu item availability while selecting a hand card
 */
- (void)checkPlayingMenuAvailabilityWithSelectedCard:(BGPlayingCard *)card
{
    CCMenuItem *okayMenu = [_player.playingMenu.menu.children objectAtIndex:kPlayingMenuItemTagOkay];
    NSAssert(okayMenu, @"okayMenu Nil in %@", NSStringFromSelector(_cmd));

//  No card selected
    if (!card.isSelected) {
        okayMenu.isEnabled = NO;
        if (_player.playingMenu.menuType == kPlayingMenuItemTagStrengthen) {
            [_player.playingMenu removeFromParent];
            [_player addPlayingMenu];
        }
        return;
    }

//  Card is selected
    if (kGameStateCutting == _gameLayer.state || kGameStateDiscarding == _gameLayer.state) {
        okayMenu.isEnabled = YES;
        return;
    }

    if (card.canBeStrengthened && _player.heroArea.angerPoint > 0) {
        [_player.playingMenu removeFromParent];
        [_player addPlayingMenuOfStrengthen];
    }

    if (card.needSpecifyTarget) {
        okayMenu.isEnabled = (_gameLayer.targetPlayerNames.count == card.targetCount);
    } else {
        okayMenu.isEnabled = YES;
    }
}

/*
 * Check which player can be selected as target while selecting a hand card
 */
- (void)checkTargetPlayerSelectivityWithSelectedCard:(BGPlayingCard *)card
{
    if (kGameStatePlaying != _gameLayer.state || !card.needSpecifyTarget) {
        return;
    }
    
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
            
        default:
            break;
    }
}

- (void)checkTargetPlayerOfAttack
{
    NSUInteger playerCount = _gameLayer.allPlayers.count;
    
    for (NSUInteger i = 1; i < playerCount; i++) {
        BGPlayer *player = _gameLayer.allPlayers[i];
        NSUInteger halfCount = floor(playerCount/2.0);
        NSInteger distance = (i < halfCount) ? player.positiveDistance+i-1 : player.positiveDistance+playerCount-i-1;
        
        if ((NSInteger)_player.attackRange >= distance) {
            [player enablePlayerArea];
        } else {
            [player setDisabledColor];
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
    
    _player.selectedCardIds = [BGPlayingCard playingCardIdsWithCards:_selectedCards];
    
    if (kGameStatePlaying == _gameLayer.state && 1 == _selectableCardCount &&
        kCardTypeEquipment == [_selectedCards.lastObject cardType]) {   // 装备牌
        [self equipEquipmentCard];
    } else {
        [self moveSelectedCardToPlayingDeck];
    }
    
    [self updateHandCardBuffer];
    
    [_actionComp runDelayWithDuration:DURATION_CARD_MOVE WithBlock:block];
}

- (void)moveSelectedCardToPlayingDeck
{
    [_selectedMenuItems enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        [obj removeFromParent];
    }];
    
    [_gameLayer.playingDeck updateWithCardMenuItems:_selectedMenuItems];

    [self makeHandCardLeftAlignment];
    [_selectedMenuItems removeAllObjects];
}

- (void)moveSelectedCardToTargetPlayer
{
    CCMenu *menu = [CCMenu menuWithArray:_selectedMenuItems];
    menu.enabled = NO;
    menu.position = CGPointZero;
    [menu alignItemsHorizontallyWithPadding:_cardWidth/2];
    [self addChild:menu];
    
    [_gameLayer moveCardWithCardMenuItems:_selectedMenuItems
                                    block:^(id object) {
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
    [self makeHandCardLeftAlignment];
}

/*
 * Add an extracted(抽到的) hand card or equipment into hand and face down it
 */
- (void)addAndFaceDownOneExtractedCardWith:(CCMenuItem *)menuItem
{
    menuItem.isEnabled = NO;
    [_cardMenu addChild:menuItem z:_cardMenu.children.count];
    _facedDownCardCount += 1;
}

/*
 * Selected cards and give them to target player
 */
- (void)giveSelectedCardsToTargetPlayerWithBlock:(void (^)())block
{
    _player.selectedCardIds = [BGPlayingCard playingCardIdsWithCards:_selectedCards];
    [self updateHandCardBuffer];
    [self moveSelectedCardToTargetPlayer];
    
    [_actionComp runDelayWithDuration:DURATION_CARD_MOVE WithBlock:block];
}

@end
