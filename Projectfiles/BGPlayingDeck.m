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
#import "BGActionComponent.h"

@interface BGPlayingDeck ()

@property (nonatomic, weak) BGGameLayer *gameLayer;
@property (nonatomic, weak) BGPlayer *player;
@property (nonatomic, weak) BGPlayer *targetPlayer;

@property (nonatomic, strong) BGActionComponent *actionComp;
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
        _actionComp = [BGActionComponent actionComponentWithNode:self];
        
        _menuFactory = [BGMenuFactory menuFactory];
        _cardMenu = [CCMenu menuWithArray:nil];
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

- (NSUInteger)allCardCount
{
    return _cardMenu.children.count;
}

- (BOOL)isNeedClearByAddingCardCount:(NSUInteger)count
{
    return (kGameStatePlaying == _gameLayer.state || (count+_existingCardCount) > COUNT_MAX_DECK_CARD_NO_OVERLAP);
}

/*
 * Clear the deck after one card effect was resolved(结算)
 */
- (void)clearExistingUsedCards
{
    NSUInteger allCount = self.allCardCount;
    NSUInteger existingCount = _existingCardCount;
    void(^block)() = ^{
        for (NSUInteger i = 0; i < allCount; i++) {
            if (i < existingCount) {
                [_cardMenu removeChild:[_cardMenu.children objectAtIndex:0]];   // Clear existing used card
            }
        }
    };
    
    if (0 != _existingCardCount) {
        BGActionComponent *ac = [BGActionComponent actionComponentWithNode:_cardMenu];
        [ac runFadeOutWithDuration:DURATION_USED_CARD_FADE_OUT
                             block:block];
        _existingCardCount = 0;
    }
}

#pragma mark - Deck updating
/*
 * Update deck with to be selected hero cards
 */
- (void)updateWithHeroIds:(NSArray *)heroIds
{
    _heroMenu = [_menuFactory createMenuWithCards:[self.class heroCardsWithHeroIds:heroIds]];
    _heroMenu.visible = NO;
    _heroMenu.position = POSITION_TO_BE_SELECTED_HERO;
    [_heroMenu alignItemsHorizontally];
    [self addChild:_heroMenu];
    
    void(^block)() = ^ {
        _heroMenu.visible = YES;
        
        [_player addProgressBarWithPosition:POSITION_HERO_SEL_PROGRESS_BAR
                                      block:^{
                                          [_heroMenu removeFromParent];
                                          [_player removeProgressBar];
                                      }];
    };
    
    BGActionComponent *ac = [BGActionComponent actionComponentWithNode:_cardMenu];
    [ac runFadeInWithDuration:DURATION_HERO_SEL_FADE_IN block:block];
}

/*
 * Update deck with used/discarded hand cards. Clear deck after one card effect was resolved(结算)
 */
- (void)updateWithCardIds:(NSArray *)cardIds
{
    if ([self isNeedClearByAddingCardCount:cardIds.count]) {
        [self clearExistingUsedCards];
    } else {
        _existingCardCount = _cardMenu.children.count;
    }
    
    switch (_gameLayer.action) {
        case kActionUpdateDeckCuttedCard:   // Show cutted card on deck
            [_gameLayer setHandCardCountForOtherPlayers];
            [_gameLayer removeProgressBarForOtherPlayers];
            [self showCuttedCardOnDeckWithCardIds:cardIds];
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
 * Update deck with used/discarded hand card menu items.
 */
- (void)updateWithCardMenuItems:(NSArray *)menuItems
{
    if ([self isNeedClearByAddingCardCount:menuItems.count]) {
        [self clearExistingUsedCards];
    } else {
        _existingCardCount = _cardMenu.children.count;
    }
    
    [menuItems enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        [_cardMenu addChild:obj z:_cardMenu.children.count];
    }];
    
    [_gameLayer moveCardWithCardMenuItems:menuItems
                                    block:^(id object) {
                                        [self alignCenterUsedCardWithMenuItem:object];
                                    }];
}

/*
 * Show the used card of other player on the deck
 */
- (void)showUsedCardOnDeckWithCardIds:(NSArray *)cardIds
{
    NSArray *cards = [BGHandArea playingCardsWithCardIds:cardIds];
    NSArray *menuItems = [_menuFactory createMenuItemsWithCards:cards];
    [menuItems enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        [obj setPosition:_gameLayer.currPlayer.position];
        [_cardMenu addChild:obj z:_cardMenu.children.count];
    }];
    [_player.handArea renderFigureAndSuitsOfCards:cards forMenu:_cardMenu];
    
    [_gameLayer moveCardWithCardMenuItems:menuItems
                                    block:^(id object) {
                                        [self alignCenterUsedCardWithMenuItem:object];
                                    }];
}

/*
 * 1. Show all cutted cards of other players on the deck. So the index start from 1.
 *    (The cutted card of self player already showed on deck after used it)
 * 2. Send kStartRound request after action runing finished
 */
- (void)showCuttedCardOnDeckWithCardIds:(NSArray *)cardIds
{
//  Face down the cutted card other player first
    NSMutableArray *frameNames = [NSMutableArray arrayWithCapacity:cardIds.count-1];
    for (NSUInteger i = 1; i < cardIds.count; i++) {
        [frameNames addObject:kImagePlayingCardBack];
    }
    [_menuFactory addMenuItemsWithSpriteFrameNames:frameNames toMenu:_cardMenu];
    
//  Face up all cards by flipping from left after movement    
    [[_cardMenu.children getNSArray] enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        if (idx > 0) {
            [obj setPosition:[_gameLayer.allPlayers[idx] position]];
        }
    }];
    
    NSArray *arrangedCardIds = [self arrangedCuttedCardIdsWithIds:cardIds];
    NSArray *cards = [BGHandArea playingCardsWithCardIds:arrangedCardIds];
    void (^block)(id object) = ^(id object){
        NSUInteger idx = [_cardMenu.children indexOfObject:object];
        if (0 == idx) return;
        
        NSArray *array = [NSArray arrayWithObject:cards[idx]];
        [_menuFactory addMenuItemsWithCards:array toMenu:_cardMenu];
        [_player.handArea renderFigureAndSuitsOfCards:array forMenu:_cardMenu];
        CCMenuItem *menuItem = _cardMenu.children.lastObject;
        menuItem.visible = NO;
        menuItem.position = [object position];
        
        BGActionComponent *actionComp = [BGActionComponent actionComponentWithNode:object];
        ccTime duration = DURATION_CARD_FLIP+(idx-1)*DURATION_CARD_FLIP_INTERVAL;
        [actionComp runFlipFromLeftWithDuration:duration toNode:menuItem];
        
        if (++idx != cardIds.count) return;
        
//      If it is the last cutted card, scale up it.
        [_actionComp runDelayWithDuration:duration+DURATION_USED_CARD_MOVE WithBlock:^{
            CCMenuItem *menuItem = [_cardMenu.children objectAtIndex:[arrangedCardIds indexOfObject:@(_maxCardId)]];
            menuItem.zOrder += 2*cardIds.count; // Scale up at the foremost screen
            
            for (CCMenuItem *item in _cardMenu.children) {
                if (![item isEqual:menuItem]) {
                    item.color = COLOR_DISABLED_CARD;
                }
            }
            
            BGActionComponent *ac = [BGActionComponent actionComponentWithNode:menuItem];
            [ac runScaleUpAndReverseWithDuration:DURATION_CARD_SCALE
                                           scale:SCALE_CARD_UP
                                           block:^{
                                               _existingCardCount = self.allCardCount;
                                               [self clearExistingUsedCards];
                                               [[BGClient sharedClient] sendStartRoundRequest];
                                           }];
        }];
    };
    
    [_gameLayer moveCardWithCardMenuItems:[_cardMenu.children getNSArray] block:block];
}

/*
 * Arrange the cutted card's index, put the cutted card of self player as first one.
 */
- (NSArray *)arrangedCuttedCardIdsWithIds:(NSArray *)cardIds
{
    NSMutableArray *mutableCardIds = [cardIds mutableCopy];
    NSMutableIndexSet *idxSet = [NSMutableIndexSet indexSet];
    NSUInteger idx = 0;
    
    for (id obj in cardIds) {
        if ([obj integerValue] == _player.comparedCardId) {
            [mutableCardIds removeObjectsAtIndexes:idxSet];
            [mutableCardIds addObjectsFromArray:[mutableCardIds objectsAtIndexes:idxSet]];
            cardIds = mutableCardIds;
            break;
        }
        [idxSet addIndex:idx]; idx++;
    }
    
    return cardIds;
}

/*
 * Update deck with hand card count and equipment card
 * Faced down(暗置) all hand cards on the deck for being extracted(比如贪婪)
 */
- (void)updateWithCardCount:(NSUInteger)count equipmentIds:(NSArray *)cardIds
{
    if (0 != count) {
//      If card count is great than 5, need narrow the padding.
//        CGFloat cardPadding = [_player.handArea cardPaddingWithCardCount:count maxCount:COUNT_MAX_DECK_CARD_NO_OVERLAP];
        
        NSMutableArray *frameNames = [NSMutableArray arrayWithCapacity:count];
        for (NSUInteger i = 0 ; i < count; i++) {
            [frameNames addObject:kImagePlayingCardBack];
        }
        
        _handMenu = [_menuFactory createMenuWithSpriteFrameNames:frameNames];
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

//#pragma mark - Card movement
///*
// * Move the selected cards on playing deck or other player's hand
// */
//- (void)moveCardWithCardMenuItems:(NSArray *)menuItems block:(void(^)(id object))block
//{
//    [menuItems enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
//        CGPoint targetPos = [self cardMoveTargetPositionWithIndex:idx];
//        
//        BGActionComponent *ac = [BGActionComponent actionComponentWithNode:obj];
//        [ac runEaseMoveWithTarget:targetPos
//                         duration:DURATION_USED_CARD_MOVE
//                           object:obj
//                            block:block];
//    }];
//}
//
///*
// * Determine target position of selected card movement
// * Set card move target positon according to different game state
// * (Move card to playing deck or other player)
// */
//- (CGPoint)cardMoveTargetPositionWithIndex:(NSUInteger)idx
//{
//    CGPoint targetPos;
//    CGFloat cardWidth = _player.handArea.cardWidth;
//    CGFloat cardHeight = _player.handArea.cardHeight;
//    
//    switch (_gameLayer.state) {
//        case kGameStateCutting: {
//            _gameLayer.state = kGameStateInvalid;   // Set by default
//            
//            NSUInteger rowCount = ceil((double)_gameLayer.allPlayers.count/COUNT_MAX_DECK_CARD_NO_OVERLAP);
//            NSUInteger colCount = ceil((double)_gameLayer.allPlayers.count/rowCount);
//            CGFloat padding = PADDING_CUTTED_CARD;
//            
//            CGFloat startPosX = POSITION_DECK_AREA_CENTER.x - (colCount-1)*cardWidth/2;
//            CGFloat delta = (idx < colCount) ? idx*(cardWidth+padding) : (idx-colCount)*(cardWidth+padding);
//            CGFloat cardPosX = startPosX + delta;
//            
//            CGFloat startPosY = (1 == rowCount) ? POSITION_DECK_AREA_CENTER.y : POSITION_DECK_AREA_TOP.y;
//            CGFloat cardPosY = (idx < colCount) ? startPosY : (POSITION_DECK_AREA_TOP.y-cardHeight-padding);
//            
//            targetPos = ccp(cardPosX, cardPosY);
//            break;
//        }
//            
//        case kGameStatePlaying:
//        case kGameStateDiscarding: {
//            NSUInteger addedCardCount = _cardMenu.children.count - _existingCardCount;
//            NSUInteger factor = (0 != _existingCardCount) ? addedCardCount : addedCardCount-1;
//            factor += _existingCardCount;
//            CGFloat padding = [_player.handArea cardPaddingWithCardCount:addedCardCount
//                                                                maxCount:COUNT_MAX_DECK_CARD_NO_OVERLAP];
//            
//            CGPoint basePos = ccpSub(POSITION_DECK_AREA_CENTER, ccp(factor*cardWidth/2, 0.0f));
//            
//            targetPos = ccpAdd(basePos, ccp((cardWidth+padding)*(idx+1), 0.0f));
//            break;
//        }
//            
//        default: {
//            BGPlayer *targetPlayer = [_gameLayer playerWithName:_gameLayer.targetPlayerNames.lastObject];
//            BGPlayer *player = (_gameLayer.currPlayer.isSelfPlayer) ? targetPlayer : _gameLayer.currPlayer;
//            targetPos = player.position;
//            break;
//        }
//    }
//    
//    return targetPos;
//}

/*
 * Make each card on the deck center alignment
 */
- (void)alignCenterUsedCardWithMenuItem:(CCMenuItem *)menuItem
{
    NSUInteger addedCardCount = _cardMenu.children.count - _existingCardCount;
    CGPoint deltaPos = (0 != _existingCardCount) ? ccp(addedCardCount*_player.handArea.cardWidth/2, 0.0f) : CGPointZero;
    
    BGActionComponent *ac = [BGActionComponent actionComponentWithNode:menuItem];
    [ac runEaseMoveWithTarget:ccpAdd(menuItem.position, deltaPos)
                     duration:DURATION_USED_CARD_MOVE
                        block:nil];
}

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
    
    BGActionComponent *ac = [BGActionComponent actionComponentWithNode:menuItem];
    [ac runEaseMoveScaleWithTarget:ccp(-SCREEN_WIDTH*0.4, -SCREEN_HEIGHT*0.4)
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
    BGActionComponent *ac = [BGActionComponent actionComponentWithNode:menuItem];
    [ac runEaseMoveWithTarget:targetPos
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
