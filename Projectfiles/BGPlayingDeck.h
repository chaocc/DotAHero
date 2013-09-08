//
//  BGPlayingDeck.h
//  DotAHero
//
//  Created by Killua Liu on 7/20/13.
//
//

#import "CCNode.h"
#import "BGMenuFactory.h"

@class BGPlayer;

@interface BGPlayingDeck : CCNode <BGMenuFactoryDelegate>

//@property (nonatomic) BOOL isNeedClear; // 更新桌面之前是否要清除已有的卡牌
@property (nonatomic) NSInteger maxCardId;  // 最大点数的卡牌

+ (id)sharedPlayingDeck;

- (void)updateWithHeroIds:(NSArray *)heroIds;
- (void)updateWithCardIds:(NSArray *)cardIds;
- (void)updateWithCardMenuItems:(NSArray *)menuItems;
- (void)updateWithCardCount:(NSUInteger)count equipmentIds:(NSArray *)cardIds;

- (void)clearUsedCards;

@end
