//
//  EsMessage.m
//  cocoa-touch
//
//  Created by Jason von Nieda on 7/10/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "EsMessage.h"


@implementation EsMessage

@synthesize messageType = messageType_;
@synthesize requestId;
@synthesize messageNumber;
@synthesize serverId;

- (void) setMessageType:(int) messageType {
	messageType_ = messageType;
	self.eventType = messageType;
}

- (void) fromThrift: (id) thriftObject {
}

- (id) newThrift {
	return nil;
}

- (id) toThrift {
	return nil;
}

@end
