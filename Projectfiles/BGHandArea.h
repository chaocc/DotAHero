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
    kGreedTypeEquipment = 4,    // 装备
    kGreedTypeHandCard = 5,     // 手牌
};

@class BGPlayer;

@interface BGHandArea : CCNode <BGMenuFactoryDelegate>

@property (nonatomic, strong) NSMutableArray *handCards;        // 现存的手牌
@property (nonatomic, strong) NSMutableArray *selectedCards;    // 选中的手牌

@property (nonatomic, readonly) CGPoint targetPosition; // 摸牌动画移动的目标位置
@property (nonatomic) NSUInteger canSelectCardCount;    // 最多可以选择几张牌

- (id)initWithPlayingCardIds:(NSArray *)cardIds ofPlayer:(BGPlayer *)player;
+ (id)handAreaWithPlayingCardIds:(NSArray *)cardIds ofPlayer:(BGPlayer *)player;

+ (NSArray *)playingCardsWithCardIds:(NSArray *)cardIds;
+ (NSArray *)playingCardIdsWithCards:(NSArray *)cards;

- (void)addHandCardsWithCardIds:(NSArray *)cardIds;
- (void)addOneExtractedHandCard;
- (void)gotExtractedHandCardsWithCardIds:(NSArray *)cardIds;
- (void)lostHandCardsWithCardIds:(NSArray *)cardIds;
- (void)removeHandCardsFromSelectedCards;

- (void)useHandCardsWithBlock:(void (^)())block;
- (void)useHandCardsAndRunAnimationWithBlock:(void (^)())block;     // 使用/打出手牌并播放动画特效
- (void)giveSelectedCardsToTargetPlayerWithBlock:(void (^)())block;

- (void)renderFigureAndSuitsOfCards:(NSArray *)cards forMenu:(CCMenu *)menu;

@end
