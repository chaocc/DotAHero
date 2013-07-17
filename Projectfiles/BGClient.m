//
//  BGClient.m
//  DotAHero
//
//  Created by Killua Liu on 7/11/13.
//
//

#import "BGClient.h"
#import "BGPluginConstants.h"
#import "BGFileConstants.h"
#import "BGLoginLayer.h"
#import "BGRoomListLayer.h"
#import "BGRoomLayer.h"
#import "BGGameLayer.h"

@interface BGClient ()

@end

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

- (BOOL)isSingleMode
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    return [defaults boolForKey:@"singleMode"];
}

#pragma mark - Server connection
/*
 * Connect to Elctro Server. Called in login layer.
 */
- (void)conntectServer
{
    NSString *path = [[CCFileUtils sharedFileUtils] fullPathFromRelativePath:kXmlSettings];
    [_es loadAndConnect:path];
    
    [_es.engine addEventListenerWithTarget:self action:@selector(onConnectionResponse:) eventIdentifier:EsMessageType_ConnectionResponse];
}

/*
 * Receive connnection response from server
 */
- (void)onConnectionResponse:(EsConnectionResponse *)e
{
    NSAssert(e.successful, @"Connnection Failed in %@", NSStringFromSelector(_cmd));
    
    BGLoginLayer *login = [BGLoginLayer sharedLoginLayer];
    
    if (e.successful)
    {
        [_es.engine addEventListenerWithTarget:self action:@selector(onLoginResponse:) eventIdentifier:EsMessageType_LoginResponse];
        
        EsLoginRequest *lr = [[EsLoginRequest alloc] init];
        lr.userName = login.userName;
        [_es.engine sendMessage:lr];
    }
    else
    {
//      ...TEMP...
        CCLabelTTF *label = [CCLabelTTF labelWithString:@"Network Connection Failed"
                                               fontName:@"Arial"
                                               fontSize:30.0f];
        label.position = [CCDirector sharedDirector].screenCenter;
        [login addChild:label];
    }
}

/*
 * Receive login response from server(Show room list layer)
 */
- (void)onLoginResponse:(EsLoginResponse *)e
{
    NSAssert(e.successful, @"Login Failed in %@", NSStringFromSelector(_cmd));
    
    [[BGLoginLayer sharedLoginLayer] showRoomListLayer];
}

#pragma mark - Room reqeust/response/event
/*
 * Send room request with all plugins to server. Call in room list layer.
 */
- (void)joinRoom
{
    [_es.engine addEventListenerWithTarget:self action:@selector(onJoinRoomEvent:) eventIdentifier:EsMessageType_JoinRoomEvent];
    [_es.engine addEventListenerWithTarget:self action:@selector(onUserUpdateEvent:) eventIdentifier:EsMessageType_UserUpdateEvent];
    
    EsCreateRoomRequest *crr = [[EsCreateRoomRequest alloc] init];
    crr.roomName = @"TestRoom";
    crr.zoneName = @"TestZone";
    
    EsPluginListEntry *pleRoom = [[EsPluginListEntry alloc] init];
    pleRoom.extensionName = @"ChatLogger";
    pleRoom.pluginHandle = kPluginRoom;
    pleRoom.pluginName = kPluginRoom;
    
    EsPluginListEntry *pleGame = [[EsPluginListEntry alloc] init];
    pleGame.extensionName = @"ChatLogger";
    pleGame.pluginHandle = kPluginGame;
    pleGame.pluginName = kPluginGame;
    
    crr.plugins = [NSMutableArray arrayWithObjects:pleRoom, pleGame, nil];
    
    [_es.engine sendMessage:crr];
}

/*
 * Receive join room event(Show room layer)
 */
- (void)onJoinRoomEvent:(EsJoinRoomEvent *)e
{
    _room = [[_es.managerHelper.zoneManager zoneById:e.zoneId] roomById:e.roomId];
    
    [[BGRoomListLayer sharedRoomListLayer] showRoomLayer];
    
    if (e.users.count == 1) {
        [BGRoomLayer sharedRoomLayer].isRoomOwner = YES;    // First joiner is room owner
        NSLog(@"User %@ is room owner", [e.users.lastObject userName]);
    } else {
        [self sendReadyStartGameRequest];
    }
}

/*
 * Receive userUpdate event(Check if startGame button can be enabled)
 */
- (void)onUserUpdateEvent:(EsZoneUpdateEvent *)e
{
    if (_es.managerHelper.userManager.users.count >= 2) {
        [self sendReadyStartGameRequest];
    }
}

#pragma mark - Room plugin message
/*
 * Send plugin request to server with specified plugin name
 */
- (void)sendPluginRequestWithPluginName:(NSString *)pluginName andObject:(EsObject *)obj
{    
    EsPluginRequest *pr = [[EsPluginRequest alloc] init];
    pr.pluginName = pluginName;
    pr.roomId = _room.roomId;
    pr.zoneId = _room.zoneId;
    pr.parameters = obj;
    [_es.engine sendMessage:pr];
}

/*
 * Add room plugin message event listener
 */
- (void)addRoomPluginMessageEventListener
{
    [_es.engine addEventListenerWithTarget:self action:@selector(onRoomPluginMessageEvent:) eventIdentifier:EsMessageType_PluginMessageEvent];
}

/*
 * Remove room plugin message event listener
 */
- (void)removeRoomPluginMessageEventListener
{
    [_es.engine removeEventListenerWithTarget:self action:@selector(onRoomPluginMessageEvent:) eventIdentifier:EsMessageType_PluginMessageEvent];
}

/*
 * Send room plugin request to server with specified ES object
 */
- (void)sendRoomPluginRequestWithObject:(EsObject *)obj
{
    [self addRoomPluginMessageEventListener];
    [self sendPluginRequestWithPluginName:kPluginRoom andObject:obj];
}

/*
 * Send room plugin request with action-readyStartGame. Called in room layer.
 */
- (void)sendReadyStartGameRequest
{
    EsObject *obj = [[EsObject alloc] init];
    [obj setInt:kActionReadyStartGame forKey:kAction];
    [self sendRoomPluginRequestWithObject:obj];
    
    NSLog(@"Send room plugin request with action(%i)", kActionReadyStartGame);
}

/*
 * Receive room plugin message event. Handle different returning actions.
 */
- (void)onRoomPluginMessageEvent:(EsPluginMessageEvent *)e
{
    EsObject *obj = e.parameters;
    NSInteger action = [obj intWithKey:kAction];
    NSAssert(action != kActionInvalid, @"Invalid action in %@", NSStringFromSelector(_cmd));
    NSLog(@"Receive room plugin message event with action(%i)", action);
    
    switch (action) {
        case kActionReadyStartGame:
            [[BGRoomLayer sharedRoomLayer] readyStartGame];
            [self removeRoomPluginMessageEventListener];
            break;
            
        default:
            break;
    }
}

#pragma mark - Game plugin message
/*
 * Add game plugin message event listener
 */
- (void)addGamePluginMessageEventListener
{
    [_es.engine addEventListenerWithTarget:self action:@selector(onGamePluginMessageEvent:) eventIdentifier:EsMessageType_PluginMessageEvent];
}

/*
 * Remove game plugin message event listener
 */
- (void)removeGamePluginMessageEventListener
{
    [_es.engine removeEventListenerWithTarget:self action:@selector(onGamePluginMessageEvent:) eventIdentifier:EsMessageType_PluginMessageEvent];
}

/*
 * Send game plugin request to server with specified ES object
 */
- (void)sendGamePluginRequestWithObject:(EsObject *)obj
{
    [self sendPluginRequestWithPluginName:kPluginGame andObject:obj];
}

/*
 * Send game plugin request with action-startGame. Called in game layer.
 */
- (void)sendStartGameRequest
{
    EsObject *obj = [[EsObject alloc] init];
    [obj setInt:kActionStartGame forKey:kAction];
    [self sendGamePluginRequestWithObject:obj];
    
    NSLog(@"Send game plugin request with action-startGame(%i)", kActionStartGame);
}

/*
 * Send game plugin request with action-selectHeroCard and heroId. Called in player class.
 */
- (void)sendSelectHeroCardRequestWithHeroId:(NSInteger)heroId
{
    EsObject *obj = [[EsObject alloc] init];
    [obj setInt:kActionSelectHeroCard forKey:kAction];
    [obj setInt:heroId forKey:kParamHeroId];
    [self sendGamePluginRequestWithObject:obj];
    
    NSLog(@"Send game plugin request with action-selectHeroCard(%i) and heroId:%i", kActionSelectHeroCard, heroId);
}

/*
 * Send game plugin request with action-cutCard and usedPlayingCardIds. Called in playing menu.
 */
- (void)sendCutCardRequestWithPlayingCardId:(NSInteger)cardId
{
    EsObject *obj = [[EsObject alloc] init];
    [obj setInt:kActionCutCard forKey:kAction];
    NSArray *cardIds = [NSArray arrayWithObject:@(cardId)];
    [obj setIntArray:cardIds forKey:kParamUsedPlayingCardIds];
    [self sendGamePluginRequestWithObject:obj];
    
    NSLog(@"Send game plugin request with action-cutCard(%i) and usedPlayingCardIds:%@", kActionCutCard, cardIds);
}

/*
 * Send game plugin request with action-drawCard. Called in playing menu.
 */
- (void)sendDrawPlayingCardRequest
{
    EsObject *obj = [[EsObject alloc] init];
    [obj setInt:kActionDrawPlayingCard forKey:kAction];
    [self sendGamePluginRequestWithObject:obj];
    
    NSLog(@"Send game plugin request with action-drawPlayingCard(%i)", kActionDrawPlayingCard);
}

/*
 * 1. Send game plugin request with action-okToUseCard, usedPlayingCardIds and targetPlayerNames. Called in playing menu.
 * 2. Send public message with action-okToUseCard and usedPlayingCardIds
 */
- (void)sendUseCardRequestWithPlayingCardId:(NSInteger)cardId
{
    NSAssert([BGGameLayer sharedGameLayer].targetPlayerNames.count == 0,
             @"targetPlayerNames Nil in %@", NSStringFromSelector(_cmd));
    
    EsObject *obj1 = [[EsObject alloc] init];
    [obj1 setInt:kActionOkToUseCard forKey:kAction];
    NSArray *cardIds = [NSArray arrayWithObject:@(cardId)];
    [obj1 setIntArray:cardIds forKey:kParamUsedPlayingCardIds];
    [obj1 setStringArray:[BGGameLayer sharedGameLayer].targetPlayerNames forKey:kParamTargetPlayerNames];
    [self sendGamePluginRequestWithObject:obj1];
    
    NSLog(@"Send game plugin request with action-okToUseCard(%i), usedPlayingCardIds:%@ and targetPlayerNames:%@",
          kActionOkToUseCard, cardIds, [BGGameLayer sharedGameLayer].targetPlayerNames);
    
//  Send public message
    EsObject *obj2 = [[EsObject alloc] init];
    [obj2 setInt:kActionOkToUseCard forKey:kAction];
    [obj2 setIntArray:[NSArray arrayWithObject:@(cardId)] forKey:kParamUsedPlayingCardIds];
    [self sendPublicMessageRequestWithObject:obj2];
    
    NSLog(@"Send public message with action-okToUseCard(%i) and usedPlayingCardIds:%@", kActionOkToUseCard, cardIds);
}

/*
 * Send game plugin request with action-cancelCard. Called in playing menu.
 */
- (void)sendCancelCardRequest
{
    NSAssert([BGGameLayer sharedGameLayer].playerName, @"playerName is nil");
    
    EsObject *obj = [[EsObject alloc] init];
    [obj setInt:kActionCancelCard forKey:kAction];
    [obj setString:[BGGameLayer sharedGameLayer].playerName forKey:kParamPlayerName];   //伤害来源的玩家名
    [self sendGamePluginRequestWithObject:obj];
    
    NSLog(@"Send game plugin request with action-cancelCard(%i) and playerName:%@",
          kActionCancelCard, [BGGameLayer sharedGameLayer].playerName);
}

/*
 * Receive Game plugin message event. Handle different returning actions.
 */
- (void)onGamePluginMessageEvent:(EsPluginMessageEvent *)e
{
    EsObject *obj = e.parameters;
    NSInteger action = [obj intWithKey:kAction];
    NSInteger playerState = [obj intWithKey:kPlayerState];
    NSArray *array = nil;
    BGGameLayer *gamePlayer = [BGGameLayer sharedGameLayer];
    BGPlayer *currentPlayer = gamePlayer.currentPlayer;
    
    if (action != kActionInvalid) {
        NSLog(@"Receive game plugin message event with action(%i)", action);
        goto actionLabel;
    }
    if (playerState != kPlayerStateInvalid) {
        NSLog(@"Receive game plugin message event with playerState(%i)", action);
        goto playerStateLabel;
    }
    
//  Actions
actionLabel:
    switch (action) {
        case kActionDealHeroCard:
            array = [obj intArrayWithKey:kParamToBeSelectedHeroIds];
            NSAssert(array, @"Nil in selector %@", NSStringFromSelector(_cmd));
            [gamePlayer dealHeroCards:array];
            break;
            
        case kActionSendAllHeroIds:
            array = [obj stringArrayWithKey:kParamAllHeroIds];
            NSAssert(array, @"Nil in selector %@", NSStringFromSelector(_cmd));
            [gamePlayer sendAllHeroIds:array];
            break;
            
        case kActionDealPlayingCard:
            array = [obj stringArrayWithKey:kParamGotPlayingCardIds];
            NSAssert(array, @"Nil in selector %@", NSStringFromSelector(_cmd));
            [currentPlayer addPlayingAreaWithPlayingCardIds:array];
            break;
        
        case kActionCutCard:
            array = [obj stringArrayWithKey:kParamAllCuttingCardIds];
            NSAssert(array, @"Nil in selector %@", NSStringFromSelector(_cmd));
            [currentPlayer showAllCuttingCardsWithCardIds:array];
            break;
            
        case kActionSendPlayingCard:
            [self sendDrawPlayingCardPublicMessage];
            array = [obj stringArrayWithKey:kParamGotPlayingCardIds];
            NSAssert(array, @"Nil in selector %@", NSStringFromSelector(_cmd));
            [currentPlayer drawPlayingCardIds:array];
            break;
            
        default:
            break;
    }
    
//  Player state
playerStateLabel:
    currentPlayer.playerState = playerState;
    switch (playerState) {
        case kPlayerStateTurnStarting:
            [self sendStartTurnPublicMessage];
            break;
            
        case kPlayerStateDrawing:
            [self sendDrawPlayingCardRequest];
            break;
            
        case kPlayerStatePlaying:
            [currentPlayer addPlayingMenuOfCardUsing];
            break;
            
        case kPlayerStateIsBeingAttacked:
            gamePlayer.playerName = [obj stringWithKey:kParamPlayerName];
            NSAssert(gamePlayer.playerName, @"playerName Nil in %@", NSStringFromSelector(_cmd));
            [gamePlayer.targetPlayerNames addObject:gamePlayer.playerName];
            [currentPlayer addPlayingMenuOfCardPlaying];
            break;
            
        case kPlayerStateWasAttacked:
//          掉血／加怒气
            NSLog(@"BLOOD1: %d", [obj intWithKey:kParamBloodPointChanged]);
            NSLog(@"ANGER1: %d", [obj intWithKey:kParamAngerPointChanged]);
            break;
            
        case kPlayerStateAttacked:
//          可能获得怒气
            NSLog(@"BLOOD2: %d", [obj intWithKey:kParamBloodPointChanged]);
            NSLog(@"ANGER2: %d", [obj intWithKey:kParamAngerPointChanged]);
            break;
            
        default:
            break;
    }
}

#pragma mark - Public message
/*
 * Add public message event listener(Public message is sent by one player, but other players need register the event)
 */
- (void)addPublicMessageEventListener
{
    [_es.engine addEventListenerWithTarget:self action:@selector(onPublicMessageEvent:) eventIdentifier:EsMessageType_PublicMessageEvent];
}

/*
 * Send public message request with specified ES object
 */
- (void)sendPublicMessageRequestWithObject:(EsObject *)obj
{    
    EsPublicMessageRequest *pmr = [[EsPublicMessageRequest alloc] init];
    pmr.roomId = _room.roomId;
    pmr.zoneId = _room.zoneId;
    pmr.esObject = obj;
    [_es.engine sendMessage:pmr];
}

/*
 * Send public message with action-startGame
 */
- (void)sendStartGamePublicMessage
{
    EsObject *obj = [[EsObject alloc] init];
    [obj setInt:kActionStartGame forKey:kAction];
    [self sendPublicMessageRequestWithObject:obj];
    
    NSLog(@"Send public message with action-startGame(%i)", kActionStartGame);
}

/*
 * Send public message with action-startTurn and plyerName
 */
- (void)sendStartTurnPublicMessage
{
    EsObject *obj = [[EsObject alloc] init];
    [obj setInt:kActionStartTurn forKey:kAction];
    [obj setString:[BGGameLayer sharedGameLayer].currentPlayer.playerName forKey:kParamPlayerName];
    [self sendPublicMessageRequestWithObject:obj];
    
    NSLog(@"Send public message with action-startGame(%i) and playerName:%@",
          kActionStartGame, [BGGameLayer sharedGameLayer].currentPlayer.playerName);
}

/*
 * Send public message with action-drawPlayingCard
 */
- (void)sendDrawPlayingCardPublicMessage
{
    EsObject *obj = [[EsObject alloc] init];
    [obj setInt:kActionDrawPlayingCard forKey:kAction];
    [self sendPublicMessageRequestWithObject:obj];
    
    NSLog(@"Send public message with action-drawPlayingCard(%i)", kActionDrawPlayingCard);
}

/*
 * Receive all public message events. Broadcast to all players in the same room.
 */
- (void)onPublicMessageEvent:(EsPublicMessageEvent *)e
{
    EsObject *obj = e.esObject;
    NSInteger action = [obj intWithKey:kAction];
    NSAssert(action != kActionInvalid, @"Invalid action in %@", NSStringFromSelector(_cmd));
    NSLog(@"Receive public message event with action(%i)", action);
    
    switch (action) {
        case kActionStartGame:
            self.users = _es.managerHelper.userManager.users;
            [[BGRoomLayer sharedRoomLayer] showGameLayer];
            NSLog(@"All login users:%@", self.users);
            break;
            
        case kActionStartTurn:
            [BGGameLayer sharedGameLayer].playerName = [obj stringWithKey:kParamPlayerName];
            NSLog(@"Parameter-playerName:%@",[BGGameLayer sharedGameLayer].playerName);
            break;
            
        default:
            break;
    }
}

/*
 * Adjust the user's index, put the current user as first one.
 */
- (void)setUsers:(NSArray *)users
{
    NSMutableArray *mutableUsers = [users mutableCopy];
    NSMutableIndexSet *idxSet = [NSMutableIndexSet indexSet];
    
    [users enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        if ([obj isEqual:_es.managerHelper.userManager.me]) {
            [mutableUsers removeObjectsAtIndexes:idxSet];
            [mutableUsers addObjectsFromArray:[users objectsAtIndexes:idxSet]];
            _users = mutableUsers;
            return;
        }
        
        [idxSet addIndex:idx];
    }];
}

@end
