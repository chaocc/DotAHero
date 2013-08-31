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

@property (nonatomic, weak) BGGameLayer *gameLayer;
@property (nonatomic, weak) BGPlayingDeck *playingDeck;
@property (nonatomic, weak) BGPlayer *player;

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

#pragma mark - Server connection
/*
 * Connect to Elctro Server. Called in login layer.
 */
- (void)conntectServer
{
    NSString *path = [[CCFileUtils sharedFileUtils] fullPathFromRelativePath:kXmlSettings];
    [_es loadAndConnect:path];
    
    [_es.engine addEventListenerWithTarget:self
                                    action:@selector(onConnectionResponse:)
                           eventIdentifier:EsMessageType_ConnectionResponse];
}

/*
 * Receive connnection response from server
 */
- (void)onConnectionResponse:(EsConnectionResponse *)e
{
    NSAssert(e.successful, @"Connnection Failed in %@", NSStringFromSelector(_cmd));
    
    BGLoginLayer *login = [BGLoginLayer sharedLoginLayer];
    
    if (e.successful) {
        [_es.engine addEventListenerWithTarget:self
                                        action:@selector(onLoginResponse:)
                               eventIdentifier:EsMessageType_LoginResponse];

        EsLoginRequest *lr = [[EsLoginRequest alloc] init];
        lr.userName = login.userName;
        [_es.engine sendMessage:lr];
    }
    else {
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
 * Send create/join room request with all plugins to server. Called in room list layer.
 */
- (void)sendCreateRoomRequest
{
    [_es.engine addEventListenerWithTarget:self
                                    action:@selector(onJoinRoomEvent:)
                           eventIdentifier:EsMessageType_JoinRoomEvent];
    
    [_es.engine addEventListenerWithTarget:self
                                    action:@selector(onUserUpdateEvent:)
                           eventIdentifier:EsMessageType_UserUpdateEvent];
    
    EsCreateRoomRequest *crr = [[EsCreateRoomRequest alloc] init];
    crr.roomName = @"TestRoom";
    crr.zoneName = @"TestZone";
    
    EsPluginListEntry *pleRoom = [[EsPluginListEntry alloc] init];
    pleRoom.extensionName = kExtensionHeroServer;
    pleRoom.pluginHandle = kPluginRoom;
    pleRoom.pluginName = kPluginRoom;
    
    EsPluginListEntry *pleGame = [[EsPluginListEntry alloc] init];
    pleGame.extensionName = kExtensionHeroServer;
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
    
    if (1 == e.users.count) {
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

/*
 * Send leave room request. Called when user exit room or application will terminate
 */
- (void)sendLeaveRoomRequest
{
    [_es.engine addEventListenerWithTarget:self
                                    action:@selector(onLeaveRoomEvent:)
                           eventIdentifier:EsMessageType_LeaveRoomEvent];
    
    EsLeaveRoomRequest *lrr = [[EsLeaveRoomRequest alloc] init];
    lrr.roomId = _room.roomId;
    [_es.engine sendMessage:lrr];
}

/*
 * Receive leave room event
 */
- (void)onLeaveRoomEvent:(EsLeaveRoomEvent *)e
{
    
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
    [_es.engine addEventListenerWithTarget:self
                                    action:@selector(onRoomPluginMessageEvent:)
                           eventIdentifier:EsMessageType_PluginMessageEvent];
}

/*
 * Remove room plugin message event listener
 */
- (void)removeRoomPluginMessageEventListener
{
    [_es.engine removeEventListenerWithTarget:self
                                       action:@selector(onRoomPluginMessageEvent:)
                              eventIdentifier:EsMessageType_PluginMessageEvent];
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
 * Send room plugin request with kActionReadyStartGame. Called in room layer.
 */
- (void)sendReadyStartGameRequest
{    
    EsObject *obj = [[EsObject alloc] init];
    [obj setInt:kActionReadyStartGame forKey:kAction];
    [self sendRoomPluginRequestWithObject:obj];
    
    NSLog(@"Send room plugin request with EsObject: %@", obj);
}

/*
 * Receive room plugin message event. Handle different returning actions.
 */
- (void)onRoomPluginMessageEvent:(EsPluginMessageEvent *)e
{
    NSLog(@"Receive room plugin message with EsObject: %@", e.parameters);
    
    NSInteger action = [e.parameters intWithKey:kAction];
    NSAssert(kActionInvalid != action, @"Invalid action in %@", NSStringFromSelector(_cmd));
    
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
    [_es.engine addEventListenerWithTarget:self
                                    action:@selector(onGamePluginMessageEvent:)
                           eventIdentifier:EsMessageType_PluginMessageEvent];
}

/*
 * Remove game plugin message event listener
 */
- (void)removeGamePluginMessageEventListener
{
    [_es.engine removeEventListenerWithTarget:self
                                       action:@selector(onGamePluginMessageEvent:)
                              eventIdentifier:EsMessageType_PluginMessageEvent];
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
    [obj setInt:kPlayerCountSix forKey:kParamPlayerCount];
    [self sendGamePluginRequestWithObject:obj];
    
    NSLog(@"Send game plugin request with EsObject: %@", obj);
}

/*
 * Send game plugin request with kActionChooseHero and kParamCardIdList.
 */
- (void)sendChooseHeroIdRequest
{    
    EsObject *obj = [[EsObject alloc] init];
    [obj setInt:kActionChooseHero forKey:kAction];
    NSArray *heroIds = [NSArray arrayWithObject:@(_player.selectedHeroId)];
    [obj setIntArray:heroIds forKey:kParamCardIdList];
    [self sendGamePluginRequestWithObject:obj];
    
    NSLog(@"Send game plugin request with EsObject: %@", obj);
}

/*
 * Send game plugin request with kActionUseHandCard, kParamCardIdList and kParamTargetPlayerList.
 */
- (void)sendUseHandCardRequestWithIsStrengthened:(BOOL)isStrengthened
{    
    EsObject *obj = [[EsObject alloc] init];
    [obj setInt:kActionUseHandCard forKey:kAction];    
    [obj setIntArray:_player.selectedCardIds forKey:kParamCardIdList];
    [obj setBool:isStrengthened forKey:kParamIsStrengthened];
    if (0 != _gameLayer.targetPlayerNames.count) {
        [obj setStringArray:_gameLayer.targetPlayerNames forKey:kParamTargetPlayerList];
    }
    [self sendGamePluginRequestWithObject:obj];
    
    NSLog(@"Send game plugin request with EsObject: %@", obj);
}

/*
 * Send game plugin request with kActionUseHeroSkill, kParamSelectedSkillId, kParamCardIdList and kParamTargetPlayerList.
 */
- (void)sendUseHeroSkillRequest
{    
    EsObject *obj = [[EsObject alloc] init];
    [obj setInt:kActionUseHeroSkill forKey:kAction];
    [obj setInt:_player.selectedSkillId forKey:kParamSelectedSkillId];
    if (0 != _player.selectedCardIds.count) {
        [obj setIntArray:_player.selectedCardIds forKey:kParamCardIdList];
    }
    if (0 != _gameLayer.targetPlayerNames.count) {
        [obj setStringArray:_gameLayer.targetPlayerNames forKey:kParamTargetPlayerList];
    }
    [self sendGamePluginRequestWithObject:obj];
    
    NSLog(@"Send game plugin request with EsObject: %@", obj);
}

/*
 * Send game plugin request with kActionCancel.
 */
- (void)sendCancelRequest
{    
    EsObject *obj = [[EsObject alloc] init];
    [obj setInt:kActionCancel forKey:kAction];
    [self sendGamePluginRequestWithObject:obj];
    
    NSLog(@"Send game plugin request with EsObject: %@", obj);
}

/*
 * Send game plugin request with kActionDiscard.
 */
- (void)sendDiscardRequest
{    
    EsObject *obj = [[EsObject alloc] init];
    [obj setInt:kActionDiscard forKey:kAction];
    [self sendGamePluginRequestWithObject:obj];
    
    NSLog(@"Send game plugin request with EsObject: %@", obj);
}

/*
 * Send game plugin request with kActionChooseCard.
 */
- (void)sendChooseCardRequest
{    
    EsObject *obj = [[EsObject alloc] init];
    [obj setInt:kActionChooseCard forKey:kAction];
    if (0 != _player.selectedCardIdxes.count) {
        [obj setIntArray:_player.selectedCardIdxes forKey:kParamCardIndexList];
    }
    if (0 != _player.selectedCardIds.count) {
        [obj setIntArray:_player.selectedCardIds forKey:kParamCardIdList];
    }
    [self sendGamePluginRequestWithObject:obj];
    
    NSLog(@"Send game plugin request with EsObject: %@", obj);
}

/*
 * Send game plugin request with kActionChooseColor.
 */
- (void)sendChooseColorRequest
{    
    EsObject *obj = [[EsObject alloc] init];
    [obj setInt:kActionChooseColor forKey:kAction];
    [obj setInt:_player.selectedColor forKey:kParamSelectedColor];
    [self sendGamePluginRequestWithObject:obj];
    
    NSLog(@"Send game plugin request with EsObject: %@", obj);
}

/*
 * Send game plugin request with kActionChooseSuits.
 */
- (void)sendChooseSuitsRequest
{    
    EsObject *obj = [[EsObject alloc] init];
    [obj setInt:kActionChooseSuits forKey:kAction];
    [obj setInt:_player.selectedSuits forKey:kParamSelectedSuits];
    [self sendGamePluginRequestWithObject:obj];
    
    NSLog(@"Send game plugin request with EsObject: %@", obj);
}

/*
 * Receive game plugin message event. Handle different returning actions.
 */
- (void)onGamePluginMessageEvent:(EsPluginMessageEvent *)e
{
    NSLog(@"Receive game plugin message with EsObject: %@", e.parameters);
    
    EsObject *obj = e.parameters;
    NSInteger action = [obj intWithKey:kAction];
    NSAssert(kActionInvalid != action, @"Invalid action in %@", NSStringFromSelector(_cmd));
    _gameLayer.selfPlayer.action = action;
    
//  Remaining card count
    _gameLayer.remainingCardCount = [obj intWithKey:kParamRemainingCardCount];
    
//  Receive public message with specified player name
    NSString *playerName = [obj stringWithKey:kParamPlayerName];
    _gameLayer.currPlayerName = playerName;
    _player = (_gameLayer && playerName) ? [_gameLayer playerWithName:playerName] : _gameLayer.selfPlayer;
    
//  Action handling
    switch (action) {
        case kActionStartGame:
//          TEMP
            self.users = [obj stringArrayWithKey:kParamUserList];
//            self.users = _es.managerHelper.userManager.users;
            [[BGRoomLayer sharedRoomLayer] showGameLayer];
            NSLog(@"All login users: %@", self.users);
            
            _gameLayer = [BGGameLayer sharedGameLayer];
            _playingDeck = _gameLayer.playingDeck;
            break;
            
        case kActionUpdateDeckHero:
            [_playingDeck updatePlayingDeckWithHeroIds:[obj intArrayWithKey:kParamCardIdList]];
            break;
            
        case kActionUpdateDeckSelectedHeros:
            [_gameLayer renderOtherPlayersHeroWithHeroIds:[obj intArrayWithKey:kParamCardIdList]];
            break;
        
        case kActionUpdateDeckCuttedCard:
            _playingDeck.isNeedClearDeck = YES;
        case kActionUpdateDeckUsedCard:
        case kActionUpdateDeckAssigning:
            [_playingDeck updatePlayingDeckWithCardIds:[obj intArrayWithKey:kParamCardIdList]];
            _player.handCardCount = [obj intWithKey:kParamHandCardCount];
            break;
            
        case kActionUpdateDeckHandCard:
            [_playingDeck updatePlayingDeckWithCardCount:[obj intWithKey:kParamHandCardCount]
                                            equipmentIds:[obj intArrayWithKey:kParamCardIdList]];
            break;
            
        case kActionInitPlayerHero:
            [_player renderHeroWithHeroId:[obj intWithKey:kParamSelectedHeroId]];
            break;
            
        case kActionInitPlayerCard:
            [_player renderHandCardWithCardIds:[obj intArrayWithKey:kParamCardIdList]];
            break;
            
        case kActionUpdatePlayerHero:
            [_player updateHeroWithBloodPoint:[obj intWithKey:kParamHeroBloodPoint]
                                   angerPoint:[obj intWithKey:kParamHeroAngerPoint]];
            break;
        
        case kActionUpdatePlayerHand:
            [_player updateHandCardWithCardIds:[obj intArrayWithKey:kParamCardIdList]];
            break;
            
        case kActionUpdatePlayerEquipment:
            [_player updateEquipmentWithCardIds:[obj intArrayWithKey:kParamCardIdList]];
            break;
            
        case kActionChooseCardToCut:
            [_player addPlayingMenu];
            [_player addProgressBar];
            [_gameLayer addProgressBarForOtherPlayers];
            break;
            
        case kActionPlayingCard:
            _playingDeck.isNeedClearDeck = YES; // 每张卡牌结算完后需要清除桌面
        case kActionChooseCardToUse:
        case kActionChooseCardToDiscard:
        case kActionChoosingColor:
        case kActionChoosingSuits:
            [_player addProgressBar];
            if (_player.playerName == _gameLayer.selfPlayer.playerName) {
                [_player addPlayingMenu];
                [_player enableHandCardWithCardIds:[obj intArrayWithKey:kParamAvailableIdList]
                               selectableCardCount:[obj intWithKey:kParamSelectableCardCount]];
            }
            break;
            
        case kActionChooseCardToExtract:
            _player.canExtractCardCount = [obj intWithKey:kParamExtractedCardCount];
            break;
            
        default:
            break;
    }
    
    [_player clearBuffer];
}

/*
 * Adjust the user's index, put the current user as first one.
 */
- (void)setUsers:(NSArray *)users
{
    NSMutableArray *mutableUsers = [users mutableCopy];
    NSMutableIndexSet *idxSet = [NSMutableIndexSet indexSet];
    
    [users enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
//      TEMP
        if ([obj isEqual:_es.managerHelper.userManager.me.userName]) {
//        if ([obj isEqual:_es.managerHelper.userManager.me]) {
            [mutableUsers removeObjectsAtIndexes:idxSet];
            [mutableUsers addObjectsFromArray:[users objectsAtIndexes:idxSet]];
            _users = mutableUsers;
            return;
        }
        
        [idxSet addIndex:idx];
    }];
}

#pragma mark - Public message
/*
 * Add public message event listener(Public message is sent by one player, but other players need register the event)
 */
- (void)addPublicMessageEventListener
{
    [_es.engine addEventListenerWithTarget:self
                                    action:@selector(onPublicMessageEvent:)
                           eventIdentifier:EsMessageType_PublicMessageEvent];
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
 * Receive all public message events. Broadcast to all players in the same room.
 */
- (void)onPublicMessageEvent:(EsPublicMessageEvent *)e
{
//    NSLog(@"Receive public message with EsObject: %@", e.esObject);
//    
//    NSInteger action = [e.esObject intWithKey:kAction];
//    NSAssert(kActionInvalid != action, @"Invalid action in %@", NSStringFromSelector(_cmd));
//    
//    switch (action) {
//        case kActionStartGame:
//            self.users = _es.managerHelper.userManager.users;
//            [[BGRoomLayer sharedRoomLayer] showGameLayer];
//            NSLog(@"All login users: %@", self.users);
//            
//            _gameLayer = [BGGameLayer sharedGameLayer];
//            _playingDeck = _gameLayer.playingDeck;
//            break;
//            
//        default:
//            break;
//    }
}

@end
