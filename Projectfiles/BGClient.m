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
    EsObject *obj = [[EsObject alloc] init];
    [obj setInt:kActionStartGame forKey:kAction];
    [self sendPublicMessageRequestWithObject:obj];
    NSLog(@"Send public message");
    
    [self sendGamePluginRequestWithObject:obj];
    NSLog(@"Send game plugin request with action-startGame(%i)", kActionStartGame);
}

/*
 * Send game plugin request with action-selectHeroCard and heroId. Called in player class.
 */
- (void)sendSelectHeroCardRequest
{
    EsObject *obj = [[EsObject alloc] init];
    [obj setInt:kActionSelectHeroCard forKey:kAction];
    [obj setInt:_player.selectedHeroId forKey:kParamHeroId];
    [self sendGamePluginRequestWithObject:obj];
    
    NSLog(@"Send game plugin request with action-selectHeroCard(%i)", kActionSelectHeroCard);
    NSLog(@"param-selectedHeroId: %i", _player.selectedHeroId);
}

/*
 * Send game plugin request with action-cutCard and usedPlayingCardIds. Called in playing menu.
 */
- (void)sendCutPlayingCardRequest
{
    EsObject *obj = [[EsObject alloc] init];
    [obj setInt:kActionCutCard forKey:kAction];
    [obj setIntArray:_player.selectedCardIds forKey:kParamUsedPlayingCardIds];
    [self sendGamePluginRequestWithObject:obj];
    
    NSLog(@"Send game plugin request with action-cutCard(%i)", kActionCutCard);
    NSLog(@"param-usedPlayingCardIds: %@", _player.selectedCardIds);
}

/*
 * 1. Send game plugin request with action-drawPlayingCard. Called in playing menu.
 * 2. Send public message
 */
- (void)sendDrawPlayingCardRequest
{
    EsObject *obj = [[EsObject alloc] init];
    [obj setInt:kActionDrawPlayingCard forKey:kAction];
    [self sendGamePluginRequestWithObject:obj];
    NSLog(@"Send game plugin request with action-drawPlayingCard(%i)", kActionDrawPlayingCard);
    
    [obj setInt:_player.canDrawCardCount forKey:kParamGotCardCount];
    [self sendPublicMessageRequestWithObject:obj];
    NSLog(@"Send pubic message");
    NSLog(@"param-gotCardCount: %i", _player.canDrawCardCount);
}

/*
 * 1. Send game plugin request with action-okToUseCard, usedPlayingCardIds and targetPlayerNames. Called in playing menu.
 * 2. Send public message
 */
- (void)sendUsePlayingCardRequest
{
    NSLog(@"Send game plugin request with action-okToUseCard(%i)", kActionOkToUseCard);
    EsObject *obj = [[EsObject alloc] init];
    [obj setInt:kActionOkToUseCard forKey:kAction];
    [obj setIntArray:_player.selectedCardIds forKey:kParamUsedPlayingCardIds];
    NSLog(@"param-usedPlayingCardIds: %@", _player.selectedCardIds);
    
    BGPlayingCard *card = [BGPlayingCard cardWithCardId:[_player.selectedCardIds.lastObject integerValue]];
    if (card.canBeStrengthed) {
        [obj setBool:_player.isSelectedStrenthen forKey:kParamIsStrengthened];
        NSLog(@"param-isStrengthened: %i", _player.isSelectedStrenthen);
    }
    
    if (card.cardEnum == kPlayingCardElunesArrow) {
        if (_player.isSelectedStrenthen) {
            [obj setInt:_player.selectedSuits forKey:kParamTargetCardSuits];
            NSLog(@"param-targetCardSuits: %i", _player.selectedSuits);
        } else {
            [obj setInt:_player.selectedColor forKey:kParamTargetCardColor];
            NSLog(@"param-targetCardColor: %i", _player.selectedColor);
        }
    }

    [obj setStringArray:_gameLayer.targetPlayerNames forKey:kParamTargetPlayerNames];
    [self sendGamePluginRequestWithObject:obj];
    NSLog(@"param-targetPlayerNames: %@", _gameLayer.targetPlayerNames);
    
    [self sendPublicMessageRequestWithObject:obj];
    NSLog(@"Send public message");
}

/*
 * 1. Send game plugin request with action-playMultipleEvasions, usedPlayingCardIds and targetPlayerNames. Called in playing menu.
 * 2. Send public message
 */
- (void)sendPlayMultipleEvasionsRequest
{
    NSLog(@"Send game plugin request with action-playMultipleEvasions(%i)", kActionPlayMultipleEvasions);
    EsObject *obj = [[EsObject alloc] init];
    [obj setInt:kActionPlayMultipleEvasions forKey:kAction];
    [obj setIntArray:_player.selectedCardIds forKey:kParamUsedPlayingCardIds];
    NSLog(@"param-usedPlayingCardIds: %@", _player.selectedCardIds);
    [self sendGamePluginRequestWithObject:obj];
    
    [self sendPublicMessageRequestWithObject:obj];
    NSLog(@"Send public message");
}

/*
 * 1. Send game plugin request with action-guessCardColor and targetCardColor. Called in playing menu.
 * 2. Send public message
 */
- (void)sendGuessCardColorRequest
{
    EsObject *obj = [[EsObject alloc] init];
    [obj setInt:kActionGuessCardColor forKey:kAction];
    [obj setInt:_player.selectedColor forKey:kParamTargetCardColor];
    [self sendGamePluginRequestWithObject:obj];
    NSLog(@"Send game plugin request with action-guessCardColor(%i)", kActionGuessCardColor);
    NSLog(@"param-targetCardColor: %i", _player.selectedColor);
    
    [self sendPublicMessageRequestWithObject:obj];
    NSLog(@"Send public message");
}

/*
 * 1. Send game plugin request with action-discardCard. Called in playing menu.
 * 2. Send public message
 */
- (void)sendDiscardPlayingCardRequest
{
    EsObject *obj = [[EsObject alloc] init];
    [obj setInt:kActionDiscardCard forKey:kAction];
    [obj setIntArray:_player.selectedCardIds forKey:kParamUsedPlayingCardIds];
    [self sendGamePluginRequestWithObject:obj];
    NSLog(@"Send game plugin request with action-discardCard(%i)", kActionDiscardCard);
    NSLog(@"param-usedPlayingCardIds: %@", _player.selectedCardIds);
    
    [self sendPublicMessageRequestWithObject:obj];
    NSLog(@"Send public message");
}

/*
 * 1. Send game plugin request with action-cancelCard. Called in playing menu.
 * 2. Send public message
 */
- (void)sendCancelPlayingCardRequest
{    
    EsObject *obj = [[EsObject alloc] init];
    [obj setInt:kActionCancelCard forKey:kAction];
    [self sendGamePluginRequestWithObject:obj];
    NSLog(@"Send game plugin request with action-cancelCard(%i)", kActionCancelCard);
    
    [self sendPublicMessageRequestWithObject:obj];
    NSLog(@"Send public message");
}

/*
 * 1. Send game plugin request with action-continuePlaying. Called in playing menu.
 * 2. Send public message
 */
- (void)sendContinuePlayingRequest
{    
    EsObject *obj = [[EsObject alloc] init];
    [obj setInt:kActionContinuePlaying forKey:kAction];
    [self sendGamePluginRequestWithObject:obj];
    NSLog(@"Send game plugin request with action-continuePlaying(%i)", kActionContinuePlaying);
    
    [self sendPublicMessageRequestWithObject:obj];
    NSLog(@"Send public message");
}

/*
 * Send game plugin request with action-extractCard. Called in playing deck.
 */
- (void)sendExtractCardRequest
{    
    EsObject *obj = [[EsObject alloc] init];
    [obj setInt:kActionExtractCard forKey:kAction];
    [obj setInt:_player.selectedGreedType forKey:kParamGreedType];
    [obj setIntArray:_player.extractedCardIdxes forKey:kParamExtractedCardIdxes];   // 抽取的哪几张牌
    [obj setIntArray:_player.extractedCardIds forKey:kParamExtractedCardIds];       // 抽取的装备
    [obj setIntArray:_player.transferedCardIds forKey:kParamTransferedCardIds];     // 交给目标玩家的手牌
    
//  ...TEMP...
    NSArray *cardIds = [BGHandArea playingCardIdsWithCards:_player.handArea.handCards];
    [obj setIntArray:cardIds forKey:kParamHandCardIds];
    
    [self sendGamePluginRequestWithObject:obj];
    NSLog(@"Send game plugin request with action-extractCard(%i)", kActionExtractCard);
    NSLog(@"param-greedType: %i", _player.selectedGreedType);
    NSLog(@"param-extractedCardIdxes: %@", _player.extractedCardIdxes);
    NSLog(@"param-extractedCardIds: %@", _player.extractedCardIds);
    NSLog(@"param-transferedCardIds: %@", _player.transferedCardIds);
    NSLog(@"param-handCardIds: %@", cardIds);
}

/*
 * Receive game plugin message event. Handle different returning actions.
 */
- (void)onGamePluginMessageEvent:(EsPluginMessageEvent *)e
{    
    EsObject *obj = e.parameters;
    NSArray *array = nil;
    NSInteger bloodPoint, angerPoint;
    
//  Remaining card count
    NSUInteger remainingCardCount = [obj intWithKey:kParamRemainingCardCount];
    if (remainingCardCount != 0) {
        _gameLayer.remainingCardCount = remainingCardCount;
    }
    
//  Actions
    NSInteger action = [obj intWithKey:kAction];
    if (action != kActionInvalid) {
        NSLog(@"Receive game plugin message event with action(%i)", action);
        goto actionLabel;
    }
    
actionLabel:
    switch (action) {
        case kActionDealHeroCard:
            array = [obj intArrayWithKey:kParamToBeSelectedHeroIds];
            NSLog(@"Param-toBeSelectedHeroIds: %@", array);
            [_gameLayer dealHeroCardsWithHeroIds:array];
            break;
            
        case kActionSendAllHeroIds:
            array = [obj stringArrayWithKey:kParamAllHeroIds];
            NSLog(@"Param-allHeroIds: %@", array);
            [_gameLayer sendAllSelectedHeroCardsWithHeroIds:array];
            break;
            
        case kActionDealPlayingCard:
            array = [obj stringArrayWithKey:kParamGotPlayingCardIds];
            NSLog(@"Param-gotPlayingCardIds: %@", array);
            [_gameLayer dealPlayingCardsWithCardIds:array];
            break;
        
        case kActionCutCard:
            [_player clearBuffer];
            array = [obj stringArrayWithKey:kParamAllCuttingCardIds];
            NSLog(@"Param-allCuttingCardIds: %@", array);
            [_gameLayer showAllCuttingCardsWithCardIds:array];
            break;
            
        case kActionSendPlayingCard:
        case kActionGotGuessedCard:
            array = [obj stringArrayWithKey:kParamGotPlayingCardIds];
            NSLog(@"Param-gotPlayingCardIds: %@", array);
            [_player drawPlayingCardIds:array];
            if (action == kActionGotGuessedCard) {
                [self sendGotGuessedCardPublicMessage];
            }
            break;
            
        case kActionGotExtractedCard:
            array = [obj stringArrayWithKey:kParamGotPlayingCardIds];
            [_player gotExtractedCardsWithCardIds:array];
            NSLog(@"Param-gotPlayingCardIds: %@", array);
            [self sendGotFacedDownCardPublicMessage];
            break;
            
        default:
            break;
    }
    
//  Player state
    NSInteger playerState = [obj intWithKey:kPlayerState];
    if (playerState != kPlayerStateInvalid) {
        NSLog(@"Receive game plugin message event with playerState(%i)", playerState);
        goto playerStateLabel;
    }
    
playerStateLabel:
    _player.playerState = playerState;
    switch (playerState) {
        case kPlayerStateTurnStarting:
            [self sendStartTurnPublicMessage];
            break;
            
        case kPlayerStateDrawing:
            [self sendDrawPlayingCardRequest];
            break;
            
        case kPlayerStatePlaying:
//            [_player clearBuffer];  // Clean buffer befere playing
            [_player addPlayingMenuOfCardUsing];
            [self sendStartPlayPublicMessage];
//            _player.misGuessedCardIds = [obj intArrayWithKey:kParamMisGuessedCardIds];
//            [self sendMisGuessedCardPublicMessage];
            break;
            
        case kPlayerStateIsBeingAttacked:
        case kPlayerStateIsBeingLagunaBladed:
            [_player addPlayingMenuOfCardPlaying];
            break;
            
        case kPlayerStateWasAttacked:
        case kPlayerStateWasDamaged:
            bloodPoint = [obj intWithKey:kParamBloodPointChanged];
            angerPoint = [obj intWithKey:kParamAngerPointChanged];
            NSLog(@"Param-bloodPointChanged: %i", bloodPoint);
            NSLog(@"Param-angerPointChanged: %i", angerPoint);
            [_player updateBloodAndAngerWithBloodPoint:bloodPoint andAngerPoint:angerPoint];
            break;
            
        case kPlayerStateAttacked:
            bloodPoint = [obj intWithKey:kParamBloodPointChanged];
            angerPoint = [obj intWithKey:kParamAngerPointChanged];
            NSLog(@"Param-bloodPointChanged: %i", bloodPoint);
            NSLog(@"Param-angerPointChanged: %i", angerPoint);
            [_player updateBloodAndAngerWithBloodPoint:bloodPoint andAngerPoint:angerPoint];
            [self sendContinuePlayingRequest];
            break;
            
        case kPlayerStateBloodRestored:
            bloodPoint = [obj intWithKey:kParamBloodPointChanged];
            NSLog(@"Param-bloodPointChanged: %i", bloodPoint);
            break;
            
        case kPlayerStateThrowingCard:
            [_player addPlayingMenuOfCardPlaying];
            break;
            
        case kPlayerStateGuessingCardColor:
            [_player addPlayingMenuOfCardColor];
            break;
            
        case kPlayerStateGreeding:
            _player.canExtractCardCount = 2;    // Greed
            [_player faceDownAllHandCardsOnDeck];
            break;
            
        case kPlayerStateIsBeingGreeded:
            _player.canExtractCardCount = 1;    // Was Greeded
            [_player faceDownAllHandCardsOnDeck];
            break;
            
        case kPlayerStateWasExtracted:
            array = [obj intArrayWithKey:kParamLostPlayingCardIds];
            [_player lostCardsWithCardIds:array];
            NSLog(@"Param-lostPlayingCardIds: %@", array);
            break;
            
        case kPlayerStateAngerLost:
            angerPoint = [obj intWithKey:kParamAngerPointChanged];
            NSLog(@"Param-angerPointChanged: %i", angerPoint);
            [_player updateBloodAndAngerWithBloodPoint:0 andAngerPoint:angerPoint];
            
            array = [obj stringArrayWithKey:kParamGotPlayingCardIds];
            NSLog(@"Param-gotPlayingCardIds: %@", array);
            [_player drawPlayingCardIds:array];
            break;
            
        case kPlayerStateAngerGain:
            angerPoint = [obj intWithKey:kParamAngerPointChanged];
            NSLog(@"Param-angerPointChanged: %i", angerPoint);
            [_player updateBloodAndAngerWithBloodPoint:0 andAngerPoint:angerPoint];
            [self sendContinuePlayingRequest];
            break;
            
        case kPlayerStateAngerUsed:
            angerPoint = [obj intWithKey:kParamAngerPointChanged];
            NSLog(@"Param-angerPointChanged: %i", angerPoint);
            [_player updateBloodAndAngerWithBloodPoint:0 andAngerPoint:angerPoint];
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
 * Send public message with action-startTurn and sourcePlayerName
 */
- (void)sendStartTurnPublicMessage
{
    EsObject *obj = [[EsObject alloc] init];
    [obj setInt:kActionStartTurn forKey:kAction];
    [obj setString:_player.playerName forKey:kParamSourcePlayerName];
    [self sendPublicMessageRequestWithObject:obj];
    
    NSLog(@"Send public message with action-startTurn(%i)", kActionStartGame);
    NSLog(@"param-sourcePlayerName: %@", _player.playerName);
}

/*
 * Send public message with action-startPlay
 */
- (void)sendStartPlayPublicMessage
{
    EsObject *obj = [[EsObject alloc] init];
    [obj setInt:kActionStartPlay forKey:kAction];
    [self sendPublicMessageRequestWithObject:obj];
    
    NSLog(@"Send public message with action-startPlay(%i)", kActionStartPlay);
}

/*
 * Send public message with action-gotGuessedCard
 */
- (void)sendGotGuessedCardPublicMessage
{
    EsObject *obj = [[EsObject alloc] init];
    [obj setInt:kActionGotGuessedCard forKey:kAction];
    [self sendPublicMessageRequestWithObject:obj];
    
    NSLog(@"Send public message with action-startGame(%i)", kActionGotGuessedCard);
}

/*
 * Send public message with action-misGuessedCard
 */
- (void)sendMisGuessedCardPublicMessage
{
    EsObject *obj = [[EsObject alloc] init];
    [obj setInt:kActionMisGuessedCard forKey:kAction];
    [obj setIntArray:_player.misGuessedCardIds forKey:kParamMisGuessedCardIds];
    [self sendPublicMessageRequestWithObject:obj];
    
    NSLog(@"Send public message with action-misGuessedCard(%i)", kActionMisGuessedCard);
    NSLog(@"param-misGuessedCardIds: %@", _player.misGuessedCardIds);
}

/*
 * Send public message with action-gotExtractedCard and gotCardCound
 */
- (void)sendGotFacedDownCardPublicMessage
{
    EsObject *obj = [[EsObject alloc] init];
    [obj setInt:kActionGotExtractedCard forKey:kAction];
    NSArray *cardIds = [obj intArrayWithKey:kParamGotPlayingCardIds];
    [obj setInt:cardIds.count forKey:kParamGotCardCount];
    [self sendPublicMessageRequestWithObject:obj];
    NSLog(@"Send public message with action-gotExtractedCard(%i)", kActionGotExtractedCard);
    NSLog(@"param-gotCardCount: %i", cardIds.count);
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
            NSLog(@"All login users: %@", self.users);
            
            _gameLayer = [BGGameLayer sharedGameLayer];
            _player = _gameLayer.selfPlayer;
            break;
            
        case kActionStartTurn:
            _gameLayer.sourcePlayerName = [obj stringWithKey:kParamSourcePlayerName];
            NSLog(@"Param-sourcePlayerName: %@",_gameLayer.sourcePlayerName);
            break;
            
        case kActionStartPlay:
            [_player clearBuffer];
            break;
            
        case kActionDrawPlayingCard:
            
            break;
            
        case kActionOkToUseCard:

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
