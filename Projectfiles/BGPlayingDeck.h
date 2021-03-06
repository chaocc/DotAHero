//
//  BGPlayingDeck.h
//  DotAHero
//
//  Created by Killua Liu on 7/20/13.
//
//

#import "CCNode.h"
#import "BGMenuFactory.h"
#import "BGPlayingMenu.h"

@interface BGPlayingDeck : CCNode <BGMenuFactoryDelegate, BGPlayingMenuDelegate>

@property (nonatomic, strong, readonly) CCMenu *heroMenu;   // 待选的英雄
@property (nonatomic, strong, readonly) CCMenu *cardMenu;   // 使用|弃置的牌
@property (nonatomic, strong, readonly) CCMenu *handMenu;   // 目标手牌
@property (nonatomic, strong, readonly) CCMenu *equipMenu;  // 目标装备
@property (nonatomic, strong, readonly) CCMenu *pileMenu;   // 牌堆牌

+ (id)sharedPlayingDeck;

- (void)showToBeSelectedHerosWithHeroIds:(NSArray *)heroIds;
- (void)showCuttedCardWithCardIds:(NSArray *)cardIds maxCardId:(NSInteger)maxCardId;
- (void)showUsedCardWithCardMenuItems:(NSArray *)menuItems;
- (void)showUsedCardWithCardIds:(NSArray *)cardIds;
- (void)showFacedDownCardWithCount:(NSUInteger)count;
- (void)showTopPileCardWithCardIds:(NSArray *)cardIds;
- (void)showPopupWithHandCount:(NSUInteger)count equipmentIds:(NSArray *)cardIds;
- (void)showPopupWithAssignedCardIds:(NSArray *)cardIds;

- (void)selectHeroByTouchingMenuItem:(CCMenuItem *)menuItem;
- (void)drawHandCardWithMenuItems:(NSArray *)menuItems;
- (void)drawEquipmentWithMenuItems:(NSArray *)menuItems;
- (void)assignCardToEachPlayer;

- (CGPoint)cardMoveTargetPositionWithIndex:(NSUInteger)idx;
- (CGPoint)cardMoveTargetPositionWithIndex:(NSUInteger)idx count:(NSUInteger)count;

- (void)removeResidualNodes;
- (void)clearAllExistingCards;

@end
