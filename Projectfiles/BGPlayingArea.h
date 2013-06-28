//
//  BGPlayingArea.h
//  DotAHero
//
//  Created by Killua Liu on 6/14/13.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

#import "CCNode.h"

@interface BGPlayingArea : CCNode

@property (nonatomic) NSUInteger playingCardCount;
@property (nonatomic, strong) NSMutableArray *playingCards;     // 现存的手牌
@property (nonatomic, strong) NSMutableArray *usedCards;        // 用掉或弃掉的手牌

- (id)initWithPlayingCards:(NSArray *)cards;
+ (id)playingAreaWithPlayingCards:(NSArray *)cards;

@end
