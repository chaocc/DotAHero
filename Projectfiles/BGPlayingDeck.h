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

@property (nonatomic) BOOL isNeedClearDeck; // 更新桌面之前是否要清除已有的卡牌
@property (nonatomic, readonly) NSUInteger cardCount;

+ (id)sharedPlayingDeck;

- (void)updatePlayingDeckWithHeroIds:(NSArray *)heroIds;
- (void)updatePlayingDeckWithCardIds:(NSArray *)cardIds;
- (void)updatePlayingDeckWithCardMenuItems:(NSArray *)menuItems;
- (void)updatePlayingDeckWithCardCount:(NSUInteger)count equipmentIds:(NSArray *)cardIds;

- (void)clearUsedCardOnDeck;

@end
