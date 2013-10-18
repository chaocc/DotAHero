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
 * Send game plugin request with kActionStartGame. Called in game layer.
 */
- (void)sendStartGameRequest
{
    EsObject *obj = [[EsObject alloc] init];
    [obj setInt:kActionStartGame forKey:kAction];
    [obj setInt:kPlayerCountTwo forKey:kParamPlayerCount];
    [self sendGamePluginRequestWithObject:obj];
    
    NSLog(@"Send game plugin request with EsObject: %@", obj);
}

/*
 * Send game plugin request with kActionStartRound. Called in playing deck layer.
 */
- (void)sendStartRoundRequest
{
    EsObject *obj = [[EsObject alloc] init];
    [obj setInt:kActionStartRound forKey:kAction];
    [self sendGamePluginRequestWithObject:obj];
    
    NSLog(@"Send game plugin request with EsObject: %@", obj);
}

/*
 * Send game plugin request with kActionChooseHero and kParamCardIdList.
 */
- (void)sendChoseHeroIdRequest
{
    EsObject *obj = [[EsObject alloc] init];
    [obj setInt:kActionChoseHero forKey:kAction];
    NSArray *heroIds = [NSArray arrayWithObject:@(_player.selectedHeroId)];
    [obj setIntArray:heroIds forKey:kParamCardIdList];
    [self sendGamePluginRequestWithObject:obj];
    
    NSLog(@"Send game plugin request with EsObject: %@", obj);
}

/*
 * Send game plugin request with kActionUseHandCard, kParamCardIdList and kParamTargetPlayerList.
 */
- (void)sendUseHandCardRequest
{
    EsObject *obj = [[EsObject alloc] init];
    [obj setInt:kActionUseHandCard forKey:kAction];
    [obj setIntArray:_player.selectedCardIds forKey:kParamCardIdList];
    [obj setBool:_player.isStrengthened forKey:kParamIsStrengthened];
    if (_gameLayer.targetPlayerNames.count > 0) {
        [obj setStringArray:_gameLayer.targetPlayerNames forKey:kParamTargetPlayerList];
    }
    [self sendGamePluginRequestWithObject:obj];
    
    NSLog(@"Send game plugin request with EsObject: %@", obj);
}

/*
 * Send game plugin request with kActionUseEquipment, kParamCardIdList;
 */
- (void)sendUseEquipmentRequest
{
    EsObject *obj = [[EsObject alloc] init];
    [obj setInt:kActionUseEquipment forKey:kAction];
    if (_player.selectedCardIds > 0) {
        [obj setIntArray:_player.selectedCardIds forKey:kParamCardIdList];
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
    if (_player.selectedCardIds.count > 0) {
        [obj setIntArray:_player.selectedCardIds forKey:kParamCardIdList];
    }
    if (_gameLayer.targetPlayerNames.count > 0) {
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
 * Send game plugin request with kActionChoseCardToCut.
 */
- (void)sendChoseCardToCutRequest
{
    EsObject *obj = [[EsObject alloc] init];
    [obj setInt:kActionChoseCardToCut forKey:kAction];
    [obj setIntArray:_player.selectedCardIds forKey:kParamCardIdList];
    [self sendGamePluginRequestWithObject:obj];
    
    NSLog(@"Send game plugin request with EsObject: %@", obj);
}

/*
 * Send game plugin request with kActionChoseCardToUse.
 */
- (void)sendChoseCardToUseRequest
{
    EsObject *obj = [[EsObject alloc] init];
    [obj setInt:kActionChoseCardToUse forKey:kAction];
    if (_player.selectedCardIdxes.count > 0) {
        [obj setIntArray:_player.selectedCardIdxes forKey:kParamCardIndexList];
    }
    if (_player.selectedCardIds.count > 0) {
        [obj setIntArray:_player.selectedCardIds forKey:kParamCardIdList];
    }
    [self sendGamePluginRequestWithObject:obj];
    
    NSLog(@"Send game plugin request with EsObject: %@", obj);
}

/*
 * Send game plugin request with kActionChoseCardToGet.
 */
- (void)sendChoseCardToGetRequest
{
    EsObject *obj = [[EsObject alloc] init];
    [obj setInt:kActionChoseCardToGet forKey:kAction];
    if (_player.selectedCardIdxes.count > 0) {
        [obj setIntArray:_player.selectedCardIdxes forKey:kParamCardIndexList];
    }
    if (_player.selectedCardIds.count > 0) {
        [obj setIntArray:_player.selectedCardIds forKey:kParamCardIdList];
    }
    [self sendGamePluginRequestWithObject:obj];
    
    NSLog(@"Send game plugin request with EsObject: %@", obj);
}

/*
 * Send game plugin request with kActionChoseCardToGive.
 * Check need broadcast gave card ids or card count
 */
- (void)sendChoseCardToGiveRequest
{
    EsObject *obj = [[EsObject alloc] init];
    [obj setInt:kActionChoseCardToGive forKey:kAction];    
    if (_player.selectedCardIds.count > 0) {
        [obj setIntArray:_player.selectedCardIds forKey:kParamCardIdList];
    }
    [self sendGamePluginRequestWithObject:obj];
    
    NSLog(@"Send game plugin request with EsObject: %@", obj);
}

/*
 * Send game plugin request with kActionChoseCardToDiscard.
 */
- (void)sendChoseCardToDiscardRequest
{
    EsObject *obj = [[EsObject alloc] init];
    [obj setInt:kActionChoseCardToDiscard forKey:kAction];
    if (_player.selectedCardIdxes.count > 0) {
        [obj setIntArray:_player.selectedCardIdxes forKey:kParamCardIndexList];
    }
    if (_player.selectedCardIds.count > 0) {
        [obj setIntArray:_player.selectedCardIds forKey:kParamCardIdList];
    }
    [self sendGamePluginRequestWithObject:obj];
    
    NSLog(@"Send game plugin request with EsObject: %@", obj);
}

/*
 * Send game plugin request with kActionChoseColor.
 */
- (void)sendChoseColorRequest
{
    EsObject *obj = [[EsObject alloc] init];
    [obj setInt:kActionChoseColor forKey:kAction];
    [obj setInt:_player.selectedColor forKey:kParamSelectedColor];
    [self sendGamePluginRequestWithObject:obj];
    
    NSLog(@"Send game plugin request with EsObject: %@", obj);
}

/*
 * Send game plugin request with kActionChoseSuits.
 */
- (void)sendChoseSuitsRequest
{
    EsObject *obj = [[EsObject alloc] init];
    [obj setInt:kActionChoseSuits forKey:kAction];
    [obj setInt:_player.selectedSuits forKey:kParamSelectedSuits];
    [self sendGamePluginRequestWithObject:obj];
    
    NSLog(@"Send game plugin request with EsObject: %@", obj);
}

- (void)sendAsignCardRequest
{
    EsObject *obj = [[EsObject alloc] init];
    [obj setInt:kActionAssignCard forKey:kAction];
    [obj setIntArray:_player.selectedCardIds forKey:kParamCardIdList];
    [self sendGamePluginRequestWithObject:obj];
    
    NSLog(@"Send game plugin request with EsObject: %@", obj);
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
    [_player removeTextPrompt];
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
    _gameLayer.reason = [obj stringWithKey:kParamPlayerUpdateReason];
    [_gameLayer mapActionToGameState];
    
//  ...TEMP...
//  Remove some games nodes(Sprite/Menu) on the screen before handle action
//    [self removeGameNodes];
    
//  Receive the player name that is self player
    _player = _gameLayer.selfPlayer;
    
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
            
        case kActionDeckDealHeros:
            [_playingDeck showToBeSelectedHerosWithHeroIds:[obj intArrayWithKey:kParamCardIdList]];
            break;
            
        case kActionDeckShowAllSelectedHeros:
            [_gameLayer renderOtherPlayersHeroWithHeroIds:[obj intArrayWithKey:kParamCardIdList]];
            break;
        
        case kActionDeckShowAllCuttedCards:
            [_gameLayer removeProgressBarForOtherPlayers];
            [_playingDeck showCuttedCardWithCardIds:[obj intArrayWithKey:kParamCardIdList]
                                          maxCardId:[obj intWithKey:kParamMaxFigureCardId]];
            break;
            
        case kActionDeckShowTopPileCard:
            [_playingDeck showTopPileCardWithCardIds:[obj intArrayWithKey:kParamCardIdList]];
            break;
            
        case kActionDeckShowPlayerCard:
            [_playingDeck showPopupWithHandCount:[obj intWithKey:kParamHandCardCount]
                                    equipmentIds:[obj intArrayWithKey:kParamCardIdList]];
            break;
            
        case kActionDeckShowAssignedCard:
            [_playingDeck showPopupWithAssignedCardIds:[obj intArrayWithKey:kParamCardIdList]];
            break;
            
        case kActionPlayerSelectedHero:
            [_player renderHeroWithHeroId:[obj intWithKey:kParamSelectedHeroId]];
            break;
            
        case kActionPlayerDealCard:
            [_player addHandAreaWithCardIds:[obj intArrayWithKey:kParamCardIdList]];
            _gameLayer.remainingCardCount = [obj intWithKey:kParamRemainingCardCount];
            break;
        
        case kActionPlayerUpdateHand:
            [_player updateHandCardWithCardIds:[obj intArrayWithKey:kParamCardIdList]];
            break;
            
        case kActionPlayerUpdateEquipment:
            [_player updateEquipmentWithCardIds:[obj intArrayWithKey:kParamCardIdList]];
            break;
            
        case kActionChooseCardToCut:
            [_player addProgressBar];
            [_player addPlayingMenu];
            [_player addTextPrompt];
            [_gameLayer addProgressBarForOtherPlayers];
            break;
            
        case kActionPlayCard:
        case kActionChooseCardToUse:
        case kActionChooseColor:
        case kActionChooseSuits:
            [_gameLayer.targetPlayerNames removeAllObjects];
        case kActionChooseCardToGive:
            [_player enableHandCardWithCardIds:[obj intArrayWithKey:kParamAvailableIdList]
                           selectableCardCount:[obj intWithKey:kParamSelectableCardCount]];
            break;
            
        case kActionChooseCardToGet:
            [_player clearSelectedObjectBuffer];
            _player.selectableCardCount = [obj intWithKey:kParamSelectableCardCount];
            break;
            
        case kActionChooseCardToDiscard:
            _player.isOptionalDiscard = [obj intWithKey:kParamIsOptionalDiscard];
            [_player enableAllHandCardsWithSelectableCount:[obj intWithKey:kParamSelectableCardCount]];
            break;
            
        default:
            break;
    }
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
//  Handle received public message
    NSLog(@"Player name: %@", e.userName);
    NSLog(@"Receive public message with EsObject: %@", e.esObject);
    
    EsObject *obj = e.esObject;
    NSInteger action = [e.esObject intWithKey:kAction];
    NSAssert(kActionInvalid != action, @"Invalid action in %@", NSStringFromSelector(_cmd));
    
//  Remaining card count
    _gameLayer.remainingCardCount = [obj intWithKey:kParamRemainingCardCount];

//  Receive the player who send the public message. Set the target player names.
    _gameLayer.currPlayerName = e.userName;
    BGPlayer *currPlayer = (_gameLayer) ? _gameLayer.currPlayer : nil;
//    [self setTargetPlayerNames:[obj intArrayWithKey:kParamTargetPlayerList]];
    [_gameLayer.targetPlayerNames addObjectsFromArray:[obj intArrayWithKey:kParamTargetPlayerList]];
    
//  Game state with action
    _gameLayer.action = action;
    if ([self isNeedSkipSelfPlayer]) return;
    [_gameLayer mapActionToGameState];
        
//  Action handling
    switch (action) {
        case kActionPlayCard:
        case kActionChooseCardToUse:
        case kActionChooseColor:
        case kActionChooseSuits:
        case kActionChooseCardToGet:
        case kActionChooseCardToAssign:
        case kActionChooseCardToDiscard:
            [currPlayer addProgressBar];
            break;
            
        case kActionUseHandCard:
        case kActionChoseCardToUse:
            [currPlayer useHandCardWithCardIds:[obj intArrayWithKey:kParamCardIdList]
                                isStrengthened:[obj boolWithKey:kParamIsStrengthened]];
            break;
            
        case kActionChoseColor:
            currPlayer.selectedColor = [obj intWithKey:kParamSelectedColor];
            break;
            
        case kActionChoseSuits:
            currPlayer.selectedSuits = [obj intWithKey:kParamSelectedSuits];
            break;
            
        case kActionDiscard:
        case kActionChoseCardToDiscard:
            [_playingDeck showUsedCardWithCardIds:[obj intArrayWithKey:kParamCardIdList]];
            break;
            
        case kActionAssignCard:
            [_playingDeck clearAllExistingCards];
        case kActionDrawCard:
            [currPlayer drawCardWithCardCount:[obj intWithKey:kParamCardCountChanged]]; // kParamCardCount
            break;
            
        case kActionPlayerUpdateHand:
            currPlayer.handCardCount += [obj intWithKey:kParamCardCountChanged];
            break;
            
        case kActionPlayerUpdateHero:
            [currPlayer updateHeroWithBloodPoint:[obj intWithKey:kParamHeroBloodPointChanged]
                                      angerPoint:[obj intWithKey:kParamHeroAngerPointChanged]];
            break;
            
        case kActionFaceDownPileCard:
            [_playingDeck showFacedDownCardWithCount:[obj intWithKey:kParamCardCount]];
            break;
            
        case kActionDeckShowTopPileCard:
            [_playingDeck showTopPileCardWithCardIds:[obj intArrayWithKey:kParamCardIdList]];
            break;
            
        case kActionPlayerGetDeckCard:
            [currPlayer getCardFromDeckWithCardIds:[obj intArrayWithKey:kParamCardIdList]];
            break;
            
        case kActionChoseCardToGet:
            [currPlayer drawCardFromTargetPlayerWithCardIds:[obj intArrayWithKey:kParamCardIdList]
                                                  cardCount:[obj intWithKey:kParamCardCount]];
            [currPlayer removeProgressBar];
            break;
            
        case kActionChoseCardToGive:
            [currPlayer giveCardToTargetPlayerWithCardIds:[obj intArrayWithKey:kParamCardIdList]
                                                cardCount:[obj intWithKey:kParamCardCount]];
            [_playingDeck clearAllExistingCards];
            break;
            
        default:
            break;
    }
}

- (BOOL)isNeedSkipSelfPlayer
{
    return (_gameLayer.currPlayer.isSelfPlayer &&
            (kActionPlayerUpdateHero    != _gameLayer.action &&
             kActionPlayerGetDeckCard   != _gameLayer.action &&
             kActionFaceDownPileCard    != _gameLayer.action &&
             kActionDeckShowTopPileCard != _gameLayer.action &&
             kActionDiscard             != _gameLayer.action));
}

///*
// * For other players(not the public sender player), if other players's target player names is empty, need set it.
// * If the specified target player is the receiver player, need add sender player as receiver player's target.
// * Otherwise, set the target player names with received esObj parameter.
// */
//- (void)setTargetPlayerNames:(NSArray *)playerNames
//{   
//    if (playerNames.count > 0 && 0 == _gameLayer.targetPlayerNames.count) {
//        for (id obj in playerNames) {
//            if ([obj isEqual:_gameLayer.selfPlayer.playerName]) {
//                [_gameLayer.targetPlayerNames addObject:_gameLayer.currPlayerName];
//                break;
//            }
//        }
//        
//        if (0 == _gameLayer.targetPlayerNames.count) {
//            _gameLayer.targetPlayerNames = [playerNames mutableCopy];
//        }
//    }
//}

@end
