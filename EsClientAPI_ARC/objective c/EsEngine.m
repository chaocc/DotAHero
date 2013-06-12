//
//  EsEngine.m
//  cocoa-touch
//
//  Created by Jason von Nieda on 7/20/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "EsEngine.h"
#import "EsMessageType.h"
#import "EsSocketConnection.h"
#import "EsTransportType.h"
#import "EsConnectionEvent.h"
#import "EsMessageTranslator.h"
#import "EsApi.h"
#import "EsQueuedMessage.h"
#import "DLOG.h"
#import <zlib.h>

@implementation EsEngine

@synthesize ignoreUnknownMessages;

- (id) init {
	if (self = [super init]) {
		servers_ = [[NSMutableArray alloc] init];
		serversById_ = [[NSMutableDictionary alloc] init];
		activeConnections_ = [[NSMutableArray alloc] init];
		connectionsToAttempt_ = [[NSMutableArray alloc] init];
		connectionsById_ = [[NSMutableDictionary alloc] init];
		secret_ = [[NSString alloc] initWithFormat:@"%d%d%d%d", rand(), rand(), rand(), rand()];
		messageSizeCompressionThreshold_ = -1;
		[self addEventListenerWithTarget:self action:@selector(onValidateAdditionalLoginRequest:) eventIdentifier:EsMessageType_ValidateAdditionalLoginRequest];
		[self addEventListenerWithTarget:self action:@selector(onLoginResponse:) eventIdentifier:EsMessageType_LoginResponse];
	}
	return self;
}

- (void) connect {
	[self connectToServer:nil];
}

- (void) connectToServer:(EsServer*) server {
	[self connectToServer:server withAvailableConnection:nil];
}

- (void) connectToServer:(EsServer*) server withAvailableConnection:(EsAvailableConnection*) availableConnection {
	connectionAttemptIndex_ = 0;
	[connectionsToAttempt_ removeAllObjects];
	
	if (availableConnection != nil) {
		[connectionsToAttempt_ addObject:availableConnection];
	}
	else if (server != nil) {
		[connectionsToAttempt_ addObjectsFromArray:[server availableConnections]];
	}
	else {
		for (EsServer* s in servers_) {
			[connectionsToAttempt_ addObjectsFromArray:[s availableConnections]];
		}
	}
	
	if (!connected_) {
		[self pruneConnectionsToAttempt];
	}
	
	[self attemptNextConnection];
}

- (void) setEncryptionEnabled:(BOOL) encryptionEnabled {
	for (EsConnection* con in activeConnections_) {
		[self setEncryptionEnabled:encryptionEnabled connection:con];
	}
}

- (void) setEncryptionEnabled:(BOOL) encryptionEnabled connection:(EsConnection*) connection {
	if (encryptionEnabled) {
		if (connection.encryptionContext == nil) {
			connection.encryptionContext = [[EsDhAesEncryptionContext alloc] init];
		}
		[connection.encryptionContext setEnabled:true engine:self connection:connection];
	}
	else {
		if (connection.encryptionContext != nil) {
			[connection.encryptionContext setEnabled:false engine:self connection:connection];
		}
	}
}

- (BOOL) encryptionEnabled {
	return false;
}

- (BOOL) encryptionEnabled:(EsConnection*) connection {
	return false;
}

- (EsConnection*) connectionWithId:(int) connectionId {
	return [connectionsById_ objectForKey:[NSNumber numberWithInt:connectionId]];
}

- (void) addServer:(EsServer*) server {
	[serversById_ setObject:server forKey:[server serverId]];
	[servers_ addObject:server];
}

- (void) removeServer:(EsServer*) server {
	[serversById_ removeObjectForKey:[server serverId]];
	[servers_ removeObject:server];
}

- (void) close {
	for (EsConnection* con in activeConnections_) {
		[con close];
	}
}

- (void) sendMessage:(EsMessage*) message {
	[self sendMessage:message onConnection:nil];
}

- (void) sendMessage:(EsMessage*) message onConnection:(EsConnection*) connection {
	if (connection == nil) {
		connection = defaultConnection_;
	}
	if ([message isKindOfClass:[EsLoginRequest class]]) {
        EsLoginRequest* lr = (EsLoginRequest*) message;
        if ([((EsLoginRequest*) message) sharedSecret] != nil) {
            secret_ = [((EsLoginRequest*) message) sharedSecret];
        }
        lr.clientType = @"CocoaTouch";
        lr.clientVersion = EsUtility.version;
	}
	if (connection != nil) {
		int outboundId;
		if ([message isKindOfClass:[EsDHInitiateKeyExchangeRequest class]] || [message isKindOfClass:[EsDHSharedModulusRequest class]] 
				|| [message isKindOfClass:[EsEncryptionStateChangeEvent class]]) {
			outboundId = -1;
		}
		else {
			outboundId = [connection nextOutboundId];
		}
		
		DLOG("[Send %d %@]", message.messageNumber, [message toThrift]);
		
		NSMutableData* b = [NSMutableData dataWithData:[EsMessageTranslator dataFromEsMessage:message outboundId:outboundId]];

		uint8_t messageFlags = 0;
		
		if (messageSizeCompressionThreshold_ != -1 &&
				(messageSizeCompressionThreshold_ == 0 || (NSInteger)[b length] >= messageSizeCompressionThreshold_)) {
			DLOG(@"compressing message with length %d", [b length]);
			z_stream zStream;
		
			const int outputBufferLength = 512;
			unsigned char outputBuffer[outputBufferLength];
		
			zStream.zalloc = Z_NULL;
			zStream.zfree = Z_NULL;
			zStream.next_in = (unsigned char *) [b bytes];
			zStream.avail_in = [b length];
			zStream.next_out = outputBuffer;
			zStream.avail_out = outputBufferLength;
		
			deflateInit(&zStream, Z_DEFAULT_COMPRESSION);
		
			NSMutableData* outputData = [NSMutableData data];
		
			while (deflate(&zStream, Z_FINISH) != Z_STREAM_END) {
				[outputData appendBytes:outputBuffer length:outputBufferLength - zStream.avail_out];
				zStream.avail_out = outputBufferLength;
				zStream.next_out = outputBuffer;
			}
			[outputData appendBytes:outputBuffer length:outputBufferLength - zStream.avail_out];
			deflateEnd(&zStream);
		
			b = outputData;
			messageFlags |= 0x01;
			DLOG(@"to message with length %d", [b length]);
		}
		
		
		if (connection.encryptionContext != nil) {
			[connection.encryptionContext handleOutgoingMessage:message engine:self connection:connection];
			[connection.encryptionContext encryptOutgoingMessage:b];
		}
			 
		int length = [b length] + 1;
		length = NSSwapHostIntToBig(length);
		[b replaceBytesInRange:NSMakeRange(0, 0) withBytes:&length length:4];
		[b replaceBytesInRange:NSMakeRange(4, 0) withBytes:&messageFlags length:1];
		
		[connection send:b];
	}
}

- (EsServer*) serverWithId:(NSString*) serverId {
	return [serversById_ objectForKey:serverId];
}

- (void) setServers:(NSMutableArray*) servers {
	servers_ = servers;
	[serversById_ removeAllObjects];
	for (EsServer* server in servers_) {
		[serversById_ setObject:server forKey:server.serverId];
	}
}

- (NSArray*) servers {
	return servers_;
}

- (BOOL) connected {
	return connected_;
}

- (NSArray*) connectionsToAttempt {
	return connectionsToAttempt_;
}

- (int) connectionAttemptIndex {
	return connectionAttemptIndex_;
}

- (NSArray*) activeConnections {
	return activeConnections_;
}

// private
- (void) attemptNextConnection {
	EsConnection* con = [self newConnection:[connectionsToAttempt_ objectAtIndex:connectionAttemptIndex_]];
	
	DLOG(@"[Attempting %d connection. Host: %@, Port: %d]", [con transportType], [con host], [con port]);
	
	[connectionsById_ setObject:con forKey:[NSNumber numberWithInt:[con connectionId]]];
	
	[con addEventListenerWithTarget:self action:@selector(onDataReceived:) eventIdentifier:EsConnectionEvent_DataReceived];
	[con addEventListenerWithTarget:self action:@selector(onConnectionEstablished:) eventIdentifier:EsConnectionEvent_ConnectionEstablished];
	[con addEventListenerWithTarget:self action:@selector(onConnectionClosed:) eventIdentifier:EsConnectionEvent_ConnectionClosed];
	[con addEventListenerWithTarget:self action:@selector(onConnectionFailed:) eventIdentifier:EsConnectionEvent_ConnectionFailed];
	
	connectionAttemptIndex_++;
	
	[con connect];
}

- (void) pruneConnectionsToAttempt {
	NSMutableArray* t = [connectionsToAttempt_ copy];
	for (EsAvailableConnection* con in t) {
		if (con.transportType != EsTransportType_BinaryTCP && con.transportType != EsTransportType_BinaryHTTP) {
			[connectionsToAttempt_ removeObject:con];
		}
	}
}

- (void) onDataReceived:(EsConnectionEvent*) event {
	NSMutableData* b = [NSMutableData dataWithData:[event data]];
	
	// get the message flags and resize the data to omit them
	uint8_t messageFlags;
	[b getBytes:&messageFlags length:1];
	[b replaceBytesInRange:NSMakeRange(0, 1) withBytes:NULL length:0];
	
	if (event.connection.encryptionContext != nil) {
		[event.connection.encryptionContext decryptIncomingMessage:b];
	}
	
	if ((messageFlags & 0x01) != 0) {
		DLOG(@"decompressing message with length %d", [b length]);
		z_stream zStream;
		
		const int outputBufferLength = 512;
		unsigned char outputBuffer[outputBufferLength];
		
		zStream.zalloc = Z_NULL;
		zStream.zfree = Z_NULL;
		zStream.next_in = (unsigned char *) [b bytes];
		zStream.avail_in = [b length];
		zStream.next_out = outputBuffer;
		zStream.avail_out = outputBufferLength;
		
		inflateInit(&zStream);
		
		NSMutableData* outputData = [NSMutableData data];
		
		while (inflate(&zStream, Z_SYNC_FLUSH) != Z_STREAM_END) {
			[outputData appendBytes:outputBuffer length:outputBufferLength - zStream.avail_out];
			zStream.avail_out = outputBufferLength;
			zStream.next_out = outputBuffer;
		}
		[outputData appendBytes:outputBuffer length:outputBufferLength - zStream.avail_out];
		inflateEnd(&zStream);
		
		b = outputData;
		DLOG(@"to message with length %d", [b length]);
	}
	
	NSInputStream* stream = [NSInputStream inputStreamWithData:b];
	[stream open];
	EsMessage* message = [EsMessageTranslator esMessageFromInputStream:stream];
	[stream close];
	[self checkMessageOrder:message connection:event.connection];
}

- (void) onConnectionEstablished:(EsConnectionEvent*) event {
	DLOG(@"[Connection established. Type: %d]", event.connection.transportType);

	[activeConnections_ addObject:event.connection];
	
	[[serversById_ objectForKey:event.connection.serverId] addActiveConnection:event.connection];
	
	if (defaultConnection_ == nil) {
		defaultConnection_ = event.connection;
	}
	
	connected_ = true;
	
	EsConnectionAttemptResponse* ca = [[EsConnectionAttemptResponse alloc] init];
	ca.successful = true;
	ca.connectionId = event.connection.connectionId;
	[self dispatchEvent:ca];
}

- (void) onConnectionClosed:(EsConnectionEvent*) event {
	[self cleanConnectionListeners:event.connection];
	[[serversById_ objectForKey:event.connection.serverId] removeActiveConnection:event.connection];
	[activeConnections_ removeObject:event.connection];
	if (event.connection == defaultConnection_) {
		connected_ = false;
		defaultConnection_ = nil;
		for (EsConnection* con in activeConnections_) {
			if (con.primaryCapable) {
				defaultConnection_ = con;
				connected_ = true;
				break;
			}
		}
	}
	if (!connected_) {
		[self close];
	}
	
	EsConnectionClosedEvent* cce = [[EsConnectionClosedEvent alloc] init];
	cce.connectionId = event.connection.connectionId;
	[self dispatchEvent:cce];
}

- (void) onConnectionFailed:(EsConnectionEvent*) event {
	[self cleanConnectionListeners:event.connection];
	
	DLOG(@"[Connection attempt failed. Type: %d]", event.connection.transportType);
	
	EsConnectionAttemptResponse* ca = [[EsConnectionAttemptResponse alloc] init];
	ca.successful = false;
	ca.connectionId = event.connection.connectionId;
	ca.error = EsErrorType_ConnectionFailed;
	[self dispatchEvent:ca];
	
	if (connectionAttemptIndex_ < [connectionsToAttempt_ count]) {
		[self attemptNextConnection];
	}
	else {
		DLOG(@"[Connection failed.]");
		EsConnectionResponse* crm = [[EsConnectionResponse alloc] init];
		crm.successful = false;
		crm.error = EsErrorType_ConnectionFailed;
		[self dispatchEvent:crm];
	}
}

- (void) onLoginResponse:(EsLoginResponse*) event {
	username_ = event.userName;
}

- (void) onValidateAdditionalLoginRequest:(EsValidateAdditionalLoginRequest*) event {
	EsValidateAdditionalLoginResponse* response = [[EsValidateAdditionalLoginResponse alloc] init];
	response.approved = [event.secret isEqualToString:secret_];
	response.secret = secret_;
	[self sendMessage:response];
}

- (EsConnection*) newConnection:(EsAvailableConnection*) availableConnection {
	EsConnection* con = nil;
	switch (availableConnection.transportType) {
		case EsTransportType_BinaryTCP:
			con = [[EsSocketConnection alloc] initWithAvailableConnection:availableConnection];
			break;
		// TODO other connection types
	}
	
	[con setConnectionId:connectionIds_++];
	
	return con;
}

- (void) cleanConnectionListeners:(EsConnection*) con {
	[con removeEventListenerWithTarget:self action:@selector(onDataReceived:) eventIdentifier:EsConnectionEvent_DataReceived];
	[con removeEventListenerWithTarget:self action:@selector(onConnectionEstablished:) eventIdentifier:EsConnectionEvent_ConnectionEstablished];
	[con removeEventListenerWithTarget:self action:@selector(onConnectionClosed:) eventIdentifier:EsConnectionEvent_ConnectionClosed];
	[con removeEventListenerWithTarget:self action:@selector(onConnectionFailed:) eventIdentifier:EsConnectionEvent_ConnectionFailed];
}

- (void) checkMessageOrder:(EsMessage*) message connection:(EsConnection*) connection {
	EsServer* server = [serversById_ objectForKey:connection.serverId];
	assert(server != nil);

	if ([message isKindOfClass:[EsLoginResponse class]] && !((EsLoginResponse*) message).successful) {
		server.expectedMessageNumber = 0;
	}
	
	// It seems that messages sent by the gateway always have -1 for their message number. I take this to
	// mean they should be processed out of order, so that's what the check below does. Additionally,
	// the code in processMessage ignores the incoming message number increment for -1 message numbers.
	if (message.messageNumber == -1 || message.messageNumber <= server.expectedMessageNumber) {
		DLOG(@"[Recv %d %d %@]", message.messageNumber, server.expectedMessageNumber, [message toThrift]);
		[self processMessage:message connection:connection];
		DLOG(@"Queued messages %d", [[server queuedMessages] count]);
		
        while ([[server queuedMessages] objectForKey:[NSNumber numberWithInt:server.expectedMessageNumber]] != nil) {
			EsQueuedMessage* qm = [[server queuedMessages] objectForKey:[NSNumber numberWithInt:server.expectedMessageNumber]];
            [[server queuedMessages] removeObjectForKey:[NSNumber numberWithInt:server.expectedMessageNumber]];
			EsConnection* con = qm.connection;
			
			DLOG(@"[Dequeue %d %d %@]", message.messageNumber, server.expectedMessageNumber, [message toThrift]);
			[self processMessage:message connection:con];
		}
	}
	else {
		DLOG(@"[Queue %d %d %@]", message.messageNumber, server.expectedMessageNumber, [message toThrift]);
		[server queueMessage:message forConnection:connection];
	}
}

- (void) processMessage:(EsMessage*) message connection:(EsConnection*) connection {
	EsServer* server = [serversById_ objectForKey:connection.serverId];
	assert(server != nil);
	
	[self preProcessMessage:message connection:connection server:server];
	
	if (message.messageNumber != -1) {
		server.expectedMessageNumber = server.expectedMessageNumber + 1;
		if (server.expectedMessageNumber > 9999) {
			server.expectedMessageNumber = 0;
		}
	}
    
    if (EsMessageType_Unknown == message.messageType) {
        if (![self ignoreUnknownMessages]) {
            DLOG(@"Unknown message received: %i", message.messageType);
            [self close];
        }
        else {
            // Just ignore it
        }
    }
    else {
        [self dispatchEvent:message];
    }
}

- (void) preProcessMessage:(EsMessage*) message connection:(EsConnection*) connection server:(EsServer*) server {
	if ([message isKindOfClass:[EsGenericErrorResponse class]]) {
		DLOG(@"[Error: %d]", ((EsGenericErrorResponse*) message).errorType);
	}
	
	if ([message isKindOfClass:[EsConnectionResponse class]]) {
		messageSizeCompressionThreshold_ = ((EsConnectionResponse*) message).protocolConfiguration.messageCompressionThreshold;
	}
	
	if (connection.encryptionContext != nil) {
		[connection.encryptionContext handleIncomingMessage:message engine:self connection:connection];
	}
    
    if ([message isKindOfClass:[EsLoginResponse class]] && !((EsLoginResponse*) message).successful) {
        [connection decrementOutboundId];
    }
    
    if ([message isKindOfClass:[EsAggregatePluginMessageEvent class]]) {
        EsAggregatePluginMessageEvent *aggregateEvent = (EsAggregatePluginMessageEvent *) message;
        for (NSUInteger i = 0; i < [aggregateEvent.esObjects count]; i++) {
            EsPluginMessageEvent *pluginEvent = [[EsPluginMessageEvent alloc] init];
            pluginEvent.roomLevelPlugin = (aggregateEvent.originRoomId >= 0);
            pluginEvent.pluginName = aggregateEvent.pluginName;
            pluginEvent.originRoomId = aggregateEvent.originRoomId;
            pluginEvent.originZoneId = aggregateEvent.originZoneId;
            pluginEvent.parameters = [aggregateEvent.esObjects objectAtIndex:i];
            
            [self processMessage:pluginEvent connection:connection];
            
            // The processMessage call will increment the expectedMessageNumber,
            // but it shouldn't because these messages all came in on one actual
            // server message. 
            server.expectedMessageNumber--;
        }
    }
}

- (void) dealloc {
	DLOG(@"dealloc");
}

@end

