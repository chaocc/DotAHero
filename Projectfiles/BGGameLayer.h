/*
 * Kobold2D™ --- http://www.kobold2d.org
 *
 * Copyright (c) 2010-2011 Steffen Itterheim. 
 * Released under MIT License in Germany (LICENSE-Kobold2D.txt).
 */

#import "kobold2d.h"
#import "BGRoomLayer.h"

@interface BGGameLayer : CCLayer

@property (nonatomic, strong, readonly) CCSpriteBatchNode *gameArtworkBatch;

@property (strong, nonatomic, readonly) ElectroServer *es;
@property (nonatomic, strong, readonly) NSArray *users;               // [0] is current user
@property (nonatomic, strong, readonly) NSArray *allHeroIds;          // [0] is selected by current user
@property (nonatomic, strong, readonly) NSMutableArray *players;      // Player instances

@property (nonatomic, readonly) ccTime gameDuration;

+ (BGGameLayer *)sharedGameLayer;
+ (id)scene;

- (void)transferRoleCardToNextPlayer;

@end
