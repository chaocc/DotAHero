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

- (void)sendCreateRoomRequest;
- (void)sendLeaveRoomRequest;

- (void)addGamePluginMessageEventListener;
- (void)sendStartGameRequest;
- (void)sendStartRoundRequest;

- (void)sendUseHandCardRequestWithIsStrengthened:(BOOL)isStrengthened;
- (void)sendUseEquipmentRequest;
- (void)sendUseHeroSkillRequest;
- (void)sendCancelRequest;
- (void)sendDiscardRequest;

- (void)sendChoseHeroIdRequest;
- (void)sendChoseCardToCutRequest;
- (void)sendChoseCardToUseRequest;
- (void)sendChoseCardToGetRequest;
- (void)sendChoseCardToGiveRequest;
- (void)sendChoseCardToDiscardRequest;
- (void)sendChoseColorRequest;
- (void)sendChoseSuitsRequest;
- (void)sendAsignCardRequest;

- (void)addPublicMessageEventListener;

@end
