//
//  BGRoomListLayer.h
//  DotAHero
//
//  Created by Killua Liu on 6/19/13.
//
//

#import "CCLayer.h"

@interface BGRoomListLayer : CCLayer

+ (BGRoomListLayer *)sharedRoomListLayer;
+ (id)scene;

- (void)showRoomLayer;

@end
