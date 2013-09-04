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

@class BGPlayer;

@interface BGHandArea : CCNode <BGMenuFactoryDelegate>

@property (nonatomic, strong) NSMutableArray *handCards;        // 现存的手牌
@property (nonatomic, strong) NSMutableArray *selectedCards;    // 选中的手牌

@property (nonatomic) NSUInteger selectableCardCount;   // 最多可以选择几张牌

@property (nonatomic, readonly) CGPoint targetPosition; // 摸牌动画移动的目标位置
@property (nonatomic, readonly) CGFloat cardWidth;
@property (nonatomic, readonly) CGFloat cardHeight;

- (id)initWithPlayer:(BGPlayer *)player andCardIds:(NSArray *)cardIds;
+ (id)handAreaWithPlayer:(BGPlayer *)player andCardIs:(NSArray *)cardIds;

+ (NSArray *)playingCardsWithCardIds:(NSArray *)cardIds;
+ (NSArray *)playingCardIdsWithCards:(NSArray *)cards;

- (void)updateHandCardWithCardIds:(NSArray *)cardIds;
- (void)enableHandCardWithCardIds:(NSArray *)cardIds;
- (void)enableAllHandCards;
- (void)disableAllHandCards;
- (void)adjustPositionOfHandCards;

- (void)renderFigureAndSuitsOfCards:(NSArray *)cards forMenu:(CCMenu *)menu;
- (CGFloat)cardPaddingWithCardCount:(NSUInteger)cardCount maxCount:(NSUInteger)maxCount;

- (void)useHandCardWithAnimation:(BOOL)isRun block:(void (^)())block; // 主动/被动使用手牌
- (void)addOneExtractedCardAndFaceDown;
- (void)giveSelectedCardsToTargetPlayerWithBlock:(void (^)())block;

- (void)removeHandCardsFromSelectedCards;

@end
