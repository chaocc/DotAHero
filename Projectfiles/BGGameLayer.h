/*
 * Kobold2D™ --- http://www.kobold2d.org
 *
 * Copyright (c) 2010-2011 Steffen Itterheim. 
 * Released under MIT License in Germany (LICENSE-Kobold2D.txt).
 */

#import "kobold2d.h"
#import "ElectroServer.h"

@interface BGGameLayer : CCLayer

@property (nonatomic, strong) NSArray *players;     // [0] is current player
@property (nonatomic, strong) NSArray *heroIds;     // [0] is selected by current player
@property (nonatomic, readonly) ccTime gameDuration;

+ (BGGameLayer *)sharedGameLayer;
+ (id)scene;

- (void)transferRoleCardToNextPlayer;

@end
