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
@property (nonatomic) NSUInteger selectableCardCount;   // 最多可以选择几张牌


- (id)initWithPlayer:(BGPlayer *)player;
+ (id)handAreaWithPlayer:(BGPlayer *)player;

+ (NSArray *)playingCardsWithCardIds:(NSArray *)cardIds;
+ (NSArray *)playingCardIdsWithCards:(NSArray *)cards;

- (void)updateHandCardWithCardIds:(NSArray *)cardIds;

- (void)useHandCardWithAnimation:(BOOL)isRun block:(void (^)())block; // 主动/被动使用手牌



- (void)addHandCardsWithCardIds:(NSArray *)cardIds;
- (void)addOneExtractedCard;
- (void)gotExtractedCardsWithCardIds:(NSArray *)cardIds;
- (void)lostCardsWithCardIds:(NSArray *)cardIds;
- (void)removeHandCardsFromSelectedCards;

- (void)checkHandCardsAvailability;
- (void)enableAllHandCardsMenuItem;
- (void)disableAllHandCardsMenuItem;

- (void)giveSelectedCardsToTargetPlayerWithBlock:(void (^)())block;

- (void)renderFigureAndSuitsOfCards:(NSArray *)cards forMenu:(CCMenu *)menu;

@end
