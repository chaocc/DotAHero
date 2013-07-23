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

@property (nonatomic, strong, readonly) CCMenu *cardMenu;

- (id)initWithPlayer:(BGPlayer *)player;
+ (id)playingDeckWithPlayer:(BGPlayer *)player;

- (void)showAllCuttingCardsWithCardIds:(NSArray *)cardIds;
- (void)showUsedHandCardsWithCardIds:(NSArray *)cardIds;
- (void)facedDownAllHandCardsOfPlayer:(BGPlayer *)player;
- (void)addEquipmentCardsOfTargetPlayer;

@end
