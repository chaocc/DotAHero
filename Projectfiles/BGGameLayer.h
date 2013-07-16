/*
 * Kobold2D™ --- http://www.kobold2d.org
 *
 * Copyright (c) 2010-2011 Steffen Itterheim. 
 * Released under MIT License in Germany (LICENSE-Kobold2D.txt).
 */

#import "kobold2d.h"
#import "BGPlayer.h"

@interface BGGameLayer : CCLayer

@property (nonatomic, strong, readonly) CCSpriteBatchNode *gameArtworkBatch;

@property (nonatomic, strong, readonly) NSMutableArray *players;    // Player instances
@property (nonatomic, strong, readonly) BGPlayer *currentPlayer;    // Player Self
@property (nonatomic, copy) NSString *playerName;                   // 回合开始/出牌的玩家
@property (nonatomic, strong) NSMutableArray *targetPlayerNames;    // 指定的目标玩家们

@property (nonatomic, readonly) ccTime gameDuration;

+ (BGGameLayer *)sharedGameLayer;
+ (id)scene;

- (void)dealHeroCards:(NSArray *)toBeSelectedHeroIds;
- (void)sendAllHeroIds:(NSArray *)allHeroIds;
- (void)transferRoleCardToNextPlayer;

@end
