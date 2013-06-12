//
//  EsConnectionEvent.m
//  cocoa-touch
//
//  Created by Jason von Nieda on 7/21/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "EsConnectionEvent.h"


@implementation EsConnectionEvent

@synthesize connection;
@synthesize data;

- (id) initWithEventType:(int) eventType connection:(EsConnection*) con {
	if (self = [super init]) {
		self.eventType = eventType;
		self.connection = con;
	}
	return self;
}

@end
