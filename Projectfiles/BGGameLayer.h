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

typedef NS_ENUM(NSUInteger, BGGameState) {
    kGameStateInvalid = 0,
    kGameStateCutting = 1,      // 切牌阶段
//    kGameStateDrawing,          // 摸牌阶段
    kGameStatePlaying,          // 主动出牌阶段
    kGameStateChoosing,         // 被动出牌阶段
    kGameStateLosing,           // 丢牌阶段
    kGameStateGetting,          // 抽牌阶段
    kGameStateGiving,           // 给牌阶段
    kGameStateDiscarding        // 弃牌阶段
};

@protocol BGGameLayerDelegate <NSObject>

- (void)remainingCardCountUpdate:(NSUInteger)count;

@end

@interface BGGameLayer : CCLayer

@property (nonatomic) BGAction action;
@property (nonatomic) BGGameState state;

@property (nonatomic, weak) id<BGGameLayerDelegate> delegate;

@property (nonatomic, strong, readonly) CCSpriteBatchNode *gameArtworkBatch;

@property (nonatomic, strong, readonly) NSMutableArray *allPlayers; // Player instances
@property (nonatomic, strong, readonly) BGPlayer *selfPlayer;       // Self player
@property (nonatomic, strong, readonly) BGPlayer *currPlayer;
@property (nonatomic, strong, readonly) NSArray *targetPlayers;
@property (nonatomic, strong, readonly) BGPlayer *targetPlayer;
@property (nonatomic, strong, readonly) BGPlayingDeck *playingDeck;

@property (nonatomic, copy) NSString *currPlayerName;               // 回合开始/伤害来源/出牌的玩家
@property (nonatomic, strong) NSMutableArray *targetPlayerNames;    // 指定的目标玩家们

@property (nonatomic) NSUInteger remainingCardCount;                // 牌堆剩余牌数
@property (nonatomic, readonly) NSUInteger playerCount;
@property (nonatomic, readonly) ccTime gameDuration;

+ (BGGameLayer *)sharedGameLayer;
+ (id)scene;

- (BGPlayer *)playerWithName:(NSString *)playerName;

- (void)mapActionToGameState;

- (void)renderOtherPlayersHeroWithHeroIds:(NSArray *)heroIds;
- (void)addProgressBarForOtherPlayers;
- (void)removeProgressBarForOtherPlayers;
- (void)enablePlayerAreaForOtherPlayers;
- (void)disablePlayerAreaForOtherPlayers;

- (void)makeBackgroundColorToDark;
- (void)makeBackgroundColorToNormal;
- (void)setColorWith:(ccColor3B)color ofNode:(CCNode *)node;

- (void)moveCardWithCardMenu:(CCMenu *)menu toTargerPlayer:(BGPlayer *)player block:(void(^)())block;
- (void)moveCardWithCardMenuItems:(NSArray *)menuItems block:(void(^)(id object))block;

@end
