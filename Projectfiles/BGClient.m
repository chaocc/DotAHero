//
//  BGClient.m
//  DotAHero
//
//  Created by Killua Liu on 7/11/13.
//
//

#import "BGClient.h"
#import "BGFileConstants.h"
#import "BGLoginLayer.h"
#import "BGRoomListLayer.h"
#import "BGRoomLayer.h"

@implementation BGClient

static BGClient *instanceOfClient = nil;

+ (BGClient *)sharedClient
{
    if (!instanceOfClient) {
        instanceOfClient = [[self alloc] init];
    }
	return instanceOfClient;
}

- (id)init
{
    if (self = [super init]) {
        _es = [[ElectroServer alloc] init];
    }
    return self;
}

- (void)conntectServer
{
    NSString *path = [[CCFileUtils sharedFileUtils] fullPathFromRelativePath:kXmlSettings];
    [_es loadAndConnect:path];
    
    [_es.engine addEventListenerWithTarget:self action:@selector(onConnectionResponse:) eventIdentifier:EsMessageType_ConnectionResponse];
}

- (void)onConnectionResponse:(EsConnectionResponse *)e
{
    NSAssert(e.successful, @"Connnection Failed");
    
    if (e.successful)
    {
        [_es.engine addEventListenerWithTarget:self action:@selector(onLoginResponse:) eventIdentifier:EsMessageType_LoginResponse];
        
        EsLoginRequest *lr = [[EsLoginRequest alloc] init];
        srandom(time(NULL));
        lr.userName = [NSString stringWithFormat:@"Killua%li", lrint(1000 * random())];
        [_es.engine sendMessage:lr];
    }
    else
    {
        CCLabelTTF *label = [CCLabelTTF labelWithString:@"Network Connection Failed"
                                               fontName:@"Arial"
                                               fontSize:30.0f];
        label.position = [CCDirector sharedDirector].screenCenter;
        [[BGLoginLayer sharedLoginLayer] addChild:label];
    }
}

- (void)onLoginResponse:(EsLoginResponse *)e
{
    NSAssert(e.successful, @"Login Failed");
    [[BGLoginLayer sharedLoginLayer] addChild:[BGRoomListLayer scene]];
//	[[CCDirector sharedDirector] replaceScene:transitionScene];
}

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
