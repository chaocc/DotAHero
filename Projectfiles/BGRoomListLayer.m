//
//  BGRoomListLayer.m
//  DotAHero
//
//  Created by Killua Liu on 6/19/13.
//
//

#import "BGRoomListLayer.h"
#import "BGRoomLayer.h"

@interface BGRoomListLayer ()



@end

@implementation BGRoomListLayer 

static BGRoomListLayer *instanceOfRoomListLayer = nil;

+ (BGRoomListLayer *)sharedRoomListLayer
{
    NSAssert(instanceOfRoomListLayer, @"RoomListLayer instance not yet initialized!");
	return instanceOfRoomListLayer;
}

+ (id)scene
{
	CCScene* scene = [CCScene node];
	CCLayer* layer = [BGRoomListLayer node];
	[scene addChild:layer];
    
	return scene;
}

- (id)init
{
    if (self = [super init]) {
        instanceOfRoomListLayer = self;
        
        _es = [BGLoginLayer sharedLoginLayer].es;
        
        [self joinRoom];
    }
    return self;
}

// ...TODO...
// showRoomList
// joinExistingRoom

- (void)joinRoom
{
    [_es.engine addEventListenerWithTarget:self action:@selector(onJoinRoomEvent:) eventIdentifier:EsMessageType_JoinRoomEvent];
    
    EsCreateRoomRequest *crr = [[EsCreateRoomRequest alloc] init];
    crr.roomName = @"TestRoom";
    crr.zoneName = @"TestZone";
    
    EsPluginListEntry *pleRoom = [[EsPluginListEntry alloc] init];
    pleRoom.extensionName = @"ChatLogger";
    pleRoom.pluginHandle = @"ChatPlugin";
    pleRoom.pluginName = @"ChatPlugin";
    
    EsPluginListEntry *pleGame = [[EsPluginListEntry alloc] init];
    pleGame.extensionName = @"ChatLogger";
    pleGame.pluginHandle = @"GamePlugin";
    pleGame.pluginName = @"GamePlugin";
    
    crr.plugins = [NSMutableArray arrayWithObjects:pleRoom, pleGame, nil];
    
    [_es.engine sendMessage:crr];
}

- (void)onJoinRoomEvent:(EsJoinRoomEvent *)e
{
	[[CCDirector sharedDirector] replaceScene:[BGRoomLayer scene]];
    [BGRoomLayer sharedRoomLayer].room = [[_es.managerHelper.zoneManager zoneById:e.zoneId] roomById:e.roomId];
    
    if (e.users.count >= 2) {
        [[BGRoomLayer sharedRoomLayer] sendStartGameRequestWithEventListener:[BGRoomLayer sharedRoomLayer]];
    }
}

@end
