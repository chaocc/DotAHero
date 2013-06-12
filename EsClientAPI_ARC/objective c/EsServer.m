//
//  EsServer.m
//  cocoa-touch
//
//  Created by Jason von Nieda on 7/20/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "EsServer.h"
#import "EsQueuedMessage.h"


@implementation EsServer

@synthesize expectedMessageNumber = expectedMessageNumber_;
@synthesize serverId = serverId_;
@synthesize connected = connected_;

- (id) initWithServerId:(NSString*) serverId {
	if (self = [super init]) {
		activeConnections_ = [[NSMutableArray alloc] init];
		availableConnections_ = [[NSMutableArray alloc] init];
		queuedMessages_ = [[NSMutableDictionary alloc] init];
		availableConnectionsByType_ = [[NSMutableDictionary alloc] init];
		serverId_ = serverId;
	}
	return self;
}

NSInteger compareQueuedMessages(EsQueuedMessage* message1, EsQueuedMessage* message2, void* context) {
	if (message1.message.messageNumber < message2.message.messageNumber) {
		return NSOrderedAscending;
	}
	if (message1.message.messageNumber > message2.message.messageNumber) {
		return NSOrderedDescending;
	}
	else {
		return NSOrderedSame;
	}
}

- (void) queueMessage:(EsMessage*) message forConnection:(EsConnection*) connection {
	EsQueuedMessage* qm = [[EsQueuedMessage alloc] initWithMessage:message connection:connection];
	[queuedMessages_ setObject:qm forKey:[NSNumber numberWithInt:qm.message.messageNumber]];
}

- (void) addActiveConnection:(EsConnection*) connection {
	[activeConnections_ addObject:connection];
	connected_ = true;
}

- (void) removeActiveConnection:(EsConnection*) connection {
	[activeConnections_ removeObject:connection];
	connected_ = [activeConnections_ count] > 0;
}

- (void) addAvailableConnection:(EsAvailableConnection*) con {
	con.serverId = serverId_;
	
	NSMutableArray* l = [availableConnectionsByType_ objectForKey:[NSNumber numberWithInt:con.transportType]];
	if (l == nil) {
		l = [[NSMutableArray alloc] init];
		[availableConnectionsByType_ setObject:l forKey:[NSNumber numberWithInt:con.transportType]];
	}
	[l addObject:con];
	[availableConnections_ addObject:con];
}

- (void) removeAvailableConnection:(EsAvailableConnection*) con {
	NSMutableArray* l = [availableConnectionsByType_ objectForKey:[NSNumber numberWithInt:con.transportType]];
	if (l != nil) {
		[l removeObject:con];
	}
	[availableConnections_ removeObject:con];
}

- (NSArray*) availableConnectionsByTransportType:(int) transportType {
	NSMutableArray* l = [availableConnectionsByType_ objectForKey:[NSNumber numberWithInt:transportType]];
	if (l == nil) {
		l = [[NSMutableArray alloc] init];
		[availableConnectionsByType_ setObject:l forKey:[NSNumber numberWithInt:transportType]];
	}
	return l;
}

- (NSArray*) availableConnections {
	return availableConnections_;
}

- (NSArray*) activeConnections {
	return activeConnections_;
}

- (NSDictionary*) queuedMessages {
	return queuedMessages_;
}
@end

