//
//  EsConnection.m
//  cocoa-touch
//
//  Created by Jason von Nieda on 7/20/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "EsConnection.h"


@implementation EsConnection

@synthesize transportType;
@synthesize host;
@synthesize port;
@synthesize serverId;
@synthesize outboundId; // = -1
@synthesize connected;
@synthesize connectionId;
@synthesize primaryCapable;
@synthesize encryptionContext;


- (id) initWithAvailableConnection: (EsAvailableConnection*) availableConnection {
	if (self = [super init]) {
		if (availableConnection != nil) {
			host = availableConnection.host;
			port = availableConnection.port;
			transportType = availableConnection.transportType;
			serverId = availableConnection.serverId;
		}
		outboundId = -1;
	}
	return self;
}

- (id) init {
	return [self initWithAvailableConnection:nil];
}

- (int) nextOutboundId {
	++outboundId;
	if (outboundId == 10000) {
		outboundId = 0;
	}
	return outboundId;
}

- (void) decrementOutboundId {
    --outboundId;
}


- (void) connect {
}

- (void) close {
}

- (void) send: (NSData*) data {
}


@end
