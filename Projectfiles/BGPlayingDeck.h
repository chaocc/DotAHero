//
//  BGPlayingDeck.h
//  DotAHero
//
//  Created by Killua Liu on 7/20/13.
//
//

#import "CCNode.h"
#import "BGMenuFactory.h"

@interface BGPlayingDeck : CCNode <BGMenuFactoryDelegate>

@property (nonatomic) NSInteger maxCardId;  // 最大点数的卡牌

+ (id)sharedPlayingDeck;

- (void)showToBeSelectedHerosWithHeroIds:(NSArray *)heroIds;
- (void)showCuttedCardWithCardIds:(NSArray *)cardIds;
- (void)showUsedWithCardMenuItems:(NSArray *)menuItems;
- (void)showUsedCardWithCardIds:(NSArray *)cardIds;
- (void)showFacedDownCardWithCount:(NSUInteger)count;
- (void)showTopPileCardWithCardIds:(NSArray *)cardIds;
- (void)showPlayerHandCardWithCount:(NSUInteger)count equipmentIds:(NSArray *)cardIds;
- (void)showAssignedCardsWithCardIds:(NSArray *)cardIds;

- (void)moveCardWithCardMenuItems:(NSArray *)menuItems;
- (CGPoint)cardPositionWithIndex:(NSUInteger)idx;
- (CGPoint)cardPositionWithIndex:(NSUInteger)idx count:(NSUInteger)count;

- (void)removeResidualNodes;
- (void)clearExistingCards;

@end
