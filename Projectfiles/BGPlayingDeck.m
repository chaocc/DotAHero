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

typedef NS_ENUM(NSInteger, BGPopupTag) {
    kPopupTagAssignedCard = 100
};

@interface BGPlayingDeck ()

@property (nonatomic, weak) BGGameLayer *gameLayer;
@property (nonatomic, weak) BGPlayer *player;

@property (nonatomic, strong) BGActionComponent *actionComp;
@property (nonatomic, strong) BGMenuFactory *menuFactory;

@property (nonatomic, strong) CCSpriteBatchNode *spriteBatch;
@property (nonatomic, strong) CCMenuItem *pannedMenuItem;
@property (nonatomic) CGPoint pannedMenuItemPos;
@property (nonatomic) NSInteger pannedMenuItemZOrder;

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

- (void)clearAllExistingCards
{
    _existingCardCount = self.allCardCount;
    [self clearExistingCards];
}

/*
 * Since some nodes can't be removed if make game running in the background
 */
- (void)removeResidualNodes
{
    [_heroMenu removeFromParent];
    [_handMenu.parent removeFromParent];
    [_equipMenu.parent removeFromParent];
    
    [_spriteBatch removeFromParent];
    [_pileMenu removeFromParent];
}

#pragma mark - Deck card showing
/*
 * Show the "to be selected heros" on the deck
 */
- (void)showToBeSelectedHerosWithHeroIds:(NSArray *)heroIds
{
    [_gameLayer makeBackgroundColorToDark];
    [_player addProgressBar];
    [_player addTextPrompt];
    
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
- (void)showCuttedCardWithCardIds:(NSArray *)cardIds maxCardId:(NSInteger)maxCardId
{
    ccTime duration = (self.numberOfRunningActions > 0) ? DURATION_CARD_MOVE : 0.0f;
    
    [_actionComp runDelayWithDuration:duration block:^{
//      Face down the cutted card of other player first
        [_menuFactory addCardBackMenuItemsWithCount:cardIds.count-1 toMenu:_cardMenu];
        
//      Face up all cards by flipping from left after movement
        [[_cardMenu.children getNSArray] enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            if (idx > 0) {
                BGPlayer *player = _gameLayer.allPlayers[idx];
                [obj setPosition:player.position];
            }
        }];
        
        NSArray *arrangedCardIds = [self arrangedCuttedCardIdsWithIds:cardIds];
        NSArray *cards = [BGPlayingCard playingCardsByCardIds:arrangedCardIds];
        
//      1. Move the card to deck
        [_gameLayer moveCardWithCardMenuItems:[_cardMenu.children getNSArray] block:^(id object) {
            CCMenuItem *cardBack = object;
            NSUInteger idx = [_cardMenu.children indexOfObject:cardBack];
            if (0 == idx) return;
            
            NSArray *array = [NSArray arrayWithObject:cards[idx]];
            [_menuFactory addMenuItemsWithCards:array toMenu:_cardMenu];
            CCMenuItem *menuItem = _cardMenu.children.lastObject;
            menuItem.visible = NO;
            menuItem.position = cardBack.position;
            
//          2. Face up the card
            BGActionComponent *actionComp = [BGActionComponent actionComponentWithNode:cardBack];
            ccTime duration = DURATION_CARD_FLIP+(idx-1)*DURATION_CARD_FLIP_INTERVAL;
            [actionComp runFlipFromLeftWithDuration:duration toNode:menuItem block:nil];
            
            if (++idx != cardIds.count) return;
            
//          3. If it is the last cutted card, scale up it.
            [_actionComp runDelayWithDuration:duration+DURATION_CARD_MOVE block:^{
                NSUInteger *index = [arrangedCardIds indexOfObject:@(maxCardId)];
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
- (void)showUsedCardWithCardMenuItems:(NSArray *)menuItems
{
    [self checkDeckBeforeAddingCardWithCount:menuItems.count];
    if (kGameStatePlaying == _gameLayer.state || kGameStateDiscarding == _gameLayer.state) {
        [self clearExistingCards];
    }
    
//  The zOrder determine index of child menu items
    __block NSInteger zOrder = _cardMenu.children.count;
    [menuItems enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        [_cardMenu addChild:obj z:zOrder++];    // cardMenu children order changed, but menuItems not changed.
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
    if ((kGameStatePlaying == _gameLayer.state || kGameStateDiscarding == _gameLayer.state) &&
        kActionPlayCard != _gameLayer.action) {
        [self clearExistingCards];
    }
    
    NSArray *cards = [BGPlayingCard playingCardsByCardIds:cardIds];
    NSArray *menuItems = [_menuFactory createMenuItemsWithCards:cards];
    __block NSInteger zOrder = _cardMenu.children.count;
    [menuItems enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        [obj setPosition:CARD_MOVE_POSITION(_gameLayer.currPlayer.position, idx, menuItems.count)];
        [_cardMenu addChild:obj z:zOrder++];
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
    ccTime duration = (self.numberOfRunningActions > 0) ? DURATION_CARD_MOVE : 0.0f;
    
    [_actionComp runDelayWithDuration:duration block:^{
        [self checkDeckBeforeAddingCardWithCount:count];
        
        NSArray *menuItems = [_menuFactory createCardBackMenuItemsWithCount:count];
        __block NSInteger zOrder = [_cardMenu.children.lastObject zOrder] + 1;
        [menuItems enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            [_cardMenu addChild:obj z:zOrder++];
            [obj setPosition:[self cardMoveTargetPositionWithIndex:idx count:count]];
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
    NSArray *cards = [BGPlayingCard playingCardsByCardIds:cardIds];
    NSArray *menuItems = [_menuFactory createMenuItemsWithCards:cards];
    
    __block NSUInteger index = self.allCardCount - 1;
    __block NSInteger zOrder = _cardMenu.children.count;
    [menuItems enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        CCMenuItem *cardBack = [_cardMenu.children objectAtIndex:index--];
        
        [obj setVisible:NO];
        [obj setPosition:cardBack.position];
        [_cardMenu addChild:obj z:zOrder++];
        
        BGActionComponent *ac = [BGActionComponent actionComponentWithNode:cardBack];
        [ac runFlipFromLeftWithDuration:DURATION_CARD_FLIP toNode:obj block:nil];
    }];
}

/*
 * Show target player hand card(暗置的) and equipment card
 * Faced down(暗置) all hand cards on the deck for being drew(比如贪婪)
 */
- (void)showPopupWithHandCount:(NSUInteger)count equipmentIds:(NSArray *)cardIds
{
    [_gameLayer makeBackgroundColorToDark];
    [_player addProgressBar];
    [_player addTextPrompt];
    
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
        NSArray *cards = [BGPlayingCard playingCardsByCardIds:cardIds];
        _equipMenu = [_menuFactory createMenuWithCards:cards];
        [_equipMenu alignItemsHorizontallyWithPadding:PADDING_DREW_CARD];
        _equipMenu.position = equipMenuPos;
        [popup addChild:_equipMenu];
    }
}

/*
 * Show assigned(待分配的) cards on the deck
 */
- (void)showPopupWithAssignedCardIds:(NSArray *)cardIds
{
    [_gameLayer makeBackgroundColorToDark];
    [_player addProgressBar];
    [_player addPlayingMenu];
    [_player addTextPrompt];
    
//  Popup window
    _spriteBatch = [CCSpriteBatchNode batchNodeWithFile:kZlibCardPopup];
    [self addChild:_spriteBatch];
    
//    NSString *image = [NSString stringWithFormat:@"%@%i", kImagePopupAssignedCard,_gameLayer.playerCount];
    NSString *image = kImagePopupAssignedCard;
    NSString *frameName = [image stringByAppendingPathExtension:kFileTypePng];
    CCSprite *popup = [CCSprite spriteWithSpriteFrameName:frameName];
    CGFloat popupWidth = popup.contentSize.width;
    CGFloat popupHeight = popup.contentSize.height;
    popup.anchorPoint = CGPointZero;
    popup.position = ccpSub(POSITION_DECK_AREA_CENTER, ccp(popupWidth/2, popupHeight*0.45));
    [_spriteBatch addChild:popup z:0 tag:kPopupTagAssignedCard];
    
//  Playing card menu
    NSArray *cards = [BGPlayingCard playingCardsByCardIds:cardIds];
    _pileMenu = [_menuFactory createMenuWithCards:cards];
    _pileMenu.enabled = NO;
    _pileMenu.position = CGPointZero;
    [self addChild:_pileMenu];
    
//  Card slot and position
    [cardIds enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        CCSprite *cardSlot = [CCSprite spriteWithSpriteFrameName:kImagePopupCardSlot];
        CGFloat slotWidth = cardSlot.contentSize.width;
        CGFloat slotHeight = cardSlot.contentSize.height;
        
        NSUInteger rowCount = ceil((double)_gameLayer.playerCount/COUNT_MAX_DECK_CARD);
        NSUInteger colCount = ceil((double)_gameLayer.playerCount/rowCount);
        CGFloat padding = PADDING_ASSIGNED_CARD;
        
        CGFloat startPosX = POSITION_DECK_AREA_CENTER.x - (colCount-1)*slotWidth/2;
        CGFloat delta = (idx < colCount) ? idx*(slotWidth+padding) : (idx-colCount)*(slotWidth+padding);
        CGFloat slotPosX = startPosX + delta;
        
        CGFloat startPosY = (1 == rowCount) ? POSITION_DECK_AREA_CENTER.y : POSITION_DECK_AREA_TOP.y;
        CGFloat slotPosY = (idx < colCount) ? startPosY : (POSITION_DECK_AREA_TOP.y-slotHeight-padding);
        
        cardSlot.position = ccp(slotPosX, slotPosY);
        [_spriteBatch addChild:cardSlot];
        
        // Card menu position
        CCMenuItem *menuItem = [_pileMenu.children objectAtIndex:idx];
        menuItem.position = ccpSub(cardSlot.position, ccp(0.0f, PLAYING_CARD_HEIGHT*0.1));
    }];
    
    _player.playingMenu.zOrder = _spriteBatch.zOrder + 1;
    _player.playingMenu.menuPosition = ccpAdd(popup.position, ccp(popupWidth/2, 0.0f));
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
        CCMenuItem *menuItem = obj;
        BGActionComponent *ac = [BGActionComponent actionComponentWithNode:menuItem];
        [ac runEaseMoveWithTarget:ccpAdd(menuItem.position, deltaPos)
                         duration:DURATION_DECK_CARD_MOVE
                            block:nil];
    }];
}

- (void)makeUsedCardCenterAlignmentDelay
{
    ccTime duration = (self.numberOfRunningActions > 0) ? DURATION_CARD_MOVE : 0.0f;
    
    [_actionComp runDelayWithDuration:duration block:^{
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

/*
 * Cutted card position
 */
- (CGPoint)cardMoveTargetPositionWithIndex:(NSUInteger)idx
{
    CGFloat cardWidth = PLAYING_CARD_WIDTH;
    CGFloat cardHeight = PLAYING_CARD_HEIGHT;
    
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
 * Used card position
 * NOTE: If received multiple actions from server sequentially and each action will update the variable "_exisingCardCount",
 *       must handle each action by sequence. The next action can be handled util previous action completed. (By running delay)
 *       (If multiple actions update the variable at the same time, it leads to wrong target position of card movement)
 */
- (CGPoint)cardMoveTargetPositionWithIndex:(NSUInteger)idx count:(NSUInteger)count
{    
    CGFloat cardWidth = PLAYING_CARD_WIDTH;
    
    NSUInteger factor = (_existingCardCount > 0) ? count : count-1;
    CGFloat padding = PLAYING_CARD_PADDING(count, COUNT_MAX_DECK_CARD);
    
    CGPoint basePos = (_existingCardCount > 0) ?
        [(CCMenuItem *)[_cardMenu.children objectAtIndex:_existingCardCount-1] position] :
        ccpSub(POSITION_DECK_AREA_CENTER, ccp(factor*cardWidth/2, 0.0f));
    CGPoint startPos = (_existingCardCount > 0) ? ccpSub(basePos, ccp(factor*cardWidth, 0.0f)) : basePos;
    
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
        [self drawHandCardWithMenuItems:[NSArray arrayWithObject:menuItem]];
    }
    else if ([menuItem.parent isEqual:_equipMenu]) {    // 目标装备
        [self drawEquipmentWithMenuItems:[NSArray arrayWithObject:menuItem]];
    }
}

/*
 * Select a hero card by touching menu item
 */
- (void)selectHeroByTouchingMenuItem:(CCMenuItem *)menuItem
{
    [_player removeProgressBar];
    [_player removeTextPrompt];
    
    _player.selectedHeroId = menuItem.tag;
    for (CCMenuItem *item in menuItem.parent.children) {
        if (![item isEqual:menuItem]) {
            item.visible = NO;
        }
    }
    
    BGActionComponent *ac = [BGActionComponent actionComponentWithNode:menuItem];
    [ac runEaseMoveScaleWithTarget:ccp(-SCREEN_WIDTH*0.4, -SCREEN_HEIGHT*0.4)
                          duration:DURATION_SELECTED_HERO_MOVE
                             scale:SCALE_SELECTED_HERO
                             block:^{
                                 [menuItem.parent removeFromParent];
                                 [[BGClient sharedClient] sendChoseHeroIdRequest];
                             }];
    
//    [self showPopupWithAssignedCardIds:[NSArray arrayWithObjects:@(10), @(20), nil]];
//    [self showPopupWithAssignedCardIds:[NSArray arrayWithObjects:@(10), @(20), @(30), @(40), @(50), @(60), nil]];
}

/*
 * Draw(抽取) hand card of target player
 */
- (void)drawHandCardWithMenuItems:(NSArray *)menuItems
{
    _equipMenu.enabled = NO;
    _equipMenu.color = COLOR_DISABLED_CARD;
    
    [menuItems enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        [_player.selectedCardIdxes addObject:@([obj tag])];
    }];
    [self drawCardWithMenuItems:menuItems];
}

/*
 * Draw(抽取) equipment of target player
 */
- (void)drawEquipmentWithMenuItems:(NSArray *)menuItems
{
    [_gameLayer.targetPlayer.equipmentArea updateEquipmentWithCardId:[menuItems.lastObject tag]];
    
    _player.selectableCardCount = 1;
    _player.selectedCardIds = [NSArray arrayWithObject:@([menuItems.lastObject tag])];
    [self drawCardWithMenuItems:menuItems];
}

/*
 * Draw(抽取) a hand card of target player by touching card menu item
 * If only have one hand card, end directly after drew.
 */
- (void)drawCardWithMenuItems:(NSArray *)menuItems
{
    _gameLayer.currPlayerName = _player.playerName;
    
    [menuItems enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        [obj removeFromParent];
        _handMenu.enabled = NO;
        [_handMenu alignItemsHorizontallyWithPadding:PLAYING_CARD_PADDING(_handMenu.children.count, COUNT_MAX_DREW_CARD)];
        [obj setPosition:CARD_MOVE_POSITION(_gameLayer.targetPlayer.position, idx, menuItems.count)];
        [_player.handArea addAndFaceDownOneDrewCardWith:obj];
    }];
    
//  If menuItems count is great than 0, only call "makeHandCardLeftAlignment" at the last time.
    [_gameLayer moveCardWithCardMenuItems:menuItems block:^(id object) {
        if ( [menuItems indexOfObject:object] == menuItems.count-1) {
            [_player.handArea makeHandCardLeftAlignment];
            _handMenu.enabled = YES;
        }
        
        if ([self isDrawingFinished]) {
            [[BGClient sharedClient] sendChoseCardToGetRequest];    // Send plugin reqeust
            [_player.selectedCardIdxes removeAllObjects];
        }
    }];
    
    if ([self isDrawingFinished]) {
        [_player removeProgressBar];
        [_handMenu.parent removeFromParent];
        [_equipMenu.parent removeFromParent];
        [_gameLayer makeBackgroundColorToNormal];
        [self clearAllExistingCards];
    }
}

//  The drew card count can't great than all hand card count
- (BOOL)isDrawingFinished
{
    return ((_player.selectedCardIdxes.count == _gameLayer.targetPlayer.handCardCount) ||
            (_player.selectedCardIdxes.count == _player.selectableCardCount));
}

#pragma mark - Playing menu touching
- (void)playingMenuItemTouched:(CCMenuItem *)menuItem
{
//  Energy transport
    if (kGameStateAssigning == _gameLayer.state) {
        [_gameLayer.allPlayers enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            NSArray *menuItems = [NSArray arrayWithObject:[_pileMenu.children objectAtIndex:idx]];
            [_gameLayer moveCardWithCardMenuItems:menuItems block:nil];
            
            if (stop) {
                [_gameLayer moveCardWithCardMenuItems:menuItems block:^(id object) {
                    _player.selectedCardIds = [BGPlayingCard playingCardIdsByMenu:_pileMenu];
                    [[BGClient sharedClient] sendAsignCardRequest];
                    [_pileMenu removeFromParent];
                }];
            }
        }];
        
        [_spriteBatch removeFromParent];
        [self clearAllExistingCards];
    }
    
    return;
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
    
//  Pan gesture for "Energy Transport" card
    if (input.gesturePanBegan) {
        NSUInteger count = _pileMenu.children.count;
        for (CCMenuItem *menuItem in _pileMenu.children) {
            if ([input isAnyTouchOnNode:menuItem touchPhase:KKTouchPhaseAny]) {
                _pannedMenuItem = menuItem;
                _pannedMenuItemPos = menuItem.position;
                _pannedMenuItemZOrder = menuItem.zOrder;
                _pannedMenuItem.zOrder = count; // Make the panned card at the foremost
                
                for (CCNode *node in _pileMenu.children) {
                    if (![node isEqual:menuItem]) {
                        [_gameLayer setColorWith:COLOR_DISABLED_CARD ofNode:node];
                    }
                }
                break;
            }
        }
        
        CCNode *popup = [_spriteBatch getChildByTag:kPopupTagAssignedCard];
        if (input.gesturePanLocation.x-_pannedMenuItem.contentSize.width/2 >= popup.position.x &&
            input.gesturePanLocation.x+_pannedMenuItem.contentSize.width/2 <= popup.position.x+popup.contentSize.width &&
            input.gesturePanLocation.y-_pannedMenuItem.contentSize.height/2 >= popup.position.y &&
            input.gesturePanLocation.y+_pannedMenuItem.contentSize.height/2 <= popup.position.y+popup.contentSize.height) {
            _pannedMenuItem.position = input.gesturePanLocation;
        }
    }
    
    if (_pannedMenuItem && input.panGestureRecognizer.state == UIGestureRecognizerStatePossible) {
        for (CCMenuItem *menuItem in _pileMenu.children) {
            if (CGRectContainsPoint(menuItem.boundingBox, input.gesturePanLocation)) {
                // The zOrder determine index of child menu items
                _pannedMenuItem.zOrder = menuItem.zOrder;
                menuItem.zOrder = _pannedMenuItemZOrder;
                _pannedMenuItem.position = menuItem.position;
                menuItem.position = _pannedMenuItemPos;
                
                _pannedMenuItem = nil;
                [_gameLayer setColorWith:ccWHITE ofNode:_pileMenu];
                break;
            }
        }
    }
}

@end
