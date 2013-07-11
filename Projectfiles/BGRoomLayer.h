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

@property (strong, nonatomic, readonly) ElectroServer *es;
@property (nonatomic, strong) EsRoom *room;
@property (nonatomic, strong) NSArray *users;           // [0] is current user

+ (BGRoomLayer *)sharedRoomLayer;
+ (id)scene;

- (void)sendPluginRequestWithObject:(EsObject *)obj pluginName:(NSString *)name andEventListener:(id)target;
- (void)sendStartGameRequestWithEventListener:(id)target;

@end
