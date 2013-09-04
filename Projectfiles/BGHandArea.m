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
#import "BGMoveComponent.h"
#import "BGEffectComponent.h"
#import "BGPluginConstants.h"

@interface BGHandArea ()

@property (nonatomic, weak) BGGameLayer *gameLayer;
@property (nonatomic, weak) BGPlayer *player;
@property (nonatomic, strong) BGMenuFactory *menuFactory;
@property (nonatomic, strong) CCMenu *cardMenu;
@property (nonatomic, strong) NSMutableArray *selectedMenuItems;

@property (nonatomic) NSUInteger facedDownCardCount;    // 暗置的牌数

@end

@implementation BGHandArea

- (id)initWithPlayer:(BGPlayer *)player andCardIds:(NSArray *)cardIds
{
    if (self = [super init]) {
        _gameLayer = [BGGameLayer sharedGameLayer];
        _player = player;
        
        _handCards = [NSMutableArray array];
        _selectedCards = [NSMutableArray array];
        _selectedMenuItems = [NSMutableArray array];
        
        [self initializeHandCardsWithCardIds:cardIds];
        
        _targetPosition = ccpAdd(_player.areaPosition, ccp(_player.areaSize.width/4, 0.0f));
    }
    return self;
}

+ (id)handAreaWithPlayer:(BGPlayer *)player andCardIs:(NSArray *)cardIds
{
    return [[self alloc] initWithPlayer:player andCardIds:cardIds];
}

+ (NSArray *)playingCardsWithCardIds:(NSArray *)cardIds
{
    NSMutableArray *cards = [NSMutableArray arrayWithCapacity:cardIds.count];
    [cardIds enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        BGCard *card = [BGPlayingCard cardWithCardId:[obj integerValue]];
        [cards addObject:card];
    }];
    return cards;
}

+ (NSArray *)playingCardIdsWithCards:(NSArray *)cards
{
    NSMutableArray *cardIds = [NSMutableArray arrayWithCapacity:cards.count];
    [cards enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        [cardIds addObject:@([obj cardId])];
    }];
    return cardIds;
}

/*
 * Initialize and render hand cards
 */
- (void)initializeHandCardsWithCardIds:(NSArray *)cardIds
{
    NSArray *cards = [self.class playingCardsWithCardIds:cardIds];
    [_handCards addObjectsFromArray:cards];
    
    _menuFactory = [BGMenuFactory menuFactory];
    _cardMenu = [_menuFactory createMenuWithCards:cards];
    _cardMenu.position = CGPointZero;
    [self addChild:_cardMenu];
    _menuFactory.delegate = self;
    
    _cardWidth = [_cardMenu.children.lastObject contentSize].width;
    _cardHeight = [_cardMenu.children.lastObject contentSize].height;
    
    [self renderFigureAndSuitsOfCards:cards forMenu:_cardMenu];
    [self adjustPositionOfHandCards];
}

#pragma mark - Hand cards updating
/*
 * Update(Draw/Got/Lost) hand card with card id list
 * 
 */
- (void)updateHandCardWithCardIds:(NSArray *)cardIds
{
//  If there is faced down cards, need remove them first. Then update hand card.
    if (0 != _facedDownCardCount) {
        for (NSUInteger i = 0; i < _facedDownCardCount; i++) {
            [_cardMenu.children.lastObject removeFromParent];
        }
        _facedDownCardCount = 0;
    }
    
//  Add or Remove hand card. If the card id is contained in hand cards, need remove it.
    NSMutableArray *addedCards = [NSMutableArray array];
    NSMutableArray *removedCards = [NSMutableArray array];
    [[self.class playingCardsWithCardIds:cardIds] enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        if ([_handCards containsObject:obj]) {
            [removedCards addObject:obj];
        } else {
            [addedCards addObject:obj];
        }
    }];
    
    if (0 != addedCards.count) {
        [self addHandCardWithCards:addedCards];
    }
    if (0 != removedCards.count) {
        [self removeHandCardWithCards:removedCards];
    }
}

- (void)addHandCardWithCards:(NSArray *)cards
{
    [_handCards addObjectsFromArray:cards];
    
    [_menuFactory addMenuItemsWithCards:cards toMenu:_cardMenu];
    [self renderFigureAndSuitsOfCards:cards forMenu:_cardMenu];
    [self adjustPositionOfHandCards];
}

/*
 * Remove hand card: Is extracted/discarded or used by server(time out)
 * Set card move target positon according to different Action
 * (Move card to playing deck or other player)
 */
- (void)removeHandCardWithCards:(NSArray *)cards
{
    _cardMenu.enabled = NO;
    [self clearBuffer];
    
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
    
    [self removeHandCardsFromSelectedCards];   // Update hand card buffer
    [self moveSelectedCards];
}

/*
 * Render hand card figure and suits
 */
- (void)renderFigureAndSuitsOfCards:(NSArray *)cards forMenu:(CCMenu *)menu
{
    NSUInteger idx = 0;
    for (NSUInteger i = (menu.children.count-cards.count); i < menu.children.count; i++) {
        @try {
            CCMenuItem *menuItem = [menu.children objectAtIndex:i];
            
            CCSprite *figureSprite = [CCSprite spriteWithSpriteFrameName:[cards[idx] figureImageName]];
            figureSprite.position = ccp(_cardWidth*0.11, _cardHeight*0.92);
            [menuItem addChild:figureSprite];
            
            CCSprite *suitsSprite = [CCSprite spriteWithSpriteFrameName:[cards[idx] suitsImageName]];
            suitsSprite.position = ccp(_cardWidth*0.11, _cardHeight*0.84);
            [menuItem addChild:suitsSprite];
        }
        @catch (NSException *exception) {
            NSLog(@"Exception: %@ in %@", exception.description, NSStringFromSelector(_cmd));
        }
        
        idx++;
    }
}

/*
 * Adjust the position of each hand card
 */
- (void)adjustPositionOfHandCards
{
    NSMutableArray *actions = [NSMutableArray arrayWithCapacity:_cardMenu.children.count];
    
//  If card count is great than 6, need narrow the padding. But the first card's position unchanged.
    CGFloat cardPadding = [self cardPaddingWithCardCount:_cardMenu.children.count
                                                maxCount:COUNT_MAX_HAND_CARD_NO_OVERLAP];
    
    [[_cardMenu.children getNSArray] enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        CCMenuItem *menuItem = obj;
        if (0.0f == menuItem.position.x && 0.0f == menuItem.position.y) {
            menuItem.position = POSITION_HAND_AREA_RIGHT;
        }
        
        CGPoint cardPosition = ccpAdd(POSITION_HAND_AREA_LEFT, ccp((_cardWidth+cardPadding)*idx, 0.0f));
//      Can't exceed hand area's width(Not overlap with equipment area)
        cardPosition = (cardPosition.x < POSITION_HAND_AREA_RIGHT.x) ? cardPosition : POSITION_HAND_AREA_RIGHT;
        
        [actions addObject:[CCCallBlock actionWithBlock:^{
            BGMoveComponent *moveComp = [BGMoveComponent moveWithNode:menuItem];
            [moveComp runActionEaseMoveWithTarget:cardPosition
                                         duration:DURATION_HAND_CARD_MOVE
                                            block:^{
                                                menuItem.position = cardPosition;
                                            }];
        }]];
    }];

    [self runAction:[CCSequence actionWithArray:actions]];
}

/*
 * If card count is great than maximum count, need narrow the padding.
 */
- (CGFloat)cardPaddingWithCardCount:(NSUInteger)cardCount maxCount:(NSUInteger)maxCount
{
    return (cardCount > maxCount) ? -(_cardWidth * (cardCount-maxCount) / (cardCount-1)) : 0.0f;
}

#pragma mark - Hand cards availability
/*
 * Enable hand card by receiving available card id list from server
 */
- (void)enableHandCardWithCardIds:(NSArray *)cardIds
{
    _cardMenu.enabled = YES;
    
    NSArray *cards = [self.class playingCardsWithCardIds:cardIds];
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

/*
 * Remove hand cards for updating buffer
 */
- (void)removeHandCardsFromSelectedCards
{
    [_handCards removeObjectsInArray:_selectedCards];
    [_selectedCards removeAllObjects];
}

- (void)clearBuffer
{
    [_selectedCards removeAllObjects];
    [_selectedMenuItems removeAllObjects];
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
    CGFloat moveHeight = _player.areaSize.height*0.13;
    
    card.isSelected = !card.isSelected;
    if (card.isSelected) {
        targetPos = ccp(menuItem.position.x, cardPosY+moveHeight);
        [_selectedMenuItems addObject:menuItem];
        [_selectedCards addObject:card];
    }
    else {
        targetPos = ccp(menuItem.position.x, cardPosY);
        [_selectedMenuItems removeObject:menuItem];
        [_selectedCards removeObject:card];
    }
    
//  Move card while selecting one
    BGMoveComponent *moveComp = [BGMoveComponent moveWithNode:menuItem];
    [moveComp runActionEaseMoveWithTarget:targetPos
                                 duration:DURATION_SELECTED_CARD_MOVE
                                    block:^{
                                        menuItem.position = targetPos;

                                        // If selected cards count great than maximum, deselect and remove the first selected card.
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
                                    }];
    
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
    if (kActionChooseCardToCut == _gameLayer.action ||
        kActionChooseCardToDiscard == _gameLayer.action) {
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

#pragma mark - Hand card using
/*
 * 1. Use hand card/equip equipment with effect animation(Yes/No) and run move action
 * 2. Set selected hand card ids by self player
 */
- (void)useHandCardWithAnimation:(BOOL)isRun block:(void (^)())block
{
    _cardMenu.enabled = NO;
    
    if (isRun) {
        BGEffectComponent *effect = [BGEffectComponent effectCompWithPlayingCardEnum:[_selectedCards.lastObject cardEnum]
                                                                            andScale:SCALE_SELF_PLAYER_EFFECT];
        effect.position = POSITION_CARD_EFFECT;
        [self addChild:effect];
    }
    
    _player.selectedCardIds = [self.class playingCardIdsWithCards:_selectedCards];
    [self removeHandCardsFromSelectedCards];   // Update hand card buffer
    
    if (kActionPlayingCard == _gameLayer.action && 1 == _selectableCardCount &&
        kCardTypeEquipment == [_selectedCards.lastObject cardType]) {   // 装备牌
        [self equipEquipmentCard];
    } else {
        [self moveSelectedCards];
    }
    
    [self runActionDelayWithBlock:block];
}

- (void)moveSelectedCards
{
    [_player moveSelectedCardWithMenuItems:_selectedMenuItems
                                     block:^{
                                         [self adjustPositionOfHandCards];
                                         [_selectedMenuItems removeAllObjects];
                                     }];
}

//- (void)moveSelectedCardToTarget:(CGPoint)target isShowingOnDeck:(BOOL)isOnDeck
//{
//    NSUInteger deckCardCount = _gameLayer.playingDeck.cardCount;
//    NSUInteger selectedCount = _selectedMenuItems.count;
//    if (_gameLayer.playingDeck.isNeedClearDeck || deckCardCount+selectedCount > COUNT_MAX_DECK_CARD_NO_OVERLAP) {
//        [_gameLayer.playingDeck clearUsedCardOnDeck];
//        _gameLayer.playingDeck.isNeedClearDeck = NO;
//        deckCardCount = 0;
//    }
//    
//    NSUInteger count = (0 != deckCardCount) ? selectedCount : selectedCount-1;
//    CGFloat cardPadding = [self cardPaddingWithCardCount:selectedCount maxCount:COUNT_MAX_DECK_CARD_NO_OVERLAP];
//    __block CGPoint targetPos = ccpSub(target, ccp((deckCardCount+count)*_cardWidth/2, 0.0f));
//    
//    [_selectedMenuItems enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
//        BGMoveComponent *moveComp = [BGMoveComponent moveWithNode:obj];
//        [moveComp runActionEaseMoveWithTarget:targetPos
//                                     duration:DURATION_USED_CARD_MOVE
//                                       object:[NSValue valueWithCGPoint:targetPos]
//                                       blockO:^(id object) {
//                                           [obj removeFromParent];
//                                           [obj setPosition:[object CGPointValue]];
//                                       }];
//        
//        targetPos = ccpAdd(targetPos, ccp((_cardWidth+cardPadding)*(idx+1), 0.0f));
//    }];
//    
//    [self runActionDelayWithBlock:^{
//        [self adjustPositionOfHandCards];
//        if (isOnDeck) {
//            [_gameLayer.playingDeck updatePlayingDeckWithCardMenuItems:_selectedMenuItems];
//        }
//        [_selectedMenuItems removeAllObjects];
//    }];
//}

- (void)runActionDelayWithBlock:(void (^)())block
{
    if (block) {
        CCDelayTime *delay = [CCDelayTime actionWithDuration:DURATION_USED_CARD_MOVE];
        CCCallBlock *callBlock = [CCCallBlock actionWithBlock:block];
        [self runAction:[CCSequence actions:delay, callBlock, nil]];
    }
}

/*
 * Select a equipment card to equip
 */
- (void)equipEquipmentCard
{
    [_player.equipmentArea updateEquipmentWithCard:_selectedCards.lastObject];
    [_selectedMenuItems.lastObject removeFromParent];
    [self adjustPositionOfHandCards];
}

/*
 * Add an extracted(抽到的) hand card or equipment into hand and face down it
 */
- (void)addOneExtractedCardAndFaceDown
{
    [_menuFactory addMenuItemWithCardBackFrameName:kImagePlayingCardBack toMenu:_cardMenu];
    [self adjustPositionOfHandCards];
    _facedDownCardCount += 1;
}

/*
 * Selected cards and give them to target player
 */
- (void)giveSelectedCardsToTargetPlayerWithBlock:(void (^)())block
{
    _player.selectedCardIds = [self.class playingCardIdsWithCards:_selectedCards];
    [_player moveSelectedCardWithMenuItems:_selectedMenuItems
                                     block:^{
                                         [self adjustPositionOfHandCards];
                                         [_selectedMenuItems removeAllObjects];
                                     }];
    
    [self removeHandCardsFromSelectedCards];   // Update hand card buffer
    [self runActionDelayWithBlock:block];
}

@end
