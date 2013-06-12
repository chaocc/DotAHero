//
//  EsQueuedMessage.m
//  cocoa-touch
//
//  Created by Jason von Nieda on 7/20/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "EsQueuedMessage.h"


@implementation EsQueuedMessage

@synthesize message;
@synthesize connection;

- initWithMessage:(EsMessage*) _message connection:(EsConnection*) _connection {
	if (self = [super init]) {
		self.message = _message;
		self.connection = _connection;
	}
	return self;
}


@end
