//
//  BGPlayingDeck.m
//  DotAHero
//
//  Created by Killua Liu on 7/20/13.
//
//

#import "BGPlayingDeck.h"
#import "BGClient.h"
#import "BGPlayer.h"
#import "BGPlayingCard.h"
#import "BGHandArea.h"
#import "BGDefines.h"
#import "BGFileConstants.h"
#import "BGMoveComponent.h"

@interface BGPlayingDeck ()

@property (nonatomic, weak) BGPlayer *player;
@property (nonatomic, weak) BGPlayer *targetPlayer;
@property (nonatomic, strong) BGMenuFactory *menuFactory;
@property (nonatomic, strong) CCMenu *handMenu;
@property (nonatomic, strong) CCMenu *equipMenu;
@property (nonatomic) CGFloat cardPadding;

@end

@implementation BGPlayingDeck

- (id)initWithPlayer:(BGPlayer *)player
{
    if (self = [super init]) {
        _player = player;
        
        _menuFactory = [BGMenuFactory menuFactory];
        _usedCardMenu = [CCMenu menuWithItems:nil];
        [self addChild:_usedCardMenu];
        _menuFactory.delegate = self;
        
        _cardPadding = DEFAULT_CARD_PADDING;
    }
    return self;
}

+ (id)playingDeckWithPlayer:(BGPlayer *)player
{
    return [[self alloc] initWithPlayer:player];
}

/*
 * Show all cutting(切牌) cards on the playing deck
 */
- (void)showAllCuttingCardsWithCardIds:(NSArray *)cardIds
{
    [self showUsedHandCardsWithCardIds:cardIds];
}

/*
 * Show used hand cards on the playing deck. Clean deck after one card effect was resolved(结算)
 */
- (void)showUsedHandCardsWithCardIds:(NSArray *)cardIds
{
    NSArray *cards = [BGHandArea playingCardsWithCardIds:cardIds];
    
    [_menuFactory addMenuItemsWithCards:cards toMenu:_usedCardMenu];
    [_usedCardMenu alignItemsHorizontally];
    _usedCardMenu.position = USED_CARD_POSITION;
    
    [_player.handArea renderFigureAndSuitsOfCards:cards forMenu:_usedCardMenu];
}

/*
 * Faced down(暗置) all hand cards on the playing deck for being extracted(比如贪婪)
 */
- (void)facedDownAllHandCardsOfPlayer:(BGPlayer *)player
{
    _targetPlayer = player;
    
    NSUInteger cardCount = player.handCardCount;
    CGFloat cardWidth = [[CCSprite spriteWithSpriteFrameName:kImagePlayingCardBack] contentSize].width;
    
//  If card count is great than 6, need narrow the padding.
    if (cardCount > 6) {
        _cardPadding = -(cardWidth*(cardCount-6) / (cardCount-1));
    }
    
    NSMutableArray *frameNames = [NSMutableArray arrayWithCapacity:cardCount];
    for (NSUInteger i = 0 ; i < cardCount; i++) {
        [frameNames addObject:kImagePlayingCardBack];
    }
    
    _handMenu = [_menuFactory createMenuWithSpriteFrameNames:frameNames
                                          selectedFrameNames:nil
                                          disabledFrameNames:nil];
    _handMenu.position = EXTRACTED_HAND_CARD_POSITION;
    [_handMenu alignItemsHorizontallyWithPadding:_cardPadding];
    [self addChild:_handMenu];
}

/*
 * Extract(抽取) a hand card of target player by touch card menu item
 * If only have one hand card, end directly after extracted.
 */
//- (void)extractCardByTouchMenuItem:(CCMenuItem *)menuItem
//{
//    NSUInteger idx = _targetPlayer.handCardCount - menuItem.tag - 1;
//    [_player.extractedCardIdxes addObject:@(idx)];
//    
//    BGMoveComponent *moveComp = [BGMoveComponent moveWithTarget:_player.handArea.targetPosition
//                                                         ofNode:menuItem];
//    [moveComp runActionEaseMoveWithDuration:CARD_MOVE_DURATION
//                                      block:^{
//                                          [menuItem removeFromParentAndCleanup:YES];
//                                          [_handMenu alignItemsHorizontallyWithPadding:_cardPadding];
//                                          [_player.handArea addOneExtractedHandCard];
//                                          
//                                          // Extracted card count can't great than all hand card count
//                                          if ((_player.extractedCardIdxes.count == _targetPlayer.handCardCount) ||
//                                              (_player.extractedCardIdxes.count == _player.canExtractCardCount)) {
//                                              _player.selectedGreedType = kGreedTypeHandCard;
//                                              [_handMenu removeAllChildrenWithCleanup:YES];
//                                              
//                                              if (!_player.isSelectedStrenthen) {   // 没有强化
//                                                  [[BGClient sharedClient] sendExtractCardRequest]; // Send plugin reqeust
//                                              }
//                                              
//                                              NSAssert(_player.playingMenu, @"Nil in selector %@", NSStringFromSelector(_cmd));
//                                              [_player.playingMenu createOkayPlayingMenu];
//                                          }
//                                      }];
//}

/*
 * Add equipment cards of target player on the deck
 */
- (void)addEquipmentCardsOfTargetPlayer:(BGPlayer *)player
{
    _targetPlayer = player;
    
    _equipMenu = [_menuFactory createMenuWithCards:_player.equipmentArea.equipmentCards];
    _equipMenu.position = EXTRACTED_EQUIPMENT_POSITION;
    [_equipMenu alignItemsHorizontally];
    [self addChild:_equipMenu];
}

#pragma mark - Cards touching
/*
 * Extract(抽取) a hand card of target player by touch card menu item
 * Select extracting hand card or equipment of target player
 */
- (void)menuItemTouched:(CCMenuItem *)menuItem
{
    if ([menuItem.parent isEqual:_handMenu]) {          // 手牌
        NSUInteger idx = _targetPlayer.handCardCount - menuItem.tag - 1;
        [_player.extractedCardIdxes addObject:@(idx)];
        _player.selectedGreedType = kGreedTypeHandCard;
    }
    else if ([menuItem.parent isEqual:_equipMenu]) {    // 装备
        _player.canExtractCardCount = 1;
        _player.extractedCardIdxes = [NSArray arrayWithObject:@(menuItem.tag)];
        _player.selectedGreedType = kGreedTypeEquipment;
    }
    
    CGPoint targetPosition = ccp(_player.playerAreaSize.width*0.31, -_player.playerAreaSize.height*0.88);
    BGMoveComponent *moveComp = [BGMoveComponent moveWithTarget:targetPosition
                                                         ofNode:menuItem];
    
    [moveComp runActionEaseMoveWithDuration:CARD_MOVE_DURATION
                                      block:^{
                                          [menuItem removeFromParentAndCleanup:YES];
                                          [_handMenu alignItemsHorizontallyWithPadding:_cardPadding];
                                          
                                          [_player.handArea addOneExtractedCard];
                                          
                                          // Extracted card count can't great than all hand card count
                                          if ((_player.extractedCardIdxes.count == _targetPlayer.handCardCount) ||
                                              (_player.extractedCardIdxes.count == _player.canExtractCardCount))
                                          {
                                              [_handMenu removeFromParentAndCleanup:YES];
                                              [_equipMenu removeFromParentAndCleanup:YES];
                                              
                                              if (_player.isSelectedStrenthen) {    // 强化
                                                  [_player addPlayingMenuOfCardGiving];
                                              } else {
                                                  [[BGClient sharedClient] sendExtractCardRequest]; // Send plugin reqeust
                                              }
                                          }
                                      }];
}

@end
