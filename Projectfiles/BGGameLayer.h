/*
 * Kobold2D™ --- http://www.kobold2d.org
 *
 * Copyright (c) 2010-2011 Steffen Itterheim. 
 * Released under MIT License in Germany (LICENSE-Kobold2D.txt).
 */

#import "kobold2d.h"
#import "BGPlayer.h"

@protocol BGGameLayerDelegate <NSObject>

- (void)remainingCardCountUpdate:(NSUInteger)count;

@end

@interface BGGameLayer : CCLayer

@property (nonatomic, weak) id<BGGameLayerDelegate> delegate;

@property (nonatomic, strong, readonly) CCSpriteBatchNode *gameArtworkBatch;

@property (nonatomic, strong, readonly) NSMutableArray *allPlayers; // Player instances
@property (nonatomic, strong, readonly) BGPlayer *selfPlayer;       // Player Self
@property (nonatomic, strong, readonly) BGPlayer *sourcePlayer;    // 回合开始/伤害来源/出牌的玩家
@property (nonatomic, copy) NSString *sourcePlayerName;            // 回合开始/伤害来源/出牌的玩家
@property (nonatomic, strong) NSMutableArray *targetPlayerNames;    // 指定的目标玩家们

@property (nonatomic) NSUInteger remainingCardCount;                // 牌堆剩余牌数
@property (nonatomic, readonly) ccTime gameDuration;

+ (BGGameLayer *)sharedGameLayer;
+ (id)scene;

- (BGPlayer *)playerWithName:(NSString *)playerName;

- (void)dealHeroCardsWithHeroIds:(NSArray *)toBeSelectedHeroIds;
- (void)sendAllSelectedHeroCardsWithHeroIds:(NSArray *)allHeroIds;
- (void)dealPlayingCardsWithCardIds:(NSArray *)cardIds;
- (void)showAllCuttingCardsWithCardIds:(NSArray *)cardIds;

- (void)transferRoleCardToNextPlayer;

@end
