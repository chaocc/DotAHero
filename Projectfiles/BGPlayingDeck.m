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
    return _cardMenu.children.count;
}

- (BOOL)isNeedClearByAddingCardCount:(NSUInteger)count
{
    return (count+_existingCardCount > COUNT_MAX_DECK_CARD);
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
                // Clear existing used card
                [_cardMenu removeChild:[_cardMenu.children objectAtIndex:0]];
            }
        }
    };
    
    if (_existingCardCount > 0) {
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
    [_gameLayer setColorWith:COLOR_DISABLED ofNode:_gameLayer];
    
    _heroMenu = [_menuFactory createMenuWithCards:[BGHeroCard heroCardsWithHeroIds:heroIds]];
    _heroMenu.visible = NO;
    _heroMenu.position = POSITION_TO_BE_SELECTED_HERO;
    [_heroMenu alignItemsHorizontally];
    [self addChild:_heroMenu];
    
    void(^block)() = ^ {
        _heroMenu.visible = YES;
        [_player addProgressBar];
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
        case kActionDeckShowAllCuttedCards: // Show cutted card on deck
            [_gameLayer removeProgressBarForOtherPlayers];
            [self showCuttedCardWithCardIds:cardIds];
            break;
        
        case kActionUseHandCard:            // Show used/dropped card on deck
        case kActionChoseCardToUse:
        case kActionDeckShowDroppedCard:
        case kActionChoseCardToDrop:
            [self showUsedCardWithCardIds:cardIds];
            break;
            
        case kActionDeckShowTopPileCard:    // Show X cards of top pile(牌堆顶) on deck
            [self showXCardsOfTopPileWithCardIds:cardIds];
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
    
    [_gameLayer moveCardWithCardMenuItems:menuItems block:nil];
    [self makeUsedCardCenterAlignment];
}

/*
 * Show the used/dropped card of other player on the deck
 */
- (void)showUsedCardWithCardIds:(NSArray *)cardIds
{
    NSArray *cards = [BGPlayingCard playingCardsWithCardIds:cardIds];
    NSArray *menuItems = [_menuFactory createMenuItemsWithCards:cards];
    [menuItems enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        [obj setPosition:_gameLayer.currPlayer.position];
        [_cardMenu addChild:obj z:_cardMenu.children.count];
    }];
    
    [_gameLayer moveCardWithCardMenuItems:menuItems block:nil];
    [self makeUsedCardCenterAlignment];
}

/*
 * 1. Show all cutted cards of other players on the deck. So the index start from 1.
 *    (The cutted card of self player already showed on deck after used it)
 * 2. Send kStartRound request after action runing finished
 */
- (void)showCuttedCardWithCardIds:(NSArray *)cardIds
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
    NSArray *cards = [BGPlayingCard playingCardsWithCardIds:arrangedCardIds];
    void (^block)(id object) = ^(id object){
        NSUInteger idx = [_cardMenu.children indexOfObject:object];
        if (0 == idx) return;
        
        NSArray *array = [NSArray arrayWithObject:cards[idx]];
        [_menuFactory addMenuItemsWithCards:array toMenu:_cardMenu];
        CCMenuItem *menuItem = _cardMenu.children.lastObject;
        menuItem.visible = NO;
        menuItem.position = [object position];
        
        BGActionComponent *actionComp = [BGActionComponent actionComponentWithNode:object];
        ccTime duration = DURATION_CARD_FLIP+(idx-1)*DURATION_CARD_FLIP_INTERVAL;
        [actionComp runFlipFromLeftWithDuration:duration toNode:menuItem];
        
        if (++idx != cardIds.count) return;
        
//      If it is the last cutted card, scale up it.
        [_actionComp runDelayWithDuration:duration+DURATION_CARD_MOVE WithBlock:^{
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
                                               [[BGClient sharedClient] sendStartRoundRequest]; // 牌局开始
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
            [mutableCardIds addObjectsFromArray:[cardIds objectsAtIndexes:idxSet]];
            cardIds = mutableCardIds;
            break;
        }
        [idxSet addIndex:idx]; idx++;
    }
    
    return cardIds;
}

/*
 * Show X cards of top pile(牌堆顶) on the deck
 */
- (void)showXCardsOfTopPileWithCardIds:(NSArray *)cardIds
{
    NSString *image = [NSString stringWithFormat:@"%@%i", kImagePopupEnergyTransport,_gameLayer.allPlayers.count];
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

/*
 * Update deck with hand card count and equipment card
 * Faced down(暗置) all hand cards on the deck for being drew(比如贪婪)
 */
- (void)updateWithCardCount:(NSUInteger)count equipmentIds:(NSArray *)cardIds
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
        NSMutableArray *frameNames = [NSMutableArray arrayWithCapacity:count];
        for (NSUInteger i = 0; i < count; i++) {
            [frameNames addObject:kImagePlayingCardBack];
        }
        _handMenu = [_menuFactory createMenuWithSpriteFrameNames:frameNames];
//      If card count is great than 5, need narrow the padding.
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
 * Make each card on the deck center alignment
 */
- (void)makeUsedCardCenterAlignment
{
    if (kGameStateCutting == _gameLayer.state) {
        return;
    }
    
    void(^block)() = ^{
        NSUInteger addedCardCount = _cardMenu.children.count - _existingCardCount;
        CGPoint deltaPos = (_existingCardCount > 0) ? ccp(addedCardCount*PLAYING_CARD_WIDTH/2, 0.0f) : CGPointZero;
        
        [[_cardMenu.children getNSArray] enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            BGActionComponent *ac = [BGActionComponent actionComponentWithNode:obj];
            [ac runEaseMoveWithTarget:ccpAdd([obj position], deltaPos)
                             duration:DURATION_CARD_MOVE
                                block:nil];
        }];
    };
    
    [_actionComp runDelayWithDuration:DURATION_CARD_MOVE
                            WithBlock:block];
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
    
    NSUInteger idx = _gameLayer.targetPlayer.handCardCount - menuItem.tag - 1;
    [_player.selectedCardIdxes addObject:@(idx)];
    [self drawCardByTouchingMenuItem:menuItem];
}

/*
 * Draw(抽取) equipment of target player
 */
- (void)drawEquipmentByTouchingMenuItem:(CCMenuItem *)menuItem
{
    [_gameLayer.targetPlayer.equipmentArea updateEquipmentWithCardId:menuItem.tag];
    
    _player.drawableCardCount = 1;
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
    void(^block)() = ^{
        [_player.handArea makeHandCardLeftAlignment];
        
        if ([self isDrawingFinished]) {
            [[BGClient sharedClient] sendChoseCardToGetRequest];    // Send plugin reqeust
        }
    };
    
    menuItem.position = _gameLayer.targetPlayer.position;
    [_gameLayer moveCardWithCardMenuItems:[NSArray arrayWithObject:menuItem] block:block];
    
    if ([self isDrawingFinished]) {
        [_player removeProgressBar];
        [_handMenu.parent removeFromParent];
        [_equipMenu.parent removeFromParent];
    }
    
//  Update target player hand card count
    _gameLayer.targetPlayer.handCardCount--;
}

- (BOOL)isDrawingFinished
{
    return ((_player.selectedCardIdxes.count == _gameLayer.targetPlayer.handCardCount) ||
            (_player.selectedCardIdxes.count == _player.drawableCardCount));
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
