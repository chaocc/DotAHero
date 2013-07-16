//
//  BGRoomLayer.h
//  DotAHero
//
//  Created by Killua Liu on 6/14/13.
//
//

#import "CCLayer.h"
#import "BGRoomListLayer.h"

@interface BGRoomLayer : CCLayer

@property (nonatomic) BOOL isRoomOwner;

+ (BGRoomLayer *)sharedRoomLayer;
+ (id)scene;

- (void)readyStartGame;
- (void)showGameLayer;

@end
