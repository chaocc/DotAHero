//
//  BGRoomLayer.m
//  DotAHero
//
//  Created by Killua Liu on 6/14/13.
//
//

#import "BGRoomLayer.h"
#import "BGGameLayer.h"

@interface BGRoomLayer ()

@property (nonatomic) BOOL isRoomOwner;

@end

@implementation BGRoomLayer

static BGRoomLayer *instanceOfRoomLayer = nil;

+ (BGRoomLayer *)sharedRoomLayer
{
    NSAssert(instanceOfRoomLayer, @"RoomListLayer instance not yet initialized!");
	return instanceOfRoomLayer;
}

+ (id)scene
{
	CCScene* scene = [CCScene node];
	CCLayer* layer = [BGRoomLayer node];
	[scene addChild:layer];
    
	return scene;
}

- (id)init
{
    if (self = [super init]) {
        instanceOfRoomLayer = self;
        
        _es = [BGLoginLayer sharedLoginLayer].es;
        
        if (_es.managerHelper.userManager.users.count == 1) {
            _isRoomOwner = YES;
        }
        
        [_es.engine addEventListenerWithTarget:self action:@selector(onUserUpdateEvent:) eventIdentifier:EsMessageType_UserUpdateEvent];
        
        CCLabelTTF *label = [CCLabelTTF labelWithString:@"Wait for another player joining the game..."
                                               fontName:@"Arial"
                                               fontSize:30.0f];
        label.position = [CCDirector sharedDirector].screenCenter;
        [self addChild:label];
    }
    return self;
}

- (void)onUserUpdateEvent:(EsZoneUpdateEvent *)e
{
    if (_es.managerHelper.userManager.users.count >= 2) {
        [self sendStartGameRequestWithEventListener:self];
    }
}

// Send plugin request to server
- (void)sendPluginRequestWithObject:(EsObject *)obj pluginName:(NSString *)name andEventListener:(id)target
{
    [_es.engine addEventListenerWithTarget:target action:@selector(onPluginMessageEvent:) eventIdentifier:EsMessageType_PluginMessageEvent];
    
    EsPluginRequest *pr = [[EsPluginRequest alloc] init];
    pr.pluginName = name;
    pr.roomId = _room.roomId;
    pr.zoneId = _room.zoneId;
    pr.parameters = obj;
    [_es.engine sendMessage:pr];
}

- (void)sendStartGameRequestWithEventListener:(id)target
{
    EsObject *obj = [[EsObject alloc] init];
    [obj setInt:kActionReadyStartGame forKey:kAction];
    
    [self sendPluginRequestWithObject:obj pluginName:@"ChatPlugin" andEventListener:target];
}

- (void)onPluginMessageEvent:(EsPluginMessageEvent *)e
{
    [self removeAllChildrenWithCleanup:YES];
    
    [_es.engine addEventListenerWithTarget:self action:@selector(onPublicMessageEvent:) eventIdentifier:EsMessageType_PublicMessageEvent];
    
    if (_isRoomOwner)
    {
        CCMenuItemFont *item = [CCMenuItemFont itemWithString:@"Start Game" block:^(id sender) {
//          Send startGame public message to server
            EsPublicMessageRequest *pmr = [[EsPublicMessageRequest alloc] init];
            pmr.roomId = _room.roomId;
            pmr.zoneId = _room.zoneId;
            EsObject *obj = [[EsObject alloc] init];
            [obj setInt:kActionStartGame forKey:kAction];
            pmr.esObject = obj;
            [_es.engine sendMessage:pmr];
        }];
        CCMenu *menu = [CCMenu menuWithItems:item, nil];
        [self addChild:menu];
    }
    else
    {
        CCLabelTTF *label = [CCLabelTTF labelWithString:@"Wait for starting game..."
                                               fontName:@"Arial"
                                               fontSize:30.0f];
        label.position = [CCDirector sharedDirector].screenCenter;
        [self addChild:label];
    }
}

- (void)onPublicMessageEvent:(EsPublicMessageEvent *)e
{
    [self removeAllChildrenWithCleanup:YES];
    
    CCScene *scene = [BGGameLayer node];
    CCTransitionSlideInR *transitionScene = [CCTransitionSlideInR transitionWithDuration:0.5f scene:scene];
    [[CCDirector sharedDirector] replaceScene:transitionScene];
}

// ...TODO...
// checkRoomOwner
// if yes, display start game button

@end
