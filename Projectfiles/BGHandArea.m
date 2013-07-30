//
//  BGHandArea.m
//  DotAHero
//
//  Created by Killua Liu on 6/14/13.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

#import "BGHandArea.h"
#import "BGGameLayer.h"
#import "BGPlayer.h"
#import "BGFileConstants.h"
#import "BGDefines.h"
#import "BGMoveComponent.h"
#import "BGCheckComponent.h"
#import "BGEffectComponent.h"
#import "BGPluginConstants.h"

@interface BGHandArea ()

@property (nonatomic, weak) BGPlayer *player;
@property (nonatomic, strong) BGMenuFactory *menuFactory;
@property (nonatomic, strong) CCMenu *cardMenu;
@property (nonatomic, strong) NSMutableArray *selectedMenuItems;

@property (nonatomic) CGFloat cardWidth;
@property (nonatomic) CGFloat cardHeight;
@property (nonatomic) NSUInteger facedDownCardCount;    // 暗置的牌数

@end

@implementation BGHandArea

- (id)initWithPlayingCardIds:(NSArray *)cardIds ofPlayer:(BGPlayer *)player
{
    if (self = [super init]) {
        _player = player;
        _canSelectCardCount = 1;
        _targetPosition = ccpAdd(_player.playerAreaPosition, ccp(_player.playerAreaSize.width/4, 0.0f));
        _selectedCards = [NSMutableArray array];
        _selectedMenuItems = [NSMutableArray array];
        _handCards = [[self.class playingCardsWithCardIds:cardIds] mutableCopy];
        
        [self initializeHandCardsWithCardIds:cardIds];
    }
    return self;
}

+ (id)handAreaWithPlayingCardIds:(NSArray *)cardIds ofPlayer:(BGPlayer *)player
{
    return [[self alloc] initWithPlayingCardIds:cardIds ofPlayer:player];
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

#pragma mark - Hand cards rendering
/*
 * Initialize hand cards while game starting
 */
- (void)initializeHandCardsWithCardIds:(NSArray *)cardIds
{
    _menuFactory = [BGMenuFactory menuFactory];
    _cardMenu = [_menuFactory createMenuWithCards:_handCards];
    _cardMenu.position = CGPointZero;
    [self addChild:_cardMenu];
    _menuFactory.delegate = self;
    
    [self renderFigureAndSuitsOfCards:_handCards forMenu:_cardMenu];
    [self adjustPositionOfHandCards];
    [self checkHandCardsUsability];
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
    CGFloat cardStartX = _player.playerAreaSize.width * 0.27;
    CGFloat cardPosY = _player.playerAreaSize.height * 0.34;
    CGFloat maxHandAreaWidth = _player.playerAreaSize.width*0.806;
    CGFloat cardPadding = 0.0f;
    
//  If card count is great than 6, need narrow the padding. But the first card's position unchanged.
    if (_cardMenu.children.count > 6) {
        cardPadding = -(_cardWidth*(_cardMenu.children.count-6) / (_cardMenu.children.count-1));
    }
    
    [[_cardMenu.children getNSArray] enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        CCMenuItem *menuItem = obj;
        menuItem.position = ccp(cardStartX + (_cardWidth+cardPadding)*idx, cardPosY);
        
//      Can't exceed hand area's width(Not overlap with equipment area)
        if (menuItem.position.x > maxHandAreaWidth) {
            menuItem.position = ccp(maxHandAreaWidth, menuItem.position.y);
        }
    }];
}

#pragma mark - Hand cards update(Draw/Discard)
/*
 * 1. Run drawing card animation
 * 2. Render drawn hand cards and update buffer
 */
- (void)addHandCardsWithCardIds:(NSArray *)cardIds
{
//  Run drawing card animation
    NSMutableArray *frameNames = [NSMutableArray arrayWithCapacity:cardIds.count];
    for (NSUInteger i = 0; i < cardIds.count; i++) {
        [frameNames addObject:kImagePlayingCardBack];
    }
    CCMenu *menu = [_menuFactory createMenuWithSpriteFrameNames:frameNames
                                             selectedFrameNames:nil
                                             disabledFrameNames:nil];
    CGFloat cardWidth = [menu.children.lastObject contentSize].width;
    menu.position = DRAW_CARD_POSITION;
    [menu alignItemsHorizontallyWithPadding:-cardWidth / 2];
    [self addChild:menu];
    
    BGMoveComponent *moveComp = [BGMoveComponent moveWithTarget:_targetPosition
                                                         ofNode:menu];
    [moveComp runActionEaseMoveWithDuration:CARD_MOVE_DURATION
                                      block:^{
                                          [menu removeFromParentAndCleanup:YES];
                                          [self renderHandCardsAndUpdateBufferWithCardIds:cardIds];
                                      }];
}

/*
 * Render drawn hand cards and update buffer
 */
- (void)renderHandCardsAndUpdateBufferWithCardIds:(NSArray *)cardIds;
{
    NSArray *cards = [self.class playingCardsWithCardIds:cardIds];
    [_menuFactory addMenuItemsWithCards:cards toMenu:_cardMenu];
    [self renderFigureAndSuitsOfCards:cards forMenu:_cardMenu];
    [self adjustPositionOfHandCards];
    [self checkHandCardsUsability];
    
    [_handCards addObjectsFromArray:cards];
}

/*
 * Add an extracted(抽到的) hand card or equipment into hand
 */
- (void)addOneExtractedCard
{
    [_menuFactory addMenuItemWithCardBackFrameName:kImagePlayingCardBack toMenu:_cardMenu];
    [self adjustPositionOfHandCards];
    _facedDownCardCount += 1;
}

/*
 * Got extracted(抽到的) hand cards or equipment
 */
- (void)gotExtractedCardsWithCardIds:(NSArray *)cardIds
{
    for (NSUInteger i = 0; i < _facedDownCardCount; i++) {
        [_cardMenu.children.lastObject removeFromParentAndCleanup:YES];
    }
    
    [self renderHandCardsAndUpdateBufferWithCardIds:cardIds];
    _facedDownCardCount = 0;
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

#pragma mark - Hand cards usability
/*
 * Check if each hand card can be used during different game state
 */
- (void)checkHandCardsUsability
{
//    BGCheckComponent *checkComp = [BGCheckComponent checkComponentWithPlayer:_player];
    
//    [_HandCards enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
//        BGPlayingCard *card = obj;
//        
////        [checkComp performSelector:NSSelectorFromString([obj cardName]) withObject:self];
////        
////        switch (card.cardEnum) {
////            case kPlayingCardNormalAttack:
////            case kPlayingCardFlameAttack:
////            case kPlayingCardChaosAttack:
////                card.canBeUsed = _player.canUseAttack;
////                break;
////                
////            case kPlayingCardEvasion:
////                card.canBeUsed = NO;
////                break;
////                
////            default:
////                break;
////        }
//        
////      If the card can't be used, need set it disable and dark color
//        CCMenuItemSprite *menuItem = (CCMenuItemSprite *)[_cardMenu getChildByTag:card.cardId];
//        menuItem.isEnabled = card.canBeUsed;
//        if (!menuItem.isEnabled) {
//            ccColor3B disabledColor = ccc3(120, 120, 120);
//            menuItem.normalImage.color = disabledColor;
//            
//            for (CCSprite *sprite in menuItem.children) {   // Make card figure and suits to gray
//                sprite.color = disabledColor;
//            }
//        }
//    }];
}

/*
 * Need disable all hand cards menu after discard is over
 */
- (void)disableAllHandCardsMenu
{
    _cardMenu.enabled = NO;
    for (CCMenuItemSprite *item in _cardMenu.children) {
        if (!item.isEnabled) {
            item.normalImage.color = ccWHITE;   // Restore to bright color
            
            for (CCSprite *sprite in item.children) {
                sprite.color = ccWHITE;
            }
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
    
    CGFloat moveHeight = _player.playerAreaSize.height*0.13;
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
//      ...TEMP...
        if (card.cardEnum == kPlayingCardElunesArrow || card.cardEnum == kPlayingCardGreed) {
            [_player.playingMenu removeFromParentAndCleanup:YES];
            [_player addPlayingMenuOfStrengthen];
        }
        
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
    if (_selectedCards.count > _canSelectCardCount) {
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
    
//  Enable playing menu okay button only if the selected cards count is not zero
    CCMenuItem *item = [_player.playingMenu.menu.children objectAtIndex:kPlayingMenuItemTagOkay];
    NSAssert(item, @"item Nil in %@", NSStringFromSelector(_cmd));
    if (_player.playerState != kPlayerStatePlaying || card.cardEnum == kPlayingCardHealingSalve) {
        item.isEnabled = (_selectedCards.count != 0);
    }

    
    
//    BOOL isEnabled = (_canBeSelectedCardCount < 1) ? YES : NO;
//    
//    for (CCMenuItem *item in _cardMenu.children) {
//        if (![item isEqual:menuItem]) {
//            item.isEnabled = isEnabled;
//        }
//    }
}

/*
 * 1. Use hand cards/equip equipment and run move action
 * 2. Set selected hand card ids by current player
 */
- (void)useHandCardsWithBlock:(void (^)())block
{
    _player.selectedCardIds = [self.class playingCardIdsWithCards:_selectedCards];
    
    if (_player.playerState == kPlayerStatePlaying && _canSelectCardCount == 1 &&
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
                                                  [_player.playingDeck showUsedHandCardsWithCardIds:_player.selectedCardIds];
                                              }
                                          }];
    }];
}

- (void)runActionDelayWithBlock:(void (^)())block
{
    if (block) {
        CCDelayTime *delay = [CCDelayTime actionWithDuration:RUN_DELAY_DURATION];
        CCCallBlock *callBlock = [CCCallBlock actionWithBlock:block];
        [self runAction:[CCSequence actions:delay, callBlock, nil]];
    }
}

- (void)equipEquipmentCard
{
    [_player.equipmentArea addEquipmentWithPlayingCard:_selectedCards.lastObject];
    [_selectedMenuItems.lastObject removeFromParentAndCleanup:YES];
    [self adjustPositionOfHandCards];
}

/*
 * Use hand cards and run effect animation
 */
- (void)useHandCardsAndRunAnimationWithBlock:(void (^)())block
{
    BGEffectComponent *effect = [BGEffectComponent effectCompWithPlayingCardEnum:[_selectedCards.lastObject cardEnum]];
    effect.position = CARD_EFFECT_POSITION;
    [self addChild:effect];
    
    [self useHandCardsWithBlock:block];
}

/*
 * Lost hand cards or equipment that are extracted by other player
 */
- (void)lostCardsWithCardIds:(NSArray *)cardIds
{
    for (CCMenuItem *item in _cardMenu.children) {
        if ([cardIds containsObject:@(item.tag)]) {
            [_selectedMenuItems addObject:item];
            NSUInteger idx = [_cardMenu.children indexOfObject:item];
            [_selectedCards addObject:_handCards[idx]];
        }
    }
    
    _player.selectedCardIds = [self.class playingCardIdsWithCards:_selectedCards];
    [self giveSelectedCardsToTargetPlayerWithBlock:NULL];
}

/*
 * Selected cards and give it to target player
 */
- (void)giveSelectedCardsToTargetPlayerWithBlock:(void (^)())block
{
    BGGameLayer *gamePlayer = [BGGameLayer sharedGameLayer];
    BGPlayer *targetPlayer = [gamePlayer playerWithName:gamePlayer.targetPlayerNames.lastObject];
    BGPlayer *player = ([_player isEqual:gamePlayer.sourcePlayer]) ? targetPlayer : gamePlayer.sourcePlayer;
    
    _player.transferedCardIds = [self.class playingCardIdsWithCards:_selectedCards];
    [self moveSelectedCardToTarget:player.position isShowingOnDeck:NO];
    [self removeHandCardsFromSelectedCards];   // Update hand card buffer
    [self runActionDelayWithBlock:block];
}

@end
