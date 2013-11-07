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
    kGameStateStarting = 1,         // 游戏开始阶段-选择英雄
    kGameStateCutting = 2,          // 切牌阶段
    kGameStatePlaying = 3,          // 主动出牌阶段
    kGameStateChoosingCard = 4,     // 被动出牌阶段
    kGameStateChoosingColor = 5,    // 选择颜色阶段
    kGameStateChoosingSuits = 6,    // 选择花色阶段
    kGameStateGetting = 7,          // 抽牌阶段
    kGameStateGiving = 8,           // 给牌阶段
    kGameStateRemoving = 9,         // 拆牌阶段
    kGameStateAssigning = 10,       // 分牌阶段
    kGameStateDiscarding = 11,      // 弃牌阶段
    kGameStateDying = 12            // 濒死阶段
};

@protocol BGGameLayerDelegate <NSObject>

- (void)remainingCardCountUpdate:(NSUInteger)count;

@end

@interface BGGameLayer : CCLayer

@property (nonatomic) BGAction action;
@property (nonatomic) BGGameState state;
@property (nonatomic, copy) NSString *reason;

@property (nonatomic, weak) id<BGGameLayerDelegate> delegate;

@property (nonatomic, strong, readonly) CCSpriteBatchNode *gameArtworkBatch;

@property (nonatomic, strong, readonly) NSMutableArray *allPlayers;
@property (nonatomic, strong, readonly) NSArray *targetPlayers;
@property (nonatomic, strong, readonly) BGPlayer *player;           // 玩家自己
@property (nonatomic, strong, readonly) BGPlayer *turnOwner;        // 回合开始的玩家
@property (nonatomic, strong, readonly) BGPlayer *targetPlayer;
@property (nonatomic, strong, readonly) BGPlayingDeck *playingDeck;

@property (nonatomic, copy) NSString *turnOwnerName;                // 回合开始/伤害来源的玩家
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
- (void)moveCardWithCardMenuItem:(CCMenuItem *)menuItem toPlayer:(BGPlayer *)player block:(void(^)())block;
- (void)moveCardWithCardMenuItems:(NSArray *)menuItems block:(void(^)(id object))block;

@end
