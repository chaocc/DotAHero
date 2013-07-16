//
//  BGClient.h
//  DotAHero
//
//  Created by Killua Liu on 7/11/13.
//
//  This class will handle all interactions including request/response/event between client and elctroserver.

#import <Foundation/Foundation.h>
#import "ElectroServer.h"

@class BGPlayingCard;

@interface BGClient : NSObject

@property (strong, nonatomic, readonly) ElectroServer *es;
@property (nonatomic, strong, readonly) EsRoom *room;
@property (nonatomic, strong) NSArray *users;     // [0] is current user

@property (nonatomic, readonly) BOOL isSingleMode;

+ (BGClient *)sharedClient;

- (void)conntectServer;
- (void)joinRoom;
- (void)sendReadyStartGameRequest;

- (void)addGamePluginMessageEventListener;
- (void)sendStartGameRequest;
- (void)sendSelectHeroCardRequestWithHeroId:(NSUInteger)heroId;
- (void)sendCutCardRequestWithPlayingCardId:(NSUInteger)cardId;
- (void)sendUseCardRequestWithPlayingCardId:(NSUInteger)cardId;

- (void)addPublicMessageEventListener;
- (void)sendStartGamePublicMessage;

@end
