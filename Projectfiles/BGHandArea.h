//
//  BGHandArea.h
//  DotAHero
//
//  Created by Killua Liu on 6/14/13.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

#import "CCNode.h"
#import "BGPlayingCard.h"
#import "BGMenuFactory.h"

@class BGPlayer;

@interface BGHandArea : CCNode <BGMenuFactoryDelegate>

@property (nonatomic, strong) NSMutableArray *handCards;        // 现存的手牌
@property (nonatomic, strong) NSMutableArray *selectedCards;    // 选中的手牌
@property (nonatomic) NSUInteger selectableCardCount;           // 最多可以选择几张牌

- (id)initWithPlayer:(BGPlayer *)player andCardIds:(NSArray *)cardIds;
+ (id)handAreaWithPlayer:(BGPlayer *)player andCardIs:(NSArray *)cardIds;

- (void)updateHandCardWithCardIds:(NSArray *)cardIds;
- (void)enableHandCardWithCardIds:(NSArray *)cardIds;
- (void)enableAllHandCards;
- (void)disableAllHandCards;
- (void)makeHandCardLeftAlignment;

- (void)useHandCardWithAnimation:(BOOL)isRun block:(void (^)())block; // 主动|被动使用手牌
- (void)addAndFaceDownOneExtractedCardWith:(CCMenuItem *)menuItem;
- (void)giveSelectedCardsToTargetPlayerWithBlock:(void (^)())block;

@end
