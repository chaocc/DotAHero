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

@property (nonatomic, weak) BGPlayer *player;
@property (nonatomic, weak) BGPlayer *targetPlayer;
@property (nonatomic, strong) BGMenuFactory *menuFactory;
@property (nonatomic, strong) CCMenu *heroMenu;     // 待选的英雄
@property (nonatomic, strong) CCMenu *cardMenu;     // 使用/弃置的牌
@property (nonatomic, strong) CCMenu *handMenu;     // 目标手牌
@property (nonatomic, strong) CCMenu *equipMenu;    // 目标装备
@property (nonatomic) CGFloat cardPadding;

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
        _player = [BGGameLayer sharedGameLayer].currentPlayer;
        
        _menuFactory = [BGMenuFactory menuFactory];
        _cardMenu = [CCMenu menuWithItems:nil];
        [self addChild:_cardMenu];
        _menuFactory.delegate = self;
        
        _cardPadding = DEFAULT_CARD_PADDING;
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

#pragma mark - Deck updating
/*
 * Update deck with to be selected hero cards
 */
- (void)updatePlayingDeckWithHeroIds:(NSArray *)heroIds
{
    CCDelayTime *delay = [CCDelayTime actionWithDuration:0.21f];
    CCCallBlock *block = [CCCallBlock actionWithBlock:^{
        NSArray *heroCards = [self.class heroCardsWithHeroIds:heroIds];
        
        _heroMenu = [_menuFactory createMenuWithCards:heroCards];
        _heroMenu.position = TO_BE_SELECTED_HERO_POSITION;
        [_heroMenu alignItemsHorizontally];
        [self addChild:_heroMenu];
        
        [_heroMenu runAction:[CCFadeIn actionWithDuration:0.1f]];
        
        [_player addProgressBarWithPosition:HERO_SELECTION_PROGRESS_BAR_POS
                                      block:^{
                                          [_heroMenu removeFromParentAndCleanup:YES];
                                          [_player removeProgressBar];
                                      }];
    }];
    [self runAction:[CCSequence actions:delay, block, nil]];
}

/*
 * Update deck with used/discarded hand cards. Clear deck after one card effect was resolved(结算)
 */
- (void)updatePlayingDeckWithCardIds:(NSArray *)cardIds
{
    if (_isNeedClearDeck) {
        [_cardMenu removeAllChildrenWithCleanup:YES];
        _isNeedClearDeck = NO;  // Restore default value
    }
    
    if (_player.action == kActionUpdateDeckUsedCard) {  // Show used card on deck
        NSArray *cards = [BGHandArea playingCardsWithCardIds:cardIds];
        [_menuFactory addMenuItemsWithCards:cards toMenu:_cardMenu];
        [_cardMenu alignItemsHorizontally];
        _cardMenu.position = USED_CARD_POSITION;
        [_player.handArea renderFigureAndSuitsOfCards:cards forMenu:_cardMenu];
    }
    else {                                              // Show X cards of top pile(牌堆顶) on deck
//      更新桌面: 能量转移
    }
}

/*
 * Update deck with hand card count and equipment card
 * Faced down(暗置) all hand cards on the deck for being extracted(比如贪婪)
 */
- (void)updatePlayingDeckWithCardCount:(NSUInteger)count equipmentIds:(NSArray *)cardIds
{
    if (count != 0) {
        CGFloat cardWidth = [[CCSprite spriteWithSpriteFrameName:kImagePlayingCardBack] contentSize].width;
        
//      If card count is great than 6, need narrow the padding.
        if (count > 6) {
            _cardPadding = -(cardWidth*(count-6) / (count-1));
        }
        
        NSMutableArray *frameNames = [NSMutableArray arrayWithCapacity:count];
        for (NSUInteger i = 0 ; i < count; i++) {
            [frameNames addObject:kImagePlayingCardBack];
        }
        
        _handMenu = [_menuFactory createMenuWithSpriteFrameNames:frameNames
                                              selectedFrameNames:nil
                                              disabledFrameNames:nil];
        _handMenu.position = EXTRACTED_HAND_CARD_POSITION;
        [_handMenu alignItemsHorizontallyWithPadding:_cardPadding];
        [self addChild:_handMenu];
    }
    
//  Add equipment cards of target player on the deck if equipped
    if (cardIds.count != 0) {
        _equipMenu = [_menuFactory createMenuWithCards:_player.equipmentArea.equipmentCards];
        _equipMenu.position = EXTRACTED_EQUIPMENT_POSITION;
        [_equipMenu alignItemsHorizontally];
        [self addChild:_equipMenu];
    }
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
    
    BGMoveComponent *moveComp = [BGMoveComponent moveWithTarget:ccp(-SCREEN_WIDTH*0.4, -SCREEN_HEIGHT*0.4)
                                                         ofNode:menuItem];
    [moveComp runActionEaseMoveScaleWithDuration:0.5f
                                           scale:0.5f
                                           block:^{
                                               [menuItem.parent removeFromParentAndCleanup:YES];
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
    BGMoveComponent *moveComp = [BGMoveComponent moveWithTarget:targetPos
                                                         ofNode:menuItem];
    
    [moveComp runActionEaseMoveWithDuration:CARD_MOVE_DURATION
                                      block:^{
                                          [menuItem removeFromParentAndCleanup:YES];
                                          [_handMenu alignItemsHorizontallyWithPadding:_cardPadding];
                                          
                                          [_player.handArea addOneExtractedCardAndFaceDown];
                                          
                                          // Extracted card count can't great than all hand card count
                                          if ((_player.selectedCardIdxes.count == _targetPlayer.handCardCount) ||
                                              (_player.selectedCardIdxes.count == _player.canExtractCardCount))
                                          {
                                              [_handMenu removeFromParentAndCleanup:YES];
                                              [_equipMenu removeFromParentAndCleanup:YES];
                                              [[BGClient sharedClient] sendChooseCardRequest];  // Send plugin reqeust
                                          }
                                      }];
}

@end
