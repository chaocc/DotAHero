/*
 * Kobold2D™ --- http://www.kobold2d.org
 *
 * Copyright (c) 2010-2011 Steffen Itterheim. 
 * Released under MIT License in Germany (LICENSE-Kobold2D.txt).
 */

#import "kobold2d.h"
#import "BGPlayingDeck.h"
#import "BGPlayer.h"

typedef NS_ENUM(NSUInteger, BGPlayerCount) {
    kPlayerCountTwo = 2,
    kPlayerCountThree,
    kPlayerCountFour,
    kPlayerCountFive,
    kPlayerCountSix,
    kPlayerCountSeven,
    kPlayerCountEight
};

@protocol BGGameLayerDelegate <NSObject>

- (void)remainingCardCountUpdate:(NSUInteger)count;

@end

@interface BGGameLayer : CCLayer

@property (nonatomic, weak) id<BGGameLayerDelegate> delegate;

@property (nonatomic, strong, readonly) CCSpriteBatchNode *gameArtworkBatch;

@property (nonatomic, strong, readonly) NSMutableArray *allPlayers; // Player instances
@property (nonatomic, strong, readonly) BGPlayer *selfPlayer;       // Self player
@property (nonatomic, strong, readonly) BGPlayer *currPlayer;       // 回合开始/伤害来源/出牌的玩家
@property (nonatomic, strong, readonly) BGPlayingDeck *playingDeck;

@property (nonatomic, copy) NSString *currPlayerName;               // 回合开始/伤害来源/出牌的玩家
@property (nonatomic, strong) NSMutableArray *targetPlayerNames;    // 指定的目标玩家们

@property (nonatomic) NSUInteger remainingCardCount;                // 牌堆剩余牌数
@property (nonatomic, readonly) ccTime gameDuration;

+ (BGGameLayer *)sharedGameLayer;
+ (id)scene;

- (void)renderOtherPlayersHeroWithHeroIds:(NSArray *)heroIds;
- (void)setHandCardCountForOtherPlayers;
- (void)addProgressBarForOtherPlayers;
- (void)removeProgressBarForOtherPlayers;
- (void)addProgressBarForCurrentPlayer;
- (void)removeProgressBarForCurrentPlayer;

- (BGPlayer *)playerWithName:(NSString *)playerName;

@end
