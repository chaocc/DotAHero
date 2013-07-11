//
//  BGRoomListLayer.h
//  DotAHero
//
//  Created by Killua Liu on 6/19/13.
//
//

#import "CCLayer.h"
#import "BGLoginLayer.h"

@interface BGRoomListLayer : CCLayer

@property (strong, nonatomic, readonly) ElectroServer *es;

+ (BGRoomListLayer *)sharedRoomListLayer;
+ (id)scene;

@end
