//
//  BGPlayingArea.m
//  DotAHero
//
//  Created by Killua Liu on 6/14/13.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

#import "BGPlayingArea.h"
#import "BGPlayer.h"
#import "BGPlayingCard.h"
#import "BGFileConstants.h"
#import "BGDefines.h"
#import "BGMoveComponent.h"
#import "BGCheckComponent.h"

@interface BGPlayingArea ()

@property (nonatomic, weak) BGPlayer *player;
@property (nonatomic, strong) BGMenuFactory *menuFactory;
@property (nonatomic, strong) CCMenu *cardMenu;

@property (nonatomic) CGFloat cardWidth;
@property (nonatomic) CGFloat cardHeight;

@end

@implementation BGPlayingArea

- (id)initWithPlayingCardIds:(NSArray *)cardIds ofPlayer:(BGPlayer *)player
{
    if (self = [super init]) {
        _player = player;
        _canBeSelectedCardCount = 1;
        _selectedCards = [NSMutableArray array];
        
        self.playingCards = [NSMutableArray array];
        [cardIds enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            BGCard *playingCard = [BGPlayingCard cardWithCardId:[obj integerValue]];
            [_playingCards addObject:playingCard];
        }];
        
        [self initializePlayingCardsWithCardIds:cardIds];
    }
    return self;
}

+ (id)playingAreaWithPlayingCardIds:(NSArray *)cardIds ofPlayer:(BGPlayer *)player
{
    return [[self alloc] initWithPlayingCardIds:cardIds ofPlayer:player];
}

- (void)initializePlayingCardsWithCardIds:(NSArray *)cardIds
{
    _menuFactory = [BGMenuFactory menuFactory];
    _cardMenu = [_menuFactory createMenuWithCards:_playingCards];
    _cardMenu.position = CGPointZero;
    [self addChild:_cardMenu];
    _menuFactory.delegate = self;
    
    [self renderFigureAndSuitsOfCards:_playingCards];
    [self adjustPositionOfPlayingCards];
    [self checkPlayingCardsUsability];
}

/*
 * Render playing card figure and suits
 */
- (void)renderFigureAndSuitsOfCards:(NSArray *)cards
{
    _cardWidth = [[_cardMenu.children lastObject] contentSize].width;
    _cardHeight = [[_cardMenu.children lastObject] contentSize].height;
    
    NSUInteger idx = 0;
    for (NSUInteger i = (_cardMenu.children.count-cards.count); i < _cardMenu.children.count; i++) {
        CCMenuItem *menuItem = [_cardMenu.children objectAtIndex:i];
        
        CCSprite *figureSprite = [CCSprite spriteWithSpriteFrameName:[cards[idx] figureImageName]];
        figureSprite.position = ccp(_cardWidth*0.11, _cardHeight*0.92);
        [menuItem addChild:figureSprite];
        
        CCSprite *suitsSprite = [CCSprite spriteWithSpriteFrameName:[cards[idx] suitsImageName]];
        suitsSprite.position = ccp(_cardWidth*0.11, _cardHeight*0.84);
        [menuItem addChild:suitsSprite];
        
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
    
    NSUInteger idx = 0;
    for (CCMenuItem *menuItem in _cardMenu.children) {
        menuItem.position = ccp(cardStartX + (_cardWidth+cardPadding)*idx, cardPosY);
        
//      Can't exceed playing area's width(Not overlap with equipment area)
        if (menuItem.position.x > maxPlayingAreaWidth) {
            menuItem.position = ccp(maxPlayingAreaWidth, menuItem.position.y);
        }
        idx++;
    }
}

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
    
    BGMoveComponent *moveComp = [BGMoveComponent moveWithTarget:ccp(_player.playerAreaSize.width*0.28, -_player.playerAreaSize.height*0.85)
                                                         ofNode:spritBatch];
    [moveComp runActionEaseMoveScaleWithDuration:0.7f
                                           scale:1.0f
                                           block:^{
                                               [spritBatch removeAllChildrenWithCleanup:YES];
                                               
//                                             Render drawn playing cards and update buffer
                                               NSMutableArray *cards = [NSMutableArray array];
                                               [cardIds enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                                                   BGCard *card = [BGPlayingCard cardWithCardId:[obj integerValue]];
                                                   [cards addObject:card];
                                               }];

                                               [_menuFactory addMenuItemsWithCards:cards toMenu:_cardMenu];
                                               [self renderFigureAndSuitsOfCards:cards];
                                               [self adjustPositionOfPlayingCards];
                                               [self checkPlayingCardsUsability];

                                               [_playingCards addObjectsFromArray:cards];
    }];
}

/*
 * Remove card rending on UI and update buffer
 */
- (void)removePlayingCardsWithCardIds:(NSArray *)cardIds
{
    NSMutableArray *cards = [NSMutableArray array];
    [cardIds enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        BGCard *card = [BGPlayingCard cardWithCardId:[obj integerValue]];
        [cards addObject:card];
    }];
    
    [_playingCards removeObjectsInArray:cards];
}

// Check if each playing card can be used during different game state
- (void)checkPlayingCardsUsability
{
//    BGCheckComponent *checkComp = [BGCheckComponent checkComponentWithPlayer:_player];
//    
//    [_playingCards enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
//        BGPlayingCard *card = obj;
//        
//        [checkComp performSelector:NSSelectorFromString([obj cardName]) withObject:self];
//        
//        switch (card.cardEnum) {
//            case kPlayingCardNormalAttack:
//            case kPlayingCardFlameAttack:
//            case kPlayingCardChaosAttack:
//                card.canBeUsed = _player.canUseAttack;
//                break;
//                
//            case kPlayingCardEvasion:
//                card.canBeUsed = NO;
//                break;
//                
//            default:
//                break;
//        }
//        
////      If the card can't be used, need set it disable and dark color
//        CCMenuItemSprite *menuItem = [_cardMenu.children objectAtIndex:card.cardId];
//        menuItem.isEnabled = card.canBeUsed;
//        if (!menuItem.isEnabled) {
//            ccColor3B disabledColor = ccc3(120, 120, 120);
//            menuItem.normalImage.color = disabledColor;
//            
//            for (CCSprite *sprite in menuItem.children) {   // Make card figure and suits be gray
//                sprite.color = disabledColor;
//            }
//        }
//    }];
}

// Need disable all playing cards menu after discard is over
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

#pragma mark - Menu Factory Delegate
- (void)menuItemTouched:(CCMenuItem *)menuItem
{
    NSAssert([menuItem isKindOfClass:[CCMenuItem class]], @"Not a CCMenuItem");
    CGFloat height = _player.playerAreaSize.height*0.13;
    
    BGPlayingCard *card = _playingCards[menuItem.tag];
    card.isSelected = !card.isSelected;
    
    if (card.isSelected) {
        menuItem.position = ccpAdd(menuItem.position, ccp(0.0f, height));
        [_selectedCards addObject:card];
    } else {
        menuItem.position = ccpSub(menuItem.position, ccp(0.0f, height));
        [_selectedCards removeObject:card];
    }
    
    if (_selectedCards.count > _canBeSelectedCardCount)
    {
        for (CCMenuItem *item in _cardMenu.children) {
            if (item.tag == [_selectedCards[0] cardId]) {
                [_selectedCards[0] setIsSelected:NO];
                item.position = ccpSub(item.position, ccp(0.0f, height));
                break;
            }
        }
        [_selectedCards removeObjectAtIndex:0];
    }
    
    CCMenuItem *item = [_player.playingMenu.menu.children objectAtIndex:kPlayingMenuItemTagOkay];
    item.isEnabled = (_selectedCards.count != 0);
    
//    BOOL isEnabled = (_canBeSelectedCardCount < 1) ? YES : NO;
//    
//    for (CCMenuItem *item in _cardMenu.children) {
//        if (![item isEqual:menuItem]) {
//            item.isEnabled = isEnabled;
//        }
//    }
    
//    BGEquipmentArea *equip = [BGEquipmentArea equipmentAreaWithPlayer:_player];
//    [equip addEquipmentWithCardId:27];
//    [self addChild:equip];
    
//    BGMoveComponent *moveComp = [BGMoveComponent moveWithTarget:ccp(SCREEN_WIDTH/2, SCREEN_HEIGHT*0.55)
//                                                         ofNode:menuItem];
//    [moveComp runActionEaseMoveScaleWithDuration:1.0f
//                                           scale:1.0f
//                                           block:^{
//                                               [_cardMenu removeChild:menuItem cleanup:YES];
//                                               [self adjustPositionOfPlayingCards];
//                                               
//                                               NSArray *cardIds = [NSArray arrayWithObject:@(menuItem.tag)];
//                                               [self removePlayingCardsWithCardIds:cardIds];
//                                               
//    CCSpriteFrameCache *spriteFrameCache = [CCSpriteFrameCache sharedSpriteFrameCache];
//    [spriteFrameCache addSpriteFramesWithFile:@"CardEffect.plist"];
//
//    CCSprite *sprite = [CCSprite spriteWithSpriteFrameName:@"NormalAttack0.png"];
////    CCSprite *sprite = [CCSprite spriteWithSpriteFrameName:@"HealingSalve0.png"];
//    sprite.position = [CCDirector sharedDirector].screenCenter;
//
//    CCAnimation *animation = [CCAnimation animationWithFrames:@"NormalAttack" frameCount:9 delay:0.08f];
//    CCAnimate *animate = [CCAnimate actionWithAnimation:animation];
//    [sprite runAction:animate];
//    [self addChild:sprite];
//                                           }];
}

@end
