//
//  BGClient.h
//  DotAHero
//
//  Created by Killua Liu on 7/11/13.
//
//  This class will handle all interactions including request/response/event between client and elctroserver.

#import <Foundation/Foundation.h>
#import "ElectroServer.h"

@interface BGClient : NSObject

@property (strong, nonatomic, readonly) ElectroServer *es;
@property (nonatomic, strong, readonly) EsRoom *room;
@property (nonatomic, strong) NSArray *users;     // [0] is current user

+ (BGClient *)sharedClient;

- (void)conntectServer;
- (void)joinRoom;
- (void)sendReadyStartGameRequest;

- (void)addGamePluginMessageEventListener;
- (void)sendStartGameRequest;
- (void)sendChooseHeroIdRequest;
- (void)sendUseHandCardRequestWithIsStrengthened:(BOOL)isStrengthened;
- (void)sendUseHeroSkillRequest;
- (void)sendCancelRequest;
- (void)sendDiscardRequest;
- (void)sendChooseCardIdRequest;
- (void)sendChooseColorRequest;
- (void)sendChooseSuitsRequest;

//- (void)sendCutPlayingCardRequest;
//- (void)sendUsePlayingCardRequest;
//- (void)sendPlayMultipleEvasionsRequest;
//- (void)sendGuessCardColorRequest;
//- (void)sendDiscardPlayingCardRequest;
//- (void)sendCancelPlayingCardRequest;
//- (void)sendExtractCardRequest;
//- (void)sendThrowCardRequest;
//- (void)sendStartDiscardRequest;
//- (void)sendOkToDiscardRequest;
//- (void)sendUseHeroSkillRequest;

- (void)addPublicMessageEventListener;

@end
