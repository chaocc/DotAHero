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
        _targetPosition = ccp(_player.playerAreaSize.width*0.28, -_player.playerAreaSize.height*0.85);
        _selectedCards = [NSMutableArray array];
        _selectedMenuItems = [NSMutableArray array];
        _playingCards = [[self.class playingCardsWithCardIds:cardIds] mutableCopy];
        
        [self initializePlayingCardsWithCardIds:cardIds];
    }
    return self;
}

+ (id)handAreaWithPlayingCardIds:(NSArray *)cardIds ofPlayer:(BGPlayer *)player
{
    return [[self alloc] initWithPlayingCardIds:cardIds ofPlayer:player];
}

+ (NSArray *)playingCardsWithCardIds:(NSArray *)cardIds
{
    NSMutableArray *cards = [NSMutableArray array];
    [cardIds enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        BGCard *card = [BGPlayingCard cardWithCardId:[obj integerValue]];
        [cards addObject:card];
    }];
    return cards;
}

+ (NSArray *)playingCardIdsWithCards:(NSArray *)cards
{
    NSMutableArray *cardIds = [NSMutableArray array];
    [cards enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        [cardIds addObject:@([obj cardId])];
    }];
    return cardIds;
}

#pragma mark - Playing cards rendering
/*
 * Initialize playing cards while game starting
 */
- (void)initializePlayingCardsWithCardIds:(NSArray *)cardIds
{
    _menuFactory = [BGMenuFactory menuFactory];
    _cardMenu = [_menuFactory createMenuWithCards:_playingCards];
    _cardMenu.position = CGPointZero;
    [self addChild:_cardMenu];
    _menuFactory.delegate = self;
    
    [self renderFigureAndSuitsOfCards:_playingCards forMenu:_cardMenu];
    [self adjustPositionOfPlayingCards];
    [self checkPlayingCardsUsability];
}

/*
 * Render playing card figure and suits
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
 * Adjust the position of each playing card
 */
- (void)adjustPositionOfPlayingCards
{
    CGFloat cardStartX = _player.playerAreaSize.width * 0.27;
    CGFloat cardPosY = _player.playerAreaSize.height * 0.34;
    CGFloat maxPlayingAreaWidth = _player.playerAreaSize.width*0.806;
    CGFloat cardPadding = 0.0f;
    
//  If card count is great than 6, need narrow the padding. But the first card's position unchanged.
    if (_cardMenu.children.count > 6) {
        cardPadding = -(_cardWidth*(_cardMenu.children.count-6) / (_cardMenu.children.count-1));
    }
    
    [[_cardMenu.children getNSArray] enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        CCMenuItem *menuItem = obj;
        menuItem.position = ccp(cardStartX + (_cardWidth+cardPadding)*idx, cardPosY);
        
//      Can't exceed playing area's width(Not overlap with equipment area)
        if (menuItem.position.x > maxPlayingAreaWidth) {
            menuItem.position = ccp(maxPlayingAreaWidth, menuItem.position.y);
        }
    }];
}

#pragma mark - Playing cards update(Draw/Discard)
/*
 * 1. Run drawing card animation
 * 2. Render drawn playing cards and update buffer
 */
- (void)addPlayingCardsWithCardIds:(NSArray *)cardIds
{
//  Run drawing card animation
    CCSpriteBatchNode *spritBatch = [CCSpriteBatchNode batchNodeWithFile:kZlibPlayingCard];
    [self addChild:spritBatch];
    
    CGFloat cardWidth = [[CCSprite spriteWithSpriteFrameName:kImagePlayingCardBack] contentSize].width;
    CGFloat padding = cardWidth / 2;
    CGFloat startPosX = (SCREEN_WIDTH - (cardWidth-padding)*(cardIds.count-1)) / 2;
    for (NSUInteger i = 0; i < cardIds.count; i++) {
        CCSprite *sprite = [CCSprite spriteWithSpriteFrameName:kImagePlayingCardBack];
        sprite.position = ccp(startPosX + padding*i, SCREEN_HEIGHT*0.55);
        [spritBatch addChild:sprite];
    }
    
    BGMoveComponent *moveComp = [BGMoveComponent moveWithTarget:_targetPosition
                                                         ofNode:spritBatch];
    [moveComp runActionEaseMoveScaleWithDuration:0.7f
                                           scale:1.0f
                                           block:^{
                                               [spritBatch removeFromParentAndCleanup:YES];
                                               [self renderPlayingCardsAndUpdateBufferWithCardIds:cardIds];
    }];
}

/*
 * Render drawn playing cards and update buffer
 */
- (void)renderPlayingCardsAndUpdateBufferWithCardIds:(NSArray *)cardIds;
{
    NSArray *cards = [self.class playingCardsWithCardIds:cardIds];
    
    [_menuFactory addMenuItemsWithCards:cards toMenu:_cardMenu];
    [self renderFigureAndSuitsOfCards:cards forMenu:_cardMenu];
    [self adjustPositionOfPlayingCards];
    [self checkPlayingCardsUsability];
    
    [_playingCards addObjectsFromArray:cards];
}

/*
 * Add a faced down(暗置) playing card into hand
 */
- (void)addAFacedDownPlayingCard
{
    [_menuFactory addMenuItemWithCardBackFrameName:kImagePlayingCardBack toMenu:_cardMenu];
    [self adjustPositionOfPlayingCards];
    _facedDownCardCount += 1;
}

/*
 * Got all faced down playing cards
 */
- (void)gotAllFacedDownPlayingCardsWithCardIds:(NSArray *)cardIds
{
    for (NSUInteger i = 0; i < _facedDownCardCount; i++) {
        [_cardMenu.children.lastObject removeFromParentAndCleanup:YES];
    }
    
    [self renderPlayingCardsAndUpdateBufferWithCardIds:cardIds];
}

/*
 * Remove playing cards for updating buffer
 */
- (void)removePlayingCards
{   
    [_playingCards removeObjectsInArray:_selectedCards];
    [_selectedCards removeAllObjects];
    [_selectedMenuItems removeAllObjects];
}

#pragma mark - Playing cards usability
/*
 * Check if each playing card can be used during different game state
 */
- (void)checkPlayingCardsUsability
{
//    BGCheckComponent *checkComp = [BGCheckComponent checkComponentWithPlayer:_player];
    
//    [_playingCards enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
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
 * Need disable all playing cards menu after discard is over
 */
- (void)disableAllPlayingCardsMenu
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

#pragma mark - Playing cards selection
/*
 * Menu delegate method is called while selecting a playing card
 */
- (void)menuItemTouched:(CCMenuItem *)menuItem
{
    NSAssert(_selectedCards, @"_selectedCards Nil in %@", NSStringFromSelector(_cmd));
    NSAssert(_selectedMenuItems, @"_selectedMenuItems Nil in %@", NSStringFromSelector(_cmd));
    
    CGFloat moveHeight = _player.playerAreaSize.height*0.13;
    BGPlayingCard *card = nil;
    
    @try {
        NSUInteger idx = [_cardMenu.children indexOfObject:menuItem];
        card = _playingCards[idx];
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
    } else {
        menuItem.position = ccpSub(menuItem.position, ccp(0.0f, moveHeight));
        [_selectedMenuItems removeObject:menuItem];
        [_selectedCards removeObject:card];
    }
    
//  If selected cards count great than maximum, deselect and remove the first selected card.
    if (_selectedCards.count > _canSelectCardCount)
    {
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
 * 1. Use playing cards and run move action
 * 2. Set selected playing card ids by current player
 */
- (void)usePlayingCards
{
    CGFloat menuWidth = [_selectedMenuItems.lastObject contentSize].width;
    CGFloat startX = (SCREEN_WIDTH - menuWidth*(_selectedMenuItems.count - 1)) / 2;
    
    [_selectedMenuItems enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        [self movePlayingCardWithMenuItem:obj
                                 toTarget:ccp(startX + menuWidth*idx, SCREEN_HEIGHT*0.55)];
    }];
    
    _player.selectedCardIds = [self.class playingCardIdsWithCards:_selectedCards];
    [self removePlayingCards];   // Update playing card buffer
}

- (void)movePlayingCardWithMenuItem:(CCMenuItem *)menuItem toTarget:(CGPoint)target
{
    BGMoveComponent *moveComp = [BGMoveComponent moveWithTarget:target
                                                         ofNode:menuItem];
    [moveComp runActionEaseMoveScaleWithDuration:0.5f
                                           scale:1.0f
                                           block:^{
                                               [menuItem removeFromParentAndCleanup:YES];
                                               [self adjustPositionOfPlayingCards];
                                           }];
}

/*
 * Use playing cards and run effect animation
 */
- (void)usePlayingCardsAndRunAnimation
{
    BGEffectComponent *effect = [BGEffectComponent effectCompWithPlayingCardEnum:[_selectedCards.lastObject cardEnum]];
    [self addChild:effect];
    
    [self usePlayingCards];
}

/*
 * Lost playing cards that are extracted by other player
 */
- (void)lostPlayingCardsWithCardIds:(NSArray *)cardIds
{
    for (CCMenuItem *item in _cardMenu.children) {
        if ([cardIds containsObject:@(item.tag)]) {
            [_selectedMenuItems addObject:item];
            NSUInteger idx = [_cardMenu.children indexOfObject:item];
            [_selectedCards addObject:_playingCards[idx]];
        }
    }
    
    BGGameLayer *gamePlayer = [BGGameLayer sharedGameLayer];
    [_selectedMenuItems enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        [self movePlayingCardWithMenuItem:obj
                                 toTarget:[gamePlayer playerWithName:gamePlayer.targetPlayerNames.lastObject].position];
    }];
}

@end
