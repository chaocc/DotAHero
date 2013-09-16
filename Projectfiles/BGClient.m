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

@property (nonatomic, strong) EsObject *esObj;

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
        _esObj = [[EsObject alloc] init];
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
    NSLog(@"Connnection Failed: %@", e.description);
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
    [_esObj setInt:kActionReadyStartGame forKey:kAction];
    [self sendRoomPluginRequestWithObject:_esObj];
    
    NSLog(@"Send room plugin request with EsObject: %@", _esObj);
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
 * Send game plugin request with kActionStartGame. Called in game layer.
 */
- (void)sendStartGameRequest
{
    [_esObj setInt:kActionStartGame forKey:kAction];
    [_esObj setInt:kPlayerCountSix forKey:kParamPlayerCount];
    [self sendGamePluginRequestWithObject:_esObj];
    
    NSLog(@"Send game plugin request with EsObject: %@", _esObj);
}

/*
 * Send game plugin request with kActionStartRound. Called in playing deck layer.
 */
- (void)sendStartRoundRequest
{
    [_esObj setInt:kActionStartRound forKey:kAction];
    [self sendGamePluginRequestWithObject:_esObj];
    
    NSLog(@"Send game plugin request with EsObject: %@", _esObj);
}

/*
 * Send game plugin request with kActionChooseHero and kParamCardIdList.
 */
- (void)sendChooseHeroIdRequest
{    
    [_esObj setInt:kActionChoseHero forKey:kAction];
    NSArray *heroIds = [NSArray arrayWithObject:@(_player.selectedHeroId)];
    [_esObj setIntArray:heroIds forKey:kParamCardIdList];
    [self sendGamePluginRequestWithObject:_esObj];
    
    NSLog(@"Send game plugin request with EsObject: %@", _esObj);
}

/*
 * Send game plugin request with kActionUseHandCard, kParamCardIdList and kParamTargetPlayerList.
 */
- (void)sendUseHandCardRequestWithIsStrengthened:(BOOL)isStrengthened
{    
    [_esObj setInt:kActionUseHandCard forKey:kAction];    
    [_esObj setIntArray:_player.selectedCardIds forKey:kParamCardIdList];
    [_esObj setBool:isStrengthened forKey:kParamIsStrengthened];
    if (0 != _gameLayer.targetPlayerNames.count) {
        [_esObj setStringArray:_gameLayer.targetPlayerNames forKey:kParamTargetPlayerList];
    }
    [self sendGamePluginRequestWithObject:_esObj];
    [self sendPublicMessageRequestWithObject:_esObj];
    
    NSLog(@"Send game plugin request with EsObject: %@", _esObj);
}

/*
 * Send game plugin request with kActionUseHeroSkill, kParamSelectedSkillId, kParamCardIdList and kParamTargetPlayerList.
 */
- (void)sendUseHeroSkillRequest
{    
    [_esObj setInt:kActionUseHeroSkill forKey:kAction];
    [_esObj setInt:_player.selectedSkillId forKey:kParamSelectedSkillId];
    if (0 != _player.selectedCardIds.count) {
        [_esObj setIntArray:_player.selectedCardIds forKey:kParamCardIdList];
    }
    if (0 != _gameLayer.targetPlayerNames.count) {
        [_esObj setStringArray:_gameLayer.targetPlayerNames forKey:kParamTargetPlayerList];
    }
    [self sendGamePluginRequestWithObject:_esObj];
    
    NSLog(@"Send game plugin request with EsObject: %@", _esObj);
}

/*
 * Send game plugin request with kActionCancel.
 */
- (void)sendCancelRequest
{    
    [_esObj setInt:kActionCancel forKey:kAction];
    [self sendGamePluginRequestWithObject:_esObj];
    
    NSLog(@"Send game plugin request with EsObject: %@", _esObj);
}

/*
 * Send game plugin request with kActionDiscard.
 */
- (void)sendDiscardRequest
{   
    [_esObj setInt:kActionDiscard forKey:kAction];
    [self sendGamePluginRequestWithObject:_esObj];
    
    NSLog(@"Send game plugin request with EsObject: %@", _esObj);
}

/*
 * Send game plugin request with kActionChooseCard.
 */
- (void)sendChooseCardRequest
{    
    [_esObj setInt:kActionChoseCardToUse forKey:kAction];
    if (0 != _player.selectedCardIdxes.count) {
        [_esObj setIntArray:_player.selectedCardIdxes forKey:kParamCardIndexList];
    }
    if (0 != _player.selectedCardIds.count) {
        [_esObj setIntArray:_player.selectedCardIds forKey:kParamCardIdList];
    }
    [self sendGamePluginRequestWithObject:_esObj];
    
    NSLog(@"Send game plugin request with EsObject: %@", _esObj);
}

/*
 * Send game plugin request with kActionChooseColor.
 */
- (void)sendChooseColorRequest
{    
    [_esObj setInt:kActionChoseColor forKey:kAction];
    [_esObj setInt:_player.selectedColor forKey:kParamSelectedColor];
    [self sendGamePluginRequestWithObject:_esObj];
    
    NSLog(@"Send game plugin request with EsObject: %@", _esObj);
}

/*
 * Send game plugin request with kActionChooseSuits.
 */
- (void)sendChooseSuitsRequest
{    
    [_esObj setInt:kActionChoseSuits forKey:kAction];
    [_esObj setInt:_player.selectedSuits forKey:kParamSelectedSuits];
    [self sendGamePluginRequestWithObject:_esObj];
    
    NSLog(@"Send game plugin request with EsObject: %@", _esObj);
}

/*
 * Remove some games nodes(Sprite/Menu) of previous current player on the screen
 * (Since some nodes can't be removed if make game running in the background)
 */
- (void)removeGameNodes
{
    [_playingDeck removeResidualNodes];
    [_player removePlayingMenu];
    [_player removeProgressBar];
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
    _gameLayer.action = action;
    
//  Remove some games nodes(Sprite/Menu) on the screen before handle action
    [self removeGameNodes];
    
//  Remaining card count
    _gameLayer.remainingCardCount = [obj intWithKey:kParamRemainingCardCount];
    
//  Receive the player name that is current player(出牌的玩家)
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
            [_playingDeck updateWithHeroIds:[obj intArrayWithKey:kParamCardIdList]];
            break;
            
        case kActionUpdateDeckSelectedHeros:
            [_gameLayer renderOtherPlayersHeroWithHeroIds:[obj intArrayWithKey:kParamCardIdList]];
            break;
        
        case kActionUpdateDeckCuttedCard:
        case kActionUpdateDeckUsedCard:
        case kActionUpdateDeckAssigning:
            [_playingDeck updateWithCardIds:[obj intArrayWithKey:kParamCardIdList]];
            _playingDeck.maxCardId = [obj intWithKey:kParamMaxFigureCardId];
            break;
            
        case kActionUpdateDeckPlayerCard:
            [_playingDeck updateWithCardCount:[obj intWithKey:kParamHandCardCount]
                                 equipmentIds:[obj intArrayWithKey:kParamCardIdList]];
            break;
            
        case kActionClearPlayingDeck:
            [_playingDeck clearExistingUsedCards];
            break;
            
        case kActionInitPlayerHero:
            [_player renderHeroWithHeroId:[obj intWithKey:kParamSelectedHeroId]];
            break;
            
        case kActionInitPlayerCard:
            [_player addHandAreaWithCardIds:[obj intArrayWithKey:kParamCardIdList]];
            break;
            
        case kActionUpdatePlayerHero:
            [_player updateHeroWithBloodPoint:[obj intWithKey:kParamHeroBloodPoint]
                                   angerPoint:[obj intWithKey:kParamHeroAngerPoint]];
            break;
        
        case kActionUpdatePlayerHand:
        case kActionUpdatePlayerHandExtracted:
            [_player updateHandCardWithCardIds:[obj intArrayWithKey:kParamCardIdList]
                                     cardCount:[obj intWithKey:kParamHandCardCount]];
            break;
            
        case kActionUpdatePlayerEquipment:
        case kActionUpdatePlayerEquipmentExtracted:
            [_player updateEquipmentWithCardIds:[obj intArrayWithKey:kParamCardIdList]];
            break;
            
        case kActionChooseCardToCut:
            _gameLayer.state = kGameStateCutting;
            [_player addPlayingMenu];
            [_player addProgressBar];
            [_gameLayer addProgressBarForOtherPlayers];
            break;
            
        case kActionPlayingCard:
        case kActionChooseCardToUse:
        case kActionChooseCardToDiscard:
        case kActionChoosingColor:
        case kActionChoosingSuits:
            [_player addProgressBar];
            if (_player.isSelfPlayer) {
                [_player addPlayingMenu];
                [_player enableHandCardWithCardIds:[obj intArrayWithKey:kParamAvailableIdList]
                               selectableCardCount:[obj intWithKey:kParamSelectableCardCount]];
            }
            break;
            
        case kActionChooseCardToExtract:
            _player.extractableCardCount = [obj intWithKey:kParamExtractableCardCount];
            break;
            
        default:
            break;
    }
    
    [_player clearBuffer];
}

/*
 * Adjust the user's index, put the self user as first one.
 */
- (void)setUsers:(NSArray *)users
{
    NSMutableArray *mutableUsers = [users mutableCopy];
    NSMutableIndexSet *idxSet = [NSMutableIndexSet indexSet];
    NSUInteger idx = 0;
    
    for (id obj in users) {
//      TEMP
        if ([obj isEqual:_es.managerHelper.userManager.me.userName]) {
//        if ([obj isEqual:_es.managerHelper.userManager.me]) {
            [mutableUsers removeObjectsAtIndexes:idxSet];
            [mutableUsers addObjectsFromArray:[users objectsAtIndexes:idxSet]];
            _users = mutableUsers;
            break;
        }
        [idxSet addIndex:idx]; idx++;
    }
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
    if ([_player.playerName isEqualToString:e.userName]) {
        return;
    }
    
//  Receive the player who send the public message
    _gameLayer.currPlayerName = e.userName;
    _player = (_gameLayer) ? [_gameLayer playerWithName:e.userName] : nil;
    
    NSLog(@"Receive public message with EsObject: %@", e.esObject);
    
    NSInteger action = [e.esObject intWithKey:kAction];
    NSAssert(kActionInvalid != action, @"Invalid action in %@", NSStringFromSelector(_cmd));
    
//  Action handling
    switch (action) {
        case kActionPlayingCard:
        case kActionChooseCardToUse:
//            [_player addProgressBar];
            break;
        
        case kActionChoseCardToUse:
            [_playingDeck updateWithCardIds:[_esObj intArrayWithKey:kParamCardIdList]];
            break;
            
        case kActionChoseCardToExtract:
            
            break;
            
        default:
            break;
    }
}

@end
