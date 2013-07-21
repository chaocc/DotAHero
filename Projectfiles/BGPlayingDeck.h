//
//  BGPlayingDeck.h
//  DotAHero
//
//  Created by Killua Liu on 7/20/13.
//
//

#import "CCNode.h"

@class BGPlayer;

@interface BGPlayingDeck : CCNode

- (id)initWithPlayer:(BGPlayer *)player;
+ (id)playingDeckWithPlayer:(BGPlayer *)player;

- (void)addAllCuttingCardsWithCardIds:(NSArray *)cardIds;
- (void)addAllFacedDownPlayingCardsOfTargetPlayer;

@end
