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

@property (nonatomic, strong) BGGameLayer *gameLayer;
@property (nonatomic, strong) BGPlayingDeck *playingDeck;
@property (nonatomic, strong) BGPlayer *player;

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
 * Send room request with all plugins to server. Call in room list layer.
 */
- (void)joinRoom
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
    
    switch (action) {
        case kActionReadyStartGame:
            NSLog(@"Receive room plugin message with kActionReadyStartGame(%i)", action);
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
 * 1. Send game plugin request with action-startGame. Called in game layer.
 * 2. Send public message
 */
- (void)sendStartGameRequest
{
    NSLog(@"Send game plugin request with kActionStartGame(%i)", kActionStartGame);
    EsObject *obj = [[EsObject alloc] init];
    [obj setInt:kActionStartGame forKey:kAction];
    [self sendPublicMessageRequestWithObject:obj];
}

/*
 * Send game plugin request with kActionChooseHeroId and kParamCardIdList.
 */
- (void)sendChooseHeroIdRequest
{
    NSLog(@"Send game plugin request with kActionChooseHeroId(%i)", kActionChooseHeroId);
    EsObject *obj = [[EsObject alloc] init];
    [obj setInt:kActionChooseHeroId forKey:kAction];
    NSArray *heroIds = [NSArray arrayWithObject:@(_player.selectedHeroId)];
    [obj setIntArray:heroIds forKey:kParamCardIdList];
    NSLog(@"ParamHeroIdList: %@", heroIds);
    
    [self sendGamePluginRequestWithObject:obj];
}

/*
 * Send game plugin request with kActionUseHandCard, kParamCardIdList and kParamTargetPlayerList.
 */
- (void)sendUseHandCardRequestWithIsStrengthened:(BOOL)isStrengthened
{
    NSLog(@"Send game plugin request with kActionUseHandCard(%i)", kActionUseHandCard);
    EsObject *obj = [[EsObject alloc] init];
    [obj setInt:kActionUseHandCard forKey:kAction];
    
    [obj setIntArray:_player.selectedCardIds forKey:kParamCardIdList];
    NSLog(@"ParamCardIdList: %@", _player.selectedCardIds);

    [obj setBool:isStrengthened forKey:kParamIsStrengthened];
    NSLog(@"ParamIsStrengthened: %i", isStrengthened);
    
    if (_gameLayer.targetPlayerNames.count != 0) {
        [obj setStringArray:_gameLayer.targetPlayerNames forKey:kParamTargetPlayerList];
        NSLog(@"ParamTargetPlayerList: %@", _gameLayer.targetPlayerNames);
    }
    
    [self sendGamePluginRequestWithObject:obj];
}

/*
 * Send game plugin request with kActionUseHeroSkill, kParamSelectedSkillId, kParamCardIdList and kParamTargetPlayerList.
 */
- (void)sendUseHeroSkillRequest
{
    NSLog(@"Send game plugin request with kActionUseHeroSkill(%i)", kActionUseHeroSkill);
    EsObject *obj = [[EsObject alloc] init];
    [obj setInt:kActionUseHeroSkill forKey:kAction];
    
    [obj setInt:_player.selectedSkillId forKey:kParamSelectedSkillId];
    NSLog(@"ParamSelectedSkillId: %i", _player.selectedSkillId);
    
    if (_player.selectedCardIds.count != 0) {
        [obj setIntArray:_player.selectedCardIds forKey:kParamCardIdList];
        NSLog(@"ParamCardIdList: %@", _player.selectedCardIds);
    }
    
    if (_gameLayer.targetPlayerNames.count != 0) {
        [obj setStringArray:_gameLayer.targetPlayerNames forKey:kParamTargetPlayerList];
        NSLog(@"ParamTargetPlayerList: %@", _gameLayer.targetPlayerNames);
    }
    
    [self sendGamePluginRequestWithObject:obj];
}

/*
 * Send game plugin request with kActionCancel.
 */
- (void)sendCancelRequest
{
    NSLog(@"Send game plugin request with kActionCancel(%i)", kActionCancel);
    EsObject *obj = [[EsObject alloc] init];
    [obj setInt:kActionCancel forKey:kAction];
    [self sendGamePluginRequestWithObject:obj];
}

/*
 * Send game plugin request with kActionDiscard.
 */
- (void)sendDiscardRequest
{
    NSLog(@"Send game plugin request with kActionDiscard(%i)", kActionDiscard);
    EsObject *obj = [[EsObject alloc] init];
    [obj setInt:kActionDiscard forKey:kAction];
    [self sendGamePluginRequestWithObject:obj];
}

/*
 * Send game plugin request with kActionChooseCard.
 */
- (void)sendChooseCardRequest
{
    NSLog(@"Send game plugin request with kActionChooseCard(%i)", kActionChooseCard);
    EsObject *obj = [[EsObject alloc] init];
    [obj setInt:kActionChooseCard forKey:kAction];
    
    if (_player.selectedCardIdxes.count != 0) {
        [obj setIntArray:_player.selectedCardIdxes forKey:kParamCardIndexList];
        NSLog(@"ParamCardIndexList: %@", _player.selectedCardIdxes);
    }
    if (_player.selectedCardIds.count != 0) {
        [obj setIntArray:_player.selectedCardIds forKey:kParamCardIdList];
        NSLog(@"ParamCardIdList: %@", _player.selectedCardIds);
    }
    
    [self sendGamePluginRequestWithObject:obj];
}

/*
 * Send game plugin request with kActionChooseColor.
 */
- (void)sendChooseColorRequest
{
    NSLog(@"Send game plugin request with kActionChooseColor(%i)", kActionChooseColor);
    EsObject *obj = [[EsObject alloc] init];
    [obj setInt:kActionChooseColor forKey:kAction];
    
    [obj setInt:_player.selectedColor forKey:kParamSelectedColor];
    NSLog(@"ParamSelectedColor: %i", _player.selectedColor);
    
    [self sendGamePluginRequestWithObject:obj];
}

/*
 * Send game plugin request with kActionChooseSuits.
 */
- (void)sendChooseSuitsRequest
{
    NSLog(@"Send game plugin request with kActionChooseSuits(%i)", kActionChooseSuits);
    EsObject *obj = [[EsObject alloc] init];
    [obj setInt:kActionChooseSuits forKey:kAction];
    
    [obj setInt:_player.selectedSuits forKey:kParamSelectedSuits];
    NSLog(@"ParamSelectedSuits: %i", _player.selectedSuits);
    
    [self sendGamePluginRequestWithObject:obj];
}

/*
 * Receive game plugin message event. Handle different returning actions.
 */
- (void)onGamePluginMessageEvent:(EsPluginMessageEvent *)e
{
    EsObject *obj = e.parameters;
    NSInteger action = [obj intWithKey:kAction];
    NSAssert(action != kActionInvalid, @"Invalid action in %@", NSStringFromSelector(_cmd));
    _player.action = action;
    
    NSArray *array = nil;
    NSUInteger count;
    
//  Remaining card count
    NSUInteger remainingCardCount = [obj intWithKey:kParamRemainingCardCount];
    if (remainingCardCount != 0) {
        _gameLayer.remainingCardCount = remainingCardCount;
    }
    
    switch (action) {
        case kActionUpdateDeckHero:
            NSLog(@"Receive game plugin message with kActionUpdateDeckHero(%i)", action);
            array = [obj intArrayWithKey:kParamCardIdList];
            NSLog(@"ParamToBeSelectedHeroIdList: %@", array);
            [_playingDeck updatePlayingDeckWithHeroIds:array];
            break;
            
        case kActionInitPlayerHero:
            NSLog(@"Receive game plugin message with kActionSendSelectedHero(%i)", action);
            NSInteger heroId = [obj intWithKey:kParamSelectedHeroId];
            NSLog(@"ParamSelectedHeroId: %i", heroId);
            [_player renderHeroWithHeroId:heroId];
            break;
            
        case kActionInitPlayerCard:
            NSLog(@"Receive game plugin message with kActionDealHandCard(%i)", action);
            array = [obj intArrayWithKey:kParamCardIdList];
            NSLog(@"ParamHandCardIdList: %@", array);
            [_player renderHandCardWithCardIds:array];
            break;
            
        case kActionUpdatePlayerHero:
            NSLog(@"Receive game plugin message with kActionUpdatePlayerHero(%i)", action);
            NSInteger bloodPoint = [obj intWithKey:kParamHeroBloodPoint];
            NSUInteger angerPoint = [obj intWithKey:kParamHeroAngerPoint];
            NSLog(@"ParamHeroBloodPoint: %i", bloodPoint);
            NSLog(@"ParamHeroAngerPoint: %i", angerPoint);
            [_player updateHeroWithBloodPoint:bloodPoint
                                   angerPoint:angerPoint];
            break;
        
        case kActionUpdatePlayerHand:
            NSLog(@"Receive game plugin message with kActionUpdatePlayerHand(%i)", action);
            array = [obj intArrayWithKey:kParamCardIdList];
            count = [obj intWithKey:kParamSelectableCardCount];
            NSLog(@"ParamHandCardIdList: %@", array);
            NSLog(@"ParamSelectableCardCount: %i", count);
            [_player updateHandCardWithCardIds:array
                           selectableCardCount:count];
            break;
            
        case kActionUpdatePlayerEquipment:
            NSLog(@"Receive game plugin message with kActionUpdatePlayerEquipment(%i)", action);
            array = [obj intArrayWithKey:kParamCardIdList];
            NSLog(@"ParamEquipmentCardIdList: %@", array);
            [_player updateEquipmentWithCardIds:array];
            break;
            
        case kActionPlayingCard:
        case kActionChooseCardToUse:
        case kActionChooseCardToCompare:
        case kActionChooseCardToDiscard:
        case kActionChoosingColor:
        case kActionChoosingSuits:
            NSLog(@"Receive game plugin message with kActionPlay/ChooseCard(%i)", action);
            array = [obj intArrayWithKey:kParamCardIdList];
            NSLog(@"ParamAvaliableHandCardIdList: %@", array);
            [_player addPlayingMenu];
            [_player enableHandCardWithCardIds:array];
            break;
            
        case kActionChooseCardToExtract:
            NSLog(@"Receive game plugin message with kActionChooseCardToExtract(%i)", action);
            count = [obj intWithKey:kParamExtractedCardCount];
            NSLog(@"ParamExtractedCardCount: %i", count);
            _player.canExtractCardCount = count;
            break;
            
        case kActionUpdateDeckUsedCard:
            NSLog(@"Receive game plugin message with kActionUpdateDeckUsedCard(%i)", action);
            array = [obj intArrayWithKey:kParamCardIdList];
            NSLog(@"ParamUsedCardIdList: %@", array);
            [_playingDeck updatePlayingDeckWithCardIds:array];
            break;
            
        case kActionUpdateDeckHandCard:
            NSLog(@"Receive game plugin message with kActionUpdateDeckHandCard(%i)", action);
            count = [obj intWithKey:kParamHandCardCount];
            array = [obj intArrayWithKey:kParamCardIdList];
            NSLog(@"ParamHandCardCount: %i", count);
            NSLog(@"ParamEquipmentCardIdList: %@", array);
            [_playingDeck updatePlayingDeckWithCardCount:count
                                            equipmentIds:array];
            break;
            
        case kActionUpdateDeckPlayingCard:
            
            break;
            
        default:
            break;
    }
    
    [_player clearBuffer];
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

///*
// * Send public message with action-startTurn and sourcePlayerName
// */
//- (void)sendStartTurnPublicMessage
//{
//    EsObject *obj = [[EsObject alloc] init];
//    [obj setInt:kActionStartTurn forKey:kAction];
//    [obj setString:_player.playerName forKey:kParamSourcePlayerName];
//    [self sendPublicMessageRequestWithObject:obj];
//    
//    NSLog(@"Send public message with action-startTurn(%i)", kActionStartGame);
//    NSLog(@"param-sourcePlayerName: %@", _player.playerName);
//}

/*
 * Receive all public message events. Broadcast to all players in the same room.
 */
- (void)onPublicMessageEvent:(EsPublicMessageEvent *)e
{
    EsObject *obj = e.esObject;
    NSInteger action = [obj intWithKey:kAction];
    NSAssert(action != kActionInvalid, @"Invalid action in %@", NSStringFromSelector(_cmd));
    
    NSArray *array = nil;
    
    switch (action) {
        case kActionStartGame:
            NSLog(@"Receive public message with kActionStartGame(%i)", action);
            self.users = _es.managerHelper.userManager.users;
            [[BGRoomLayer sharedRoomLayer] showGameLayer];
            NSLog(@"All login users: %@", self.users);
            
            _gameLayer = [BGGameLayer sharedGameLayer];
            _playingDeck = _gameLayer.playingDeck;
            _player = _gameLayer.currentPlayer;
            break;
            
        case kActionInitPlayerHero:
            NSLog(@"Receive public message with kActionInitPlayerHero(%i)", action);
            array = [obj intArrayWithKey:kParamCardIdList];
            NSLog(@"ParamAllHeroIdList: %@", array);
            [_gameLayer renderOtherPlayersHeroWithHeroIds:array];
            break;
            
        case kActionPlayingCard:
             NSLog(@"Receive public message with kActionPlayingCard(%i)", action);
            _playingDeck.isNeedClearDeck = YES; // 每张卡牌结算完后需要清除桌面
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
