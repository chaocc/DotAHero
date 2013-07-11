//
//  BGPlayingArea.h
//  DotAHero
//
//  Created by Killua Liu on 6/14/13.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

#import "CCNode.h"
#import "BGMenuFactory.h"

@class BGPlayer;

@interface BGPlayingArea : CCNode <BGMenuFactoryDelegate>

//@property (nonatomic) NSUInteger playingCardCount;
@property (nonatomic, strong) NSMutableArray *playingCards;     // 现存的手牌
@property (nonatomic, strong) NSMutableArray *selectedCards;
@property (nonatomic, strong) NSMutableArray *usedCards;        // 用掉或弃掉的手牌

@property (nonatomic) NSUInteger canBeSelectedCardCount;

- (id)initWithPlayingCardIds:(NSArray *)cardIds ofPlayer:(BGPlayer *)player;
+ (id)playingAreaWithPlayingCardIds:(NSArray *)cardIds ofPlayer:(BGPlayer *)player;

- (void)addPlayingCardsWithCardIds:(NSArray *)cardIds;
- (void)removePlayingCardsWithCardIds:(NSArray *)cardIds;

@end
