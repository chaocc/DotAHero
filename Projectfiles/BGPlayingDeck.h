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

@property (nonatomic, strong, readonly) CCMenu *usedCardMenu;

+ (id)sharedPlayingDeck;

- (void)updatePlayingDeckWithHeroIds:(NSArray *)heroIds;
- (void)updatePlayingDeckWithCardIds:(NSArray *)cardIds;

- (void)showAllCuttingCardsWithCardIds:(NSArray *)cardIds;
- (void)showUsedHandCardsWithCardIds:(NSArray *)cardIds;
- (void)facedDownAllHandCardsOfPlayer:(BGPlayer *)player;
- (void)addEquipmentCardsOfTargetPlayer:(BGPlayer *)player;

@end
