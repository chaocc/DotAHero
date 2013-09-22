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
@property (nonatomic, readonly) NSUInteger allCardCount;
@property (nonatomic, readonly) NSUInteger existingCardCount;

+ (id)sharedPlayingDeck;

- (void)updateWithHeroIds:(NSArray *)heroIds;
- (void)updateWithCardIds:(NSArray *)cardIds;
- (void)updateWithCardMenuItems:(NSArray *)menuItems;
- (void)updateWithHandCardCount:(NSUInteger)count equipmentIds:(NSArray *)cardIds;

- (void)removeResidualNodes;
- (void)clearExistingUsedCards;

@end
