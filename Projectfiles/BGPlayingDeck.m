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
#import "BGDefines.h"
#import "BGFileConstants.h"
#import "BGActionComponent.h"

@interface BGPlayingDeck ()

@property (nonatomic, weak) BGGameLayer *gameLayer;
@property (nonatomic, weak) BGPlayer *player;

@property (nonatomic, strong) BGActionComponent *actionComp;
@property (nonatomic, strong) BGMenuFactory *menuFactory;
@property (nonatomic, strong) CCMenu *cardMenu;     // 使用|弃置的牌
@property (nonatomic, strong) CCMenu *heroMenu;     // 待选的英雄
@property (nonatomic, strong) CCMenu *handMenu;     // 目标手牌
@property (nonatomic, strong) CCMenu *equipMenu;    // 目标装备
@property (nonatomic, strong) CCMenu *pileMenu;     // 牌堆牌

@property (nonatomic) NSUInteger allCardCount;
@property (nonatomic) NSUInteger addedCardCount;
@property (nonatomic) NSUInteger existingCardCount;

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
        
        [self scheduleUpdate];
    }
    return self;
}

- (NSUInteger)allCardCount
{
    _allCardCount = _cardMenu.children.count;
    for (CCNode *node in _cardMenu.children) {
        if (!node.visible) _allCardCount--;
    }
    
    return _allCardCount;
}

/*
 * Check if need clear deck before adding card
 * NOTE: If received multiple actions from server sequentially and each action will update the variable "_exisingCardCount",
 *       must handle each action by sequence. The next action can be handled util previous action completed. (By running delay)
 *       (If multiple actions update the variable at the same time, it leads to wrong target position of card movement)
 */
- (void)checkDeckBeforeAddingCardWithCount:(NSUInteger)count
{
    if (count+_existingCardCount > COUNT_MAX_DECK_CARD) {
        [self clearExistingCards];
    } else {
        _existingCardCount = self.allCardCount;
    }
}

/*
 * Clear the deck after one card effect was resolved(结算)
 */
- (void)clearExistingCards
{   
    NSUInteger existingCardCount = _existingCardCount;
    _existingCardCount = 0;
    
    for (NSUInteger i = 0; i < existingCardCount; i++) {
        BGActionComponent *ac = [BGActionComponent actionComponentWithNode:[_cardMenu.children objectAtIndex:i]];
        [ac runFadeOutWithDuration:DURATION_USED_CARD_FADE_OUT block:^(CCNode *node) {
            [_cardMenu removeChild:node];
        }];
    }
}

/*
 * Since some nodes can't be removed if make game running in the background
 */
- (void)removeResidualNodes
{
    [_heroMenu removeFromParent];
    [_handMenu.parent removeFromParent];
    [_equipMenu.parent removeFromParent];
}

#pragma mark - Deck card showing
/*
 * Show the "to be selected heros" on the deck
 */
- (void)showToBeSelectedHerosWithHeroIds:(NSArray *)heroIds
{
    [_gameLayer makeBackgroundColorToDark];
    [_player addProgressBar];
    
    _heroMenu = [_menuFactory createMenuWithCards:[BGHeroCard heroCardsWithHeroIds:heroIds]];
    _heroMenu.visible = YES;
    _heroMenu.position = POSITION_TO_BE_SELECTED_HERO;
    [_heroMenu alignItemsHorizontally];
    [self addChild:_heroMenu];
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
            [mutableCardIds addObjectsFromArray:[cardIds objectsAtIndexes:idxSet]];
            cardIds = mutableCardIds;
            break;
        }
        [idxSet addIndex:idx]; idx++;
    }
    
    return cardIds;
}

/*
 * 1. Show all cutted cards of other players on the deck. So the index start from 1.
 *    (The cutted card of self player already showed on deck after used it)
 * 2. Send kStartRound request after action runing finished
 */
- (void)showCuttedCardWithCardIds:(NSArray *)cardIds
{
    ccTime duraiton = (self.isRunning) ? DURATION_CARD_MOVE : 0.0f;
    
    [_actionComp runDelayWithDuration:duraiton withBlock:^{
//      Face down the cutted card of other player first
        [_menuFactory addCardBackMenuItemsWithCount:cardIds.count-1 toMenu:_cardMenu];
        
//      Face up all cards by flipping from left after movement
        [[_cardMenu.children getNSArray] enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            if (idx > 0) {
                [obj setPosition:[_gameLayer.allPlayers[idx] position]];
            }
        }];
        
        NSArray *arrangedCardIds = [self arrangedCuttedCardIdsWithIds:cardIds];
        NSArray *cards = [BGPlayingCard playingCardsWithCardIds:arrangedCardIds];
        
//      1. Move the card to deck
        [_gameLayer moveCardWithCardMenuItems:[_cardMenu.children getNSArray] block:^(id object) {
            NSUInteger idx = [_cardMenu.children indexOfObject:object];
            if (0 == idx) return;
            
            NSArray *array = [NSArray arrayWithObject:cards[idx]];
            [_menuFactory addMenuItemsWithCards:array toMenu:_cardMenu];
            CCMenuItem *menuItem = _cardMenu.children.lastObject;
            menuItem.visible = NO;
            menuItem.position = [object position];
            
//          2. Face up the card
            BGActionComponent *actionComp = [BGActionComponent actionComponentWithNode:object];
            ccTime duration = DURATION_CARD_FLIP+(idx-1)*DURATION_CARD_FLIP_INTERVAL;
            [actionComp runFlipFromLeftWithDuration:duration toNode:menuItem];
            
            if (++idx != cardIds.count) return;
            
//          3. If it is the last cutted card, scale up it.
            [_actionComp runDelayWithDuration:duration+DURATION_CARD_MOVE withBlock:^{
                NSUInteger *index = [arrangedCardIds indexOfObject:@(_maxCardId)];
                CCMenuItem *menuItem = [_cardMenu.children objectAtIndex:index];
                menuItem.zOrder += 2*cardIds.count; // Scale up at the foremost screen
                
                for (CCMenuItem *item in _cardMenu.children) {
                    if (![item isEqual:menuItem]) {
                        item.color = COLOR_DISABLED_CARD;
                    }
                }
                
                void(^block)() = ^() {
                    _existingCardCount = self.allCardCount;
                    [self clearExistingCards];
                    [[BGClient sharedClient] sendStartRoundRequest];    // 牌局开始
                };
                
                BGActionComponent *ac = [BGActionComponent actionComponentWithNode:menuItem];
                [ac runScaleUpAndReverseWithDuration:DURATION_CARD_SCALE
                                               scale:SCALE_CARD_UP
                                               block:block];
            }];
        }];
    }];
}

/*
 * Show the used/discarded hand card of self player
 */
- (void)showUsedWithCardMenuItems:(NSArray *)menuItems
{
    [self checkDeckBeforeAddingCardWithCount:menuItems.count];
    if (kGameStatePlaying == _gameLayer.state) {
        [self clearExistingCards];
    }
    
    [menuItems enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        [_cardMenu addChild:obj z:_cardMenu.children.count];
    }];
    
    [_gameLayer moveCardWithCardMenuItems:menuItems block:nil];
    
    _addedCardCount = menuItems.count;
    [self makeUsedCardCenterAlignmentDelay];
}

/*
 * Show the used/discarded hand card of current player
 */
- (void)showUsedCardWithCardIds:(NSArray *)cardIds
{
    [self checkDeckBeforeAddingCardWithCount:cardIds.count];
    if (kGameStatePlaying == _gameLayer.state && kActionPlayCard != _gameLayer.action) {
        [self clearExistingCards];
    }
    
    NSArray *cards = [BGPlayingCard playingCardsWithCardIds:cardIds];
    NSArray *menuItems = [_menuFactory createMenuItemsWithCards:cards];
    [menuItems enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        [obj setPosition:_gameLayer.currPlayer.position];
        [_cardMenu addChild:obj z:_cardMenu.children.count];
    }];
    
    [_gameLayer moveCardWithCardMenuItems:menuItems block:nil];
    
    _addedCardCount = cardIds.count;
    [self makeUsedCardCenterAlignmentDelay];
}

/*
 * Show faced down card of top pile on the deck
 * NOTE: Multiple actions need update the variable "_existingCardCount". So need delay to run it.
 */
- (void)showFacedDownCardWithCount:(NSUInteger)count
{
    ccTime duration = (self.isRunning) ? DURATION_CARD_MOVE : 0.0f;
    
    [_actionComp runDelayWithDuration:duration withBlock:^{
        [self checkDeckBeforeAddingCardWithCount:count];
        
        NSArray *menuItems = [_menuFactory createCardBackMenuItemsWithCount:count];
        [menuItems enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            [_cardMenu addChild:obj z:_cardMenu.children.count];
            [obj setPosition:[self cardPositionWithIndex:idx count:count]];
        }];
        
        _addedCardCount = count;
        [self makeUsedCardCenterAlignment];
    }];
}

/*
 * Show(face up) the card of top pile on the deck
 */
- (void)showTopPileCardWithCardIds:(NSArray *)cardIds
{
    NSArray *cards = [BGPlayingCard playingCardsWithCardIds:cardIds];
    NSArray *menuItems = [_menuFactory createMenuItemsWithCards:cards];
    
    __block NSUInteger index = self.allCardCount - 1;
    [menuItems enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        CCMenuItem *cardBack = [_cardMenu.children objectAtIndex:index--];
        
        [obj setVisible:NO];
        [obj setPosition:cardBack.position];
        [_cardMenu addChild:obj z:_cardMenu.children.count];
        
        BGActionComponent *ac = [BGActionComponent actionComponentWithNode:cardBack];
        [ac runFlipFromLeftWithDuration:DURATION_CARD_FLIP
                                 toNode:obj];
    }];
}

/*
 * Show target player hand card(暗置的) and equipment card
 * Faced down(暗置) all hand cards on the deck for being drew(比如贪婪)
 */
- (void)showPlayerHandCardWithCount:(NSUInteger)count equipmentIds:(NSArray *)cardIds
{
    NSString *frameName = nil;
    if (count > 0 && cardIds.count > 0) {
        frameName = kImagePopupDrewAllCards;
    } else if (count > 0) {
        frameName = kImagePopupDrewHandCard;
    } else {
        frameName = kImagePopupDrewEquipment;
    }
    CCSprite *popup = [CCSprite spriteWithSpriteFrameName:frameName];
    CGFloat popupWidth = popup.contentSize.width;
    CGFloat popupHeight = popup.contentSize.height;
    popup.anchorPoint = CGPointZero;
    [self addChild:popup];
    
//  Set menu position
    CGPoint handMenuPos, equipMenuPos;
    if (count > 0 && cardIds.count > 0) {
        popup.position = ccpSub(POSITION_DECK_AREA_CENTER, ccp(popupWidth/2, popupHeight*0.57));
        handMenuPos = ccp(popupWidth/2, popupHeight/2+PLAYING_CARD_HEIGHT*0.38);
        equipMenuPos = ccp(popupWidth/2, popupHeight/2-PLAYING_CARD_HEIGHT*0.62);
    } else {
        popup.position = ccpSub(POSITION_DECK_AREA_CENTER, ccp(popupWidth/2, popupHeight/2));
        handMenuPos = ccp(popupWidth/2, popupHeight*0.42);
        equipMenuPos = ccp(popupWidth/2, popupHeight*0.42);
    }
    
//  Add hand cards of target player on the deck
    if (count > 0) {
        _handMenu = [_menuFactory createCardBackMenuWithCount:count];
        // If card count is great than 5, need narrow the padding.
        [_handMenu alignItemsHorizontallyWithPadding:PLAYING_CARD_PADDING(count, COUNT_MAX_DREW_CARD)];
        _handMenu.position = handMenuPos;
        [popup addChild:_handMenu];
    }
    
//  Add equipment cards of target player on the deck if equipped
    if (cardIds.count > 0) {
        NSArray *cards = [BGPlayingCard playingCardsWithCardIds:cardIds];
        _equipMenu = [_menuFactory createMenuWithCards:cards];
        [_equipMenu alignItemsHorizontallyWithPadding:PADDING_DREW_CARD];
        _equipMenu.position = equipMenuPos;
        [popup addChild:_equipMenu];
    }
    
    [_player addProgressBar];
}

/*
 * Show assigned(待分配的) cards on the deck
 */
- (void)showAssignedCardsWithCardIds:(NSArray *)cardIds
{
    NSString *image = [NSString stringWithFormat:@"%@%i", kImagePopupEnergyTransport,_gameLayer.playerCount];
    NSString *frameName = [image stringByAppendingPathExtension:kFileTypePng];
    CCSprite *popup = [CCSprite spriteWithSpriteFrameName:frameName];
    CGFloat popupWidth = popup.contentSize.width;
    CGFloat popupHeight = popup.contentSize.height;
    popup.anchorPoint = CGPointZero;
    popup.position = ccpSub(POSITION_DECK_AREA_CENTER, ccp(popupWidth/2, popupHeight/2));
    [self addChild:popup];
    
    NSArray *cards = [BGPlayingCard playingCardsWithCardIds:cardIds];
    _pileMenu = [_menuFactory createMenuWithCards:cards];
    [_pileMenu alignItemsHorizontallyWithPadding:PADDING_ASSIGNED_CARD];
    
}

#pragma mark - Card movement
/*
 * Make each card on the deck center alignment
 */
- (void)makeUsedCardCenterAlignment
{
    if (0 == _existingCardCount) return;
    
    CGPoint deltaPos = ccp(_addedCardCount*PLAYING_CARD_WIDTH/2, 0.0f);
    [[_cardMenu.children getNSArray] enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        BGActionComponent *ac = [BGActionComponent actionComponentWithNode:obj];
        [ac runEaseMoveWithTarget:ccpAdd([obj position], deltaPos)
                         duration:DURATION_DECK_CARD_MOVE
                            block:nil];
    }];
}

- (void)makeUsedCardCenterAlignmentDelay
{
    ccTime duration = (self.isRunning) ? DURATION_CARD_MOVE : 0.0f;
    
    [_actionComp runDelayWithDuration:duration withBlock:^{
        [self makeUsedCardCenterAlignment];
    }];
}

- (void)moveCardWithCardMenuItems:(NSArray *)menuItems;
{
    [menuItems enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        for (CCMenuItem *menuItem in _cardMenu.children) {
            if ([obj tag] == menuItem.tag) {
                [_gameLayer setColorWith:COLOR_DISABLED_CARD ofNode:menuItem];
                
                [obj setPosition:menuItem.position];
            }
        }
    }];
    
    [_gameLayer moveCardWithCardMenuItems:menuItems block:nil];
}

- (CGPoint)cuttedCardPositionWithIndex:(NSUInteger)idx
{
    CGFloat cardWidth = [_cardMenu.children.lastObject contentSize].width;
    CGFloat cardHeight = [_cardMenu.children.lastObject contentSize].height;
    
    NSUInteger rowCount = ceil((double)_gameLayer.playerCount/COUNT_MAX_DECK_CARD);
    NSUInteger colCount = ceil((double)_gameLayer.playerCount/rowCount);
    CGFloat padding = PADDING_CUTTED_CARD;
    
    CGFloat startPosX = POSITION_DECK_AREA_CENTER.x - (colCount-1)*cardWidth/2;
    CGFloat delta = (idx < colCount) ? idx*(cardWidth+padding) : (idx-colCount)*(cardWidth+padding);
    CGFloat cardPosX = startPosX + delta;
    
    CGFloat startPosY = (1 == rowCount) ? POSITION_DECK_AREA_CENTER.y : POSITION_DECK_AREA_TOP.y;
    CGFloat cardPosY = (idx < colCount) ? startPosY : (POSITION_DECK_AREA_TOP.y-cardHeight-padding);
    
    return ccp(cardPosX, cardPosY);
}

/*
 * NOTE: If received multiple actions from server sequentially and each action will update the variable "_exisingCardCount",
 *       must handle each action by sequence. The next action can be handled util previous action completed. (By running delay)
 *       (If multiple actions update the variable at the same time, it leads to wrong target position of card movement)
 */
- (CGPoint)cardPositionWithIndex:(NSUInteger)idx count:(NSUInteger)count
{    
    CGFloat cardWidth = [_cardMenu.children.lastObject contentSize].width;
    
    NSUInteger factor = (_existingCardCount > 0) ? count : count-1;
    CGFloat padding = PLAYING_CARD_PADDING(count, COUNT_MAX_DECK_CARD);
    
    CGPoint basePos = (_existingCardCount > 0) ?
        [[_cardMenu.children objectAtIndex:_existingCardCount-1] position] :
        ccpSub(POSITION_DECK_AREA_CENTER, ccp(factor*cardWidth/2, 0.0f));
    CGPoint startPos = ccpSub(basePos, ccp(factor*cardWidth, 0.0f));
    
    return ccpAdd(startPos, ccp((cardWidth+padding)*idx, 0.0f));
}

#pragma mark - MenuItem touching
/*
 * Menu delegate method is called while selecting a hero/hand card
 */
- (void)menuItemTouched:(CCMenuItem *)menuItem
{
    if ([menuItem.parent isEqual:_heroMenu]) {          // 待选的英雄
        [self selectHeroByTouchingMenuItem:menuItem];
    }
    else if ([menuItem.parent isEqual:_handMenu]) {     // 目标手牌
        [self drawHandCardByTouchingMenuItem:menuItem];
    }
    else if ([menuItem.parent isEqual:_equipMenu]) {    // 目标装备
        [self drawEquipmentByTouchingMenuItem:menuItem];
    }
}

/*
 * Select a hero card by touching menu item
 */
- (void)selectHeroByTouchingMenuItem:(CCMenuItem *)menuItem
{
    _player.selectedHeroId = menuItem.tag;
    
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
                                 [[BGClient sharedClient] sendChoseHeroIdRequest];
                             }];
}

/*
 * Draw(抽取) hand card of target player
 */
- (void)drawHandCardByTouchingMenuItem:(CCMenuItem *)menuItem
{
    _equipMenu.enabled = NO;
    _equipMenu.color = COLOR_DISABLED_CARD;
    
    NSUInteger idx = _handMenu.children.count - menuItem.tag - 1;
    [_player.selectedCardIdxes addObject:@(idx)];
    [self drawCardByTouchingMenuItem:menuItem];
}

/*
 * Draw(抽取) equipment of target player
 */
- (void)drawEquipmentByTouchingMenuItem:(CCMenuItem *)menuItem
{
    [_gameLayer.targetPlayer.equipmentArea updateEquipmentWithCardId:menuItem.tag];
    
    _player.selectableCardCount = 1;
    _player.selectedCardIds = [NSArray arrayWithObject:@(menuItem.tag)];
    [self drawCardByTouchingMenuItem:menuItem];
}

/*
 * Draw(抽取) a hand card of target player by touching card menu item
 * If only have one hand card, end directly after drew.
 */
- (void)drawCardByTouchingMenuItem:(CCMenuItem *)menuItem
{   
    [menuItem removeFromParent];
    [_handMenu alignItemsHorizontallyWithPadding:PLAYING_CARD_PADDING(_handMenu.children.count, COUNT_MAX_DREW_CARD)];
    [_player.handArea addAndFaceDownOneDrewCardWith:menuItem];
    
//  The drew card count can't great than all hand card count
    menuItem.position = _gameLayer.targetPlayer.position;
    [_gameLayer moveCardWithCardMenuItems:[NSArray arrayWithObject:menuItem] block:^(id object) {
        [_player.handArea makeHandCardLeftAlignment];
        
        if ([self isDrawingFinished]) {
            [[BGClient sharedClient] sendChoseCardToGetRequest];    // Send plugin reqeust
        }
    }];
        
    if ([self isDrawingFinished]) {
        [_player removeProgressBar];
        [_handMenu.parent removeFromParent];
        [_equipMenu.parent removeFromParent];
    }
}

- (BOOL)isDrawingFinished
{
    return ((_player.selectedCardIdxes.count == _gameLayer.targetPlayer.handCardCount) ||
            (_player.selectedCardIdxes.count == _player.selectableCardCount));
}

#pragma mark - Gestures
- (void)update:(ccTime)delta
{
    if ([CCDirector sharedDirector].currentPlatformIsIOS) {
        [self gestureRecognition];
    }
    else if ([CCDirector sharedDirector].currentPlatformIsMac) {
        
    }
}

- (void)gestureRecognition
{
    KKInput *input = [KKInput sharedInput];
    
    if (![input isAnyTouchOnNode:_heroMenu.children.lastObject touchPhase:KKTouchPhaseAny]) {
        return;
    }
    
    if (input.gestureDoubleTapRecognizedThisFrame || input.gestureLongPressBegan) {
//        CCSprite *popup = [CCSprite spriteWithSpriteFrameName:kImagePopupDrewAllCards];
//        CGFloat popupWidth = popup.contentSize.width;
//        CGFloat popupHeight = popup.contentSize.height;
//        popup.anchorPoint = CGPointZero;
//        popup.position = ccpSub(POSITION_DECK_AREA_CENTER, ccp(popupWidth/2, popupHeight/2));
//        [self addChild:popup];
    }
}

@end
