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
    NSAssert(e.successful, @"Connnection Failed");
    
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
    NSAssert(e.successful, @"Login Failed");
    
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
 * Send room plugin request to server with specified ES object
 */
- (void)sendRoomPluginRequestWithObject:(EsObject *)obj
{
    [_es.engine addEventListenerWithTarget:self action:@selector(onRoomPluginMessageEvent:) eventIdentifier:EsMessageType_PluginMessageEvent];
    [self sendPluginRequestWithPluginName:kPluginRoom andObject:obj];
}

/*
 * Send readyStartGame action. Called in room layer.
 */
- (void)sendReadyStartGameRequest
{
    EsObject *obj = [[EsObject alloc] init];
    [obj setInt:kActionReadyStartGame forKey:kAction];
    [self sendRoomPluginRequestWithObject:obj];
}

/*
 * Receive room plugin message event. Handle different returning actions.
 */
- (void)onRoomPluginMessageEvent:(EsPluginMessageEvent *)e
{
    EsObject *obj = e.parameters;
    
    switch ([obj intWithKey:kAction]) {
        case kActionReadyStartGame:
            [[BGRoomLayer sharedRoomLayer] readyStartGame];
            break;
            
        default:
            break;
    }
}

#pragma mark - Game plugin message
/*
 * Add plugin message event listener
 */
- (void)addGamePluginMessageEventListener
{
    [_es.engine addEventListenerWithTarget:self action:@selector(onGamePluginMessageEvent:) eventIdentifier:EsMessageType_PluginMessageEvent];
}

/*
 * Send game plugin request to server with specified ES object
 */
- (void)sendGamePluginRequestWithObject:(EsObject *)obj
{
    [self sendPluginRequestWithPluginName:kPluginGame andObject:obj];
}

/*
 * Send startGame action. Called in game layer.
 */
- (void)sendStartGameRequest
{
    EsObject *obj = [[EsObject alloc] init];
    [obj setInt:kActionStartGame forKey:kAction];
    [self sendGamePluginRequestWithObject:obj];
}

/*
 * Send selectHeroCard action. Called in player class.
 */
- (void)sendSelectHeroCardRequestWithHeroId:(NSUInteger)heroId
{
    EsObject *obj = [[EsObject alloc] init];
    [obj setInt:kActionSelectHeroCard forKey:kAction];
    [obj setInt:heroId forKey:kParamHeroId];
    [self sendGamePluginRequestWithObject:obj];
}

/*
 * Send cutCard action. Called in playing menu.
 */
- (void)sendCutCardRequestWithPlayingCardId:(NSUInteger)cardId
{
    EsObject *obj = [[EsObject alloc] init];
    [obj setInt:kActionCutCard forKey:kAction];
    [obj setIntArray:[NSArray arrayWithObject:@(cardId)] forKey:kParamUsedPlayingCardIds];
    [self sendGamePluginRequestWithObject:obj];
}

/*
 * Send drawCard action. Called in playing menu.
 */
- (void)sendDrawPlayingCardRequest
{
    EsObject *obj = [[EsObject alloc] init];
    [obj setInt:kActionDrawPlayingCard forKey:kAction];
    [self sendGamePluginRequestWithObject:obj];
}

/*
 * Send use playing card action. Called in playing menu.
 */
- (void)sendUseCardRequestWithPlayingCardId:(NSUInteger)cardId
{
    EsObject *obj1 = [[EsObject alloc] init];
    [obj1 setInt:kActionOkToUseCard forKey:kAction];
    [obj1 setIntArray:[NSArray arrayWithObject:@(cardId)] forKey:kParamUsedPlayingCardIds];
    [obj1 setString:[BGGameLayer sharedGameLayer].playerName forKey:kParamPlayerName];
    [obj1 setStringArray:[BGGameLayer sharedGameLayer].targetPlayerNames forKey:kParamTargetPlayerNames];
    [self sendGamePluginRequestWithObject:obj1];
    
//  Send public message
    EsObject *obj2 = [[EsObject alloc] init];
    [obj2 setInt:kActionOkToUseCard forKey:kAction];
    [obj2 setIntArray:[NSArray arrayWithObject:@(cardId)] forKey:kParamUsedPlayingCardIds];
    [self sendPublicMessageRequestWithObject:obj2];
}

/*
 * Receive Game plugin message event. Handle different returning actions.
 */
- (void)onGamePluginMessageEvent:(EsPluginMessageEvent *)e
{
    EsObject *obj = e.parameters;
    BGGameLayer *gamePlayer = [BGGameLayer sharedGameLayer];
    BGPlayer *currentPlayer = gamePlayer.currentPlayer;
    
//  Actions
    switch ([obj intWithKey:kAction]) {
        case kActionDealHeroCard:
            [gamePlayer dealHeroCards:[obj stringArrayWithKey:kParamToBeSelectedHeroIds]];
            break;
            
        case kActionSendAllHeroIds:
            [gamePlayer sendAllHeroIds:[obj stringArrayWithKey:kParamAllHeroIds]];
            break;
            
        case kActionDealPlayingCard:
            [currentPlayer addPlayingAreaWithPlayingCardIds:[obj stringArrayWithKey:kParamGotPlayingCardIds]];
            break;
        
        case kActionCutCard:
            [currentPlayer showAllCuttingCardsWithCardIds:[obj stringArrayWithKey:kParamAllCuttingCardIds]];
            break;
            
        case kActionSendPlayingCard:
            [self sendDrawPlayingCardPublicMessage];
            [currentPlayer drawPlayingCardIds:[obj stringArrayWithKey:kParamGotPlayingCardIds]];
            break;
            
        default:
            break;
    }
    
//  Player state
    currentPlayer.playerState = [obj intWithKey:kPlayerState];
    switch (currentPlayer.playerState) {
        case kTurnStarting:
            [self sendStartTurnPublicMessage];
            break;
            
        case kDrawing:
            [self sendDrawPlayingCardRequest];
            break;
            
        case kPlaying:
            [currentPlayer addPlayingMenuOfCardUsing];
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
 * Send startGame public message
 */
- (void)sendStartGamePublicMessage
{
    EsObject *obj = [[EsObject alloc] init];
    [obj setInt:kActionStartGame forKey:kAction];
    [self sendPublicMessageRequestWithObject:obj];
}

/*
 * Send startTurn public message
 */
- (void)sendStartTurnPublicMessage
{
    EsObject *obj = [[EsObject alloc] init];
    [obj setInt:kActionStartTurn forKey:kAction];
    [obj setString:[BGGameLayer sharedGameLayer].currentPlayer.playerName forKey:kParamPlayerName];
    [self sendPublicMessageRequestWithObject:obj];
}

/*
 * Send drawPlayingCard public message
 */
- (void)sendDrawPlayingCardPublicMessage
{
    EsObject *obj = [[EsObject alloc] init];
    [obj setInt:kActionDrawPlayingCard forKey:kAction];
    [self sendPublicMessageRequestWithObject:obj];
}

/*
 * Receive all public message events. Broadcast to all players in the same room.
 */
- (void)onPublicMessageEvent:(EsPublicMessageEvent *)e
{
    EsObject *obj = e.esObject;
    
    switch ([obj intWithKey:kAction]) {
        case kActionStartGame:
            self.users = _es.managerHelper.userManager.users;
            [[BGRoomLayer sharedRoomLayer] showGameLayer];
            break;
            
        case kActionStartTurn:
            [BGGameLayer sharedGameLayer].playerName = [obj stringWithKey:kParamPlayerName];
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
