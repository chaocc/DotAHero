//
//  BGHandArea.h
//  DotAHero
//
//  Created by Killua Liu on 6/14/13.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

#import "CCNode.h"
#import "BGMenuFactory.h"
#import "BGPlayingCard.h"

typedef NS_ENUM(NSUInteger, BGGreedType) {
    kGreedTypeHandCard = 4,     // 手牌
    kGreedTypeEquipment = 5     // 装备
};

@class BGPlayer;

@interface BGHandArea : CCNode <BGMenuFactoryDelegate>

@property (nonatomic, strong) NSMutableArray *playingCards;     // 现存的手牌
@property (nonatomic, strong) NSMutableArray *selectedCards;    // 选中的手牌

@property (nonatomic, readonly) CGPoint targetPosition; // 摸牌动画移动的目标位置
@property (nonatomic) NSUInteger canSelectCardCount;    // 最多可以选择几张牌

- (id)initWithPlayingCardIds:(NSArray *)cardIds ofPlayer:(BGPlayer *)player;
+ (id)handAreaWithPlayingCardIds:(NSArray *)cardIds ofPlayer:(BGPlayer *)player;

+ (NSArray *)playingCardsWithCardIds:(NSArray *)cardIds;
+ (NSArray *)playingCardIdsWithCards:(NSArray *)cards;

- (void)addPlayingCardsWithCardIds:(NSArray *)cardIds;
- (void)addAFacedDownPlayingCard;
- (void)gotAllFacedDownPlayingCardsWithCardIds:(NSArray *)cardIds;
- (void)removePlayingCards;
- (void)usePlayingCards;
- (void)usePlayingCardsAndRunAnimation;     // 使用/打出手牌并播放特效动画
- (void)lostPlayingCardsWithCardIds:(NSArray *)cardIds;

- (void)renderFigureAndSuitsOfCards:(NSArray *)cards forMenu:(CCMenu *)menu;

@end
