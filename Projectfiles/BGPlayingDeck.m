//
//  BGPlayingDeck.m
//  DotAHero
//
//  Created by Killua Liu on 7/20/13.
//
//

#import "BGPlayingDeck.h"
#import "BGClient.h"
#import "BGGameLayer.h"
#import "BGHandArea.h"
#import "BGDefines.h"
#import "BGFileConstants.h"
#import "BGMoveComponent.h"

@interface BGPlayingDeck ()

@property (nonatomic, weak) BGGameLayer *gameLayer;
@property (nonatomic, weak) BGPlayer *player;
@property (nonatomic, weak) BGPlayer *targetPlayer;

@property (nonatomic, strong) BGMenuFactory *menuFactory;
@property (nonatomic, strong) CCMenu *cardMenu;     // 使用/弃置的牌
@property (nonatomic, strong) CCMenu *heroMenu;     // 待选的英雄
@property (nonatomic, strong) CCMenu *handMenu;     // 目标手牌
@property (nonatomic, strong) CCMenu *equipMenu;    // 目标装备

@end

@implementation BGPlayingDeck

static BGPlayingDeck *instanceOfPlayingDeck = nil;

+ (id)sharedPlayingDeck
{
    if (!instanceOfPlayingDeck) {
        instanceOfPlayingDeck = [[self alloc] init];
    }
	return instanceOfPlayingDeck;
}

- (id)init
{
    if (self = [super init]) {
        _gameLayer = [BGGameLayer sharedGameLayer];
        _player = _gameLayer.selfPlayer;
        
        _menuFactory = [BGMenuFactory menuFactory];
        _cardMenu = [CCMenu menuWithItems:nil];
        _cardMenu.position = CGPointZero;
        _cardMenu.enabled = NO;
        [self addChild:_cardMenu];
        _menuFactory.delegate = self;
    }
    return self;
}

+ (NSArray *)heroCardsWithHeroIds:(NSArray *)heroIds
{
    NSMutableArray *heroCards = [NSMutableArray arrayWithCapacity:heroIds.count];
    [heroIds enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        BGCard *heroCard = [BGHeroCard cardWithCardId:[obj integerValue]];
        [heroCards addObject:heroCard];
    }];
    
    return heroCards;
}

- (NSUInteger)cardCount
{
    return _cardMenu.children.count;
}

#pragma mark - Deck updating
/*
 * Update deck with to be selected hero cards
 */
- (void)updatePlayingDeckWithHeroIds:(NSArray *)heroIds
{
    [self runActionDelayWithDuration:DURATION_HERO_SEL_SHOW_DELAY
                           WithBlock:^{
                               _heroMenu = [_menuFactory createMenuWithCards:[self.class heroCardsWithHeroIds:heroIds]];
                               _heroMenu.position = POSITION_TO_BE_SELECTED_HERO;
                               [_heroMenu alignItemsHorizontally];
                               [self addChild:_heroMenu];
                               [_heroMenu runAction:[CCFadeIn actionWithDuration:DURATION_HERO_SEL_FADE_IN]];
                               
                               [_player addProgressBarWithPosition:POSITION_HERO_SEL_PROGRESS_BAR
                                                             block:^{
                                                                 [_heroMenu removeFromParent];
                                                                 [_player removeProgressBar];
                                                             }];
                           }];
}

/*
 * Update deck with used/discarded hand cards. Clear deck after one card effect was resolved(结算)
 */
- (void)updatePlayingDeckWithCardIds:(NSArray *)cardIds
{
    switch (_gameLayer.action) {
        case kActionUpdateDeckCuttedCard:   // Show cutted card on deck
            [_gameLayer setHandCardCountForOtherPlayers];
            [_gameLayer removeProgressBarForOtherPlayers];
//            [self showCuttedCardOnDeckWithCardIds:cardIds];
            break;
        
        case kActionUpdateDeckUsedCard:     // Show used card on deck
//            [self showUsedCardOnDeckWithCardIds:cardIds];
            break;
            
        case kActionUpdateDeckAssigning:    // Show X cards of top pile(牌堆顶) on deck
//          更新桌面: 能量转移
            break;
            
        default:
            break;
    }
}

/*
 * Update deck with used/discarded hand card menu items. Clear deck after one card effect was resolved(结算)
 */
- (void)updatePlayingDeckWithCardMenuItems:(NSArray *)menuItems
{   
    CGPoint deltaPos = (0 != _cardMenu.children.count) ? ccp(menuItems.count*_player.handArea.cardWidth/2, 0.0f) : CGPointZero;
    
    [menuItems enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        [_cardMenu addChild:obj z:_cardMenu.children.count];
    }];
    
    if ([self isNeedAdjustUsedCardPosition]) {
        [[_cardMenu.children getNSArray] enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            CGPoint targetPos = ccpAdd([obj position], deltaPos);
            BGMoveComponent *moveComp = [BGMoveComponent moveWithNode:obj];
            [moveComp runActionEaseMoveWithTarget:targetPos
                                         duration:DURATION_USED_CARD_MOVE
                                            block:NULL];
        }];
    }
}

- (BOOL)isNeedAdjustUsedCardPosition
{
    return (kActionChooseCardToCut != _gameLayer.action &&
            kActionUpdateDeckCuttedCard != _gameLayer.action);
}

- (void)showUsedCardOnDeckWithCardIds:(NSArray *)cardIds
{   
    NSArray *cards = [BGHandArea playingCardsWithCardIds:cardIds];
    CCMenu *menu = [CCMenu menuWithArray:nil];
    [_menuFactory addMenuItemsWithCards:cards toMenu:menu];
    menu.position = _gameLayer.currPlayer.areaPosition;
    [self addChild:menu];
    [_player.handArea renderFigureAndSuitsOfCards:cards forMenu:_cardMenu];
    
    NSArray *menuItems = [menu.children getNSArray];
    [_player moveSelectedCardWithMenuItems:menuItems
                                     block:^{
                                         [menu removeFromParent];
                                     }];
}

- (void)showCuttedCardOnDeckWithCardIds:(NSArray *)cardIds
{
    [self runActionDelayWithDuration:DURATION_USED_CARD_MOVE
                           WithBlock:^{
                               [self showUsedCardOnDeckWithCardIds:[self arrangedCuttedCardIdsWithIds:cardIds]];
                               NSUInteger cardCount = cardIds.count;
                               if (cardCount <= kPlayerCountFive) {
                                   return;
                               }
                               
                               CGFloat cardWidth = _player.handArea.cardWidth;
                               CGFloat cardHeight = _player.handArea.cardHeight;
                               CGFloat cardPadding = PADDING_CUTTED_CARD;
                               CGFloat cardStartX = POSITION_DECK_AREA_LEFT.x;
                               CGFloat cardStartY = POSITION_DECK_AREA_LEFT.y;
                               NSUInteger countOfEachRow = ceil(cardCount/2.0);
                               
                               cardStartX = (kPlayerCountSix == cardCount) ? cardStartX+cardWidth/2 : POSITION_DECK_AREA_LEFT.x;
                               cardStartY = ([_gameLayer.currPlayerName isEqualToString:_player.playerName]) ? SCREEN_HEIGHT * 0.7 : cardStartY;
                               
                               [[_cardMenu.children getNSArray] enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                                   CGFloat delta = (idx < countOfEachRow) ? (cardWidth+cardPadding)*idx : (cardWidth+cardPadding)*(idx-countOfEachRow);
                                   CGFloat cardPosY = (idx < countOfEachRow) ? cardStartY : cardStartY-cardHeight-cardPadding;
                                   
                                   [obj setPosition:ccp(cardStartX + delta, cardPosY)];
                               }];
                           }];
}

- (NSArray *)arrangedCuttedCardIdsWithIds:(NSArray *)cardIds
{
    NSMutableArray *mutableCardIds = [cardIds mutableCopy];
    NSMutableIndexSet *idxSet = [NSMutableIndexSet indexSet];
    NSUInteger idx = 0;
    
    for (id obj in cardIds) {
        if ([obj integerValue] == _player.cuttedCardId) {
            [mutableCardIds removeObjectsAtIndexes:idxSet];
            [mutableCardIds addObjectsFromArray:[mutableCardIds objectsAtIndexes:idxSet]];
            cardIds = mutableCardIds;
            break;
        }
        [idxSet addIndex:idx]; idx++;
    }
    
    return cardIds;
}

- (void)runActionDelayWithDuration:(ccTime)time WithBlock:(void (^)())block
{
    if (block) {
        CCDelayTime *delay = [CCDelayTime actionWithDuration:time];
        CCCallBlock *callBlock = [CCCallBlock actionWithBlock:block];
        [self runAction:[CCSequence actions:delay, callBlock, nil]];
    }
}

/*
 * Update deck with hand card count and equipment card
 * Faced down(暗置) all hand cards on the deck for being extracted(比如贪婪)
 */
- (void)updatePlayingDeckWithCardCount:(NSUInteger)count equipmentIds:(NSArray *)cardIds
{
    if (0 != count) {        
//      If card count is great than 5, need narrow the padding.
        CGFloat cardPadding = [_player.handArea cardPaddingWithCardCount:count maxCount:COUNT_MAX_DECK_CARD_NO_OVERLAP];
        
        NSMutableArray *frameNames = [NSMutableArray arrayWithCapacity:count];
        for (NSUInteger i = 0 ; i < count; i++) {
            [frameNames addObject:kImagePlayingCardBack];
        }
        
        _handMenu = [_menuFactory createMenuWithSpriteFrameNames:frameNames
                                              selectedFrameNames:nil
                                              disabledFrameNames:nil];
        _handMenu.position = POSITION_EXTRACTED_HAND_CARD;
        [self addChild:_handMenu];
    }
    
//  Add equipment cards of target player on the deck if equipped
    if (0 != cardIds.count) {
        _equipMenu = [_menuFactory createMenuWithCards:_player.equipmentArea.equipmentCards];
        _equipMenu.position = POSITION_EXTRACTED_EQUIPMENT;
        [self addChild:_equipMenu];
    }
}

- (void)clearUsedCardOnDeck
{
    CCFadeOut *fadeOut = [CCFadeOut actionWithDuration:DURATION_USED_CARD_FADE_OUT];
    CCCallBlock *block = [CCCallBlock actionWithBlock:^{
        [_cardMenu removeAllChildren];
    }];
    
    [_cardMenu runAction:[CCSequence actions:fadeOut, block, nil]];
}

//[[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"PlayingCard.plist"];
//CCSprite *cardBack = [CCSprite spriteWithSpriteFrameName:@"PlayingCardBack.png"];
//cardBack.position = [CCDirector sharedDirector].screenCenter;
//[self addChild:cardBack];
//
//CCRotateTo *rotate1 = [CCRotateTo actionWithDuration:1.5f angleX:0.0f angleY:-90.0f];
//
//CCCallBlock *block = [CCCallBlock actionWithBlock:^{
//    CCMenuItem *menuItem = [CCMenuItemSprite itemWithNormalSprite:[CCSprite spriteWithSpriteFrameName:@"HealingSalve.png"]
//                                                   selectedSprite:nil];
//    CCMenu *menu = [CCMenu menuWithItems:menuItem, nil];
//    menu.position = cardBack.position;
//    [self addChild:menu];
//}];
//
//CCRotateBy *rotate2 = [CCRotateBy actionWithDuration:1.5f angleX:0.0f angleY:90.0f];
//
//[self runAction:[CCSequence actions:rotate1, block, rotate2, nil]];

#pragma mark - MenuItem touching
/*
 * Menu delegate method is called while selecting a hero/hand card
 */
- (void)menuItemTouched:(CCMenuItem *)menuItem
{
    if ([menuItem.parent isEqual:_heroMenu]) {          // 待选的英雄
        _player.selectedHeroId = menuItem.tag;
        [self selectHeroByTouchingMenuItem:menuItem];
        return;
    }
    
    if ([menuItem.parent isEqual:_handMenu]) {          // 目标手牌
        NSUInteger idx = _targetPlayer.handCardCount - menuItem.tag - 1;
        [_player.selectedCardIdxes addObject:@(idx)];
    }
    else if ([menuItem.parent isEqual:_equipMenu]) {    // 目标装备
        _player.canExtractCardCount = 1;
        _player.selectedCardIds = [NSArray arrayWithObject:@(menuItem.tag)];
    } else {
        return;
    }
    [self extractCardByTouchMenuItem:menuItem];
}

/*
 * Select a hero card by touching menu item
 */
- (void)selectHeroByTouchingMenuItem:(CCMenuItem *)menuItem
{
    for (CCMenuItem *item in menuItem.parent.children) {
        if (![item isEqual:menuItem]) {
            item.visible = NO;
        }
    }
    [_player removeProgressBar];
    
    BGMoveComponent *moveComp = [BGMoveComponent moveWithNode:menuItem];
    [moveComp runActionEaseMoveScaleWithTarget:ccp(-SCREEN_WIDTH*0.4, -SCREEN_HEIGHT*0.4)
                                      duration:DURATION_SELECTED_HERO_MOVE
                                         scale:SCALE_SELECTED_HERO
                                         block:^{
                                             [menuItem.parent removeFromParent];
                                             [[BGClient sharedClient] sendChooseHeroIdRequest];
                                         }];
}

/*
 * Extract(抽取) a hand card of target player by touching card menu item
 * If only have one hand card, end directly after extracted.
 */
- (void)extractCardByTouchMenuItem:(CCMenuItem *)menuItem
{
//    CGPoint targetPos = ccp(_player.playerAreaSize.width*0.31, -_player.playerAreaSize.height*0.88);
    CGPoint targetPos = _player.handArea.targetPosition;
    BGMoveComponent *moveComp = [BGMoveComponent moveWithNode:menuItem];
    [moveComp runActionEaseMoveWithTarget:targetPos
                                 duration:DURATION_USED_CARD_MOVE
                                    block:^{
                                        [menuItem removeFromParent];
                                        
                                        [_player.handArea addOneExtractedCardAndFaceDown];
                                      
                                        // Extracted card count can't great than all hand card count
                                        if ((_player.selectedCardIdxes.count == _targetPlayer.handCardCount) ||
                                            (_player.selectedCardIdxes.count == _player.canExtractCardCount))
                                        {
                                            [_handMenu removeFromParent];
                                            [_equipMenu removeFromParent];
                                            [[BGClient sharedClient] sendChooseCardRequest];  // Send plugin reqeust
                                        }
                                    }];
}

@end
