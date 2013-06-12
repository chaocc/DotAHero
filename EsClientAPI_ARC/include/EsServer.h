//
//  EsServer.h
//  cocoa-touch
//
//  Created by Jason von Nieda on 7/20/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "EsMessage.h"
#import "EsConnection.h"

@interface EsServer : NSObject {
	@private
	NSMutableArray* activeConnections_;
	NSMutableArray* availableConnections_;
	NSString* serverId_;
	BOOL connected_;
	int expectedMessageNumber_;
	NSMutableDictionary* queuedMessages_;
	NSMutableDictionary* availableConnectionsByType_;
}

@property int expectedMessageNumber;
@property(readonly) NSString* serverId;
@property(readonly) BOOL connected;

- (id) initWithServerId:(NSString*) serverId;
- (void) queueMessage:(EsMessage*) message forConnection:(EsConnection*) connection;
- (void) addActiveConnection:(EsConnection*) connection;
- (void) removeActiveConnection:(EsConnection*) connection;
- (void) addAvailableConnection:(EsAvailableConnection*) availableConnection;
- (void) removeAvailableConnection:(EsAvailableConnection*) availableConnection;
- (NSArray*) availableConnectionsByTransportType:(int) transportType;
- (NSArray*) availableConnections;
- (NSArray*) activeConnections;
- (NSMutableDictionary*) queuedMessages;
@end
