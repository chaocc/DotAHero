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

@property (nonatomic) CGFloat cardWidth;
@property (nonatomic) CGFloat cardHeight;
@property (nonatomic) NSUInteger facedDownCardCount;    // 暗置的牌数

@end

@implementation BGHandArea

- (id)initWithPlayer:(BGPlayer *)player
{
    if (self = [super init]) {
        _gameLayer = [BGGameLayer sharedGameLayer];
        _player = player;
        _targetPosition = ccpAdd(_player.areaPosition, ccp(_player.areaSize.width/4, 0.0f));
        
        _handCards = [NSMutableArray array];
        _selectedCards = [NSMutableArray array];
        _selectedMenuItems = [NSMutableArray array];
        
        _menuFactory = [BGMenuFactory menuFactory];
        _cardMenu = [CCMenu menuWithArray:nil];
        _cardMenu.position = CGPointZero;
        [self addChild:_cardMenu];
        _menuFactory.delegate = self;
    }
    return self;
}

+ (id)handAreaWithPlayer:(BGPlayer *)player
{
    return [[self alloc] initWithPlayer:player];
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

#pragma mark - Hand cards updating
/*
 * Update(Draw/Got/Lost) hand card with card id list
 * 
 */
- (void)updateHandCardWithCardIds:(NSArray *)cardIds
{
//  If there is faced down cards, need remove them first. Then update hand card.
    if (_facedDownCardCount != 0) {
        for (NSUInteger i = 0; i < _facedDownCardCount; i++) {
            [_cardMenu.children.lastObject removeFromParentAndCleanup:YES];
        }
        _facedDownCardCount = 0;
    }
    
//  Add or Remove hand card. If the card id is contained in hand cards, need remove it.
    NSArray *cards = [self.class playingCardsWithCardIds:cardIds];
    NSMutableArray *addedCards = [NSMutableArray array];
    NSMutableArray *removedCards = [NSMutableArray array];
    [cards enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        if ([_handCards containsObject:obj]) {
            [removedCards addObject:obj];
        } else {
            [addedCards addObject:obj];
        }
    }];
    
    if (addedCards.count != 0) {
        [self addHandCardWithCards:addedCards];
    }
    if (removedCards.count != 0) {
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
 * Remove hand card: Is extracted or discarded
 * Set card move target positon according to different Action
 * (Move card to playing deck or other player)
 */
- (void)removeHandCardWithCards:(NSArray *)cards
{
    [cards enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        for (CCMenuItem *item in _cardMenu.children) {
            if ([obj cardId] == item.tag) {
                [_selectedMenuItems addObject:item];
//                NSUInteger idx = [_cardMenu.children indexOfObject:item];
//                [_selectedCards addObject:_handCards[idx]];
                break;
            }
        }
    }];
    
    CGPoint targetPos;
    if (_player.action == kActionUpdatePlayerHand) {
        targetPos = USED_CARD_POSITION;
    } else {
        BGPlayer *targetPlayer = [_gameLayer playerWithName:_gameLayer.targetPlayerNames.lastObject];
        BGPlayer *player = ([_player isEqual:_gameLayer.sourcePlayer]) ? targetPlayer : _gameLayer.sourcePlayer;
        targetPos = player.position;
    }
    [self moveSelectedCardToTarget:targetPos isShowingOnDeck:NO];
    [self removeHandCardsFromSelectedCards];   // Update hand card buffer
}

/*
 * Render hand card figure and suits
 */
- (void)renderFigureAndSuitsOfCards:(NSArray *)cards forMenu:(CCMenu *)menu
{
    _cardWidth = [[menu.children lastObject] contentSize].width;
    _cardHeight = [[menu.children lastObject] contentSize].height;
    
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
    CGFloat cardStartX = _player.areaSize.width * 0.27;
    CGFloat cardPosY = _player.areaSize.height * 0.34;
    CGFloat maxHandAreaWidth = _player.areaSize.width*0.806;
    CGFloat cardPadding = 0.0f;
    NSMutableArray *actions = [NSMutableArray arrayWithCapacity:_cardMenu.children.count];
    
//  If card count is great than 6, need narrow the padding. But the first card's position unchanged.
    if (_cardMenu.children.count > 6) {
        cardPadding = -(_cardWidth*(_cardMenu.children.count-6) / (_cardMenu.children.count-1));
    }
    
    [[_cardMenu.children getNSArray] enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        CCMenuItem *menuItem = obj;
        if (menuItem.position.x == 0.0f && menuItem.position.y == 0.0f) {
            menuItem.position = ccp(maxHandAreaWidth, cardPosY);
        }
        
        CGPoint cardPosition = ccp(cardStartX + (_cardWidth+cardPadding)*idx, cardPosY);
//      Can't exceed hand area's width(Not overlap with equipment area)
        if (cardPosition.x > maxHandAreaWidth) {
            cardPosition = ccp(maxHandAreaWidth, menuItem.position.y);
        }
        
        [actions addObject:[CCCallBlock actionWithBlock:^{
            BGMoveComponent *moveComp = [BGMoveComponent moveWithTarget:cardPosition
                                                                 ofNode:menuItem];
            [moveComp runActionEaseMoveWithDuration:0.2f
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
    
    [_handCards enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        BGPlayingCard *card = obj;
        CCMenuItemSprite *menuItem = (CCMenuItemSprite *)[_cardMenu getChildByTag:card.cardId];
//      Check if cardId is contained in available card id list
        menuItem.isEnabled = ([cardIds containsObject:@(card.cardId)]);
        
        ccColor3B cardColor;
        if (menuItem.isEnabled) {
            cardColor = ccWHITE;                // Restore to bright color
        } else {
            cardColor = ccc3(120, 120, 120);    // Make card figure and suits to gray
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
 * Remove hand cards for updating buffer
 */
- (void)removeHandCardsFromSelectedCards
{
    [_handCards removeObjectsInArray:_selectedCards];
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
    
    CGFloat moveHeight = _player.areaSize.height*0.13;
    BGPlayingCard *card = nil;
    
    @try {
        NSUInteger idx = [_cardMenu.children indexOfObject:menuItem];
        card = _handCards[idx];
        NSAssert(card, @"card Nil in %@", NSStringFromSelector(_cmd));
    }
    @catch (NSException *exception) {
        NSLog(@"Catched Exception: %@", exception.description);
    }
    
//  Need move up/down while a card is selected/deselected
    card.isSelected = !card.isSelected;
    if (card.isSelected) {
        menuItem.position = ccpAdd(menuItem.position, ccp(0.0f, moveHeight));
        [_selectedMenuItems addObject:menuItem];
        [_selectedCards addObject:card];
    }
    else {
        menuItem.position = ccpSub(menuItem.position, ccp(0.0f, moveHeight));
        [_selectedMenuItems removeObject:menuItem];
        [_selectedCards removeObject:card];
    }
    
//  If selected cards count great than maximum, deselect and remove the first selected card.
    if (_selectedCards.count > _selectableCardCount) {
        @try {
            for (CCMenuItem *item in _cardMenu.children) {
                if (item.tag == [_selectedCards[0] cardId]) {
                    [_selectedCards[0] setIsSelected:NO];
                    item.position = ccpSub(item.position, ccp(0.0f, moveHeight));
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
            [_player.playingMenu removeFromParentAndCleanup:YES];
            [_player addPlayingMenu];
        }
        return;
    }

//  Card is selected
    if (_player.action == kActionChooseCardToCompare ||
        _player.action == kActionChooseCardToDiscard) {
        okayMenu.isEnabled = YES;
        return;
    }

    if (card.canBeStrengthened && _player.heroArea.angerPoint > 0) {
        [_player.playingMenu removeFromParentAndCleanup:YES];
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
 * 2. Set selected hand card ids by current player
 */
- (void)useHandCardWithAnimation:(BOOL)isRun block:(void (^)())block
{
    if (isRun) {
        BGEffectComponent *effect = [BGEffectComponent effectCompWithPlayingCardEnum:[_selectedCards.lastObject cardEnum]
                                                                            andScale:0.5f];
        effect.position = CARD_EFFECT_POSITION;
        [self addChild:effect];
    }
    
    _player.selectedCardIds = [self.class playingCardIdsWithCards:_selectedCards];
    
    if (_player.action == kActionPlayingCard && _selectableCardCount == 1 &&
        [_selectedCards.lastObject cardType] == kCardTypeEquipment) {   // 装备牌
        [self equipEquipmentCard];
    } else {
        [self moveSelectedCardToTarget:USED_CARD_POSITION isShowingOnDeck:YES];
    }
    
    [self removeHandCardsFromSelectedCards];   // Update hand card buffer
    [self runActionDelayWithBlock:block];
}

- (void)moveSelectedCardToTarget:(CGPoint)target isShowingOnDeck:(BOOL)isOnDeck
{
    [_selectedMenuItems enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        BGMoveComponent *moveComp = [BGMoveComponent moveWithTarget:target
                                                             ofNode:obj];
        [moveComp runActionEaseMoveWithDuration:CARD_MOVE_DURATION
                                          block:^{
                                              [obj removeFromParentAndCleanup:YES];
                                              [self adjustPositionOfHandCards];
                                              if (isOnDeck) {
                                                  [_gameLayer.playingDeck updatePlayingDeckWithCardIds:_player.selectedCardIds];
                                              }
                                          }];
    }];
}

- (void)runActionDelayWithBlock:(void (^)())block
{
    if (block) {
        CCDelayTime *delay = [CCDelayTime actionWithDuration:CARD_MOVE_DURATION];
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
    [_selectedMenuItems.lastObject removeFromParentAndCleanup:YES];
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
    BGPlayer *targetPlayer = [_gameLayer playerWithName:_gameLayer.targetPlayerNames.lastObject];
    BGPlayer *player = ([_player isEqual:_gameLayer.sourcePlayer]) ? targetPlayer : _gameLayer.sourcePlayer;

    _player.selectedCardIds = [self.class playingCardIdsWithCards:_selectedCards];
    [self moveSelectedCardToTarget:player.position isShowingOnDeck:NO];
    
    [self removeHandCardsFromSelectedCards];   // Update hand card buffer
    [self runActionDelayWithBlock:block];
}

@end
