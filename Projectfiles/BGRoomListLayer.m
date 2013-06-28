//
//  BGRoomListLayer.m
//  DotAHero
//
//  Created by Killua Liu on 6/19/13.
//
//

#import "BGRoomListLayer.h"
#import "ElectroServer.h"
#import "BGLoginLayer.h"
#import "BGRoomLayer.h"

@interface BGRoomListLayer ()

@property (weak, nonatomic) ElectroServer *es;

@end

@implementation BGRoomListLayer 

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
        self.es = [[BGLoginLayer sharedLoginScene] es];
        
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
    
//    EsPluginListEntry *ple = [[EsPluginListEntry alloc] init];
//    ple.extensionName = @"HelloWorld";
//    ple.pluginHandle = @"HelloWorld";
//    ple.pluginName = @"HelloWorld";
//    crr.plugins = [NSMutableArray arrayWithObject:ple];
    
    [_es.engine sendMessage:crr];
}

- (void)onJoinRoomEvent:(EsJoinRoomEvent *)e
{    
	[[CCDirector sharedDirector] replaceScene:[BGRoomLayer scene]];
}

@end
