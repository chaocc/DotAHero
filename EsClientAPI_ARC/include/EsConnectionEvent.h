//
//  EsConnectionEvent.h
//  cocoa-touch
//
//  Created by Jason von Nieda on 7/21/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "EsConnection.h"
#import "EsEventDispatcher.h"

enum {
	EsConnectionEvent_ConnectionFailed = 0,
	EsConnectionEvent_ConnectionClosed = 1,
	EsConnectionEvent_ConnectionEstablished = 2,
	EsConnectionEvent_DataReceived = 3,
};

@interface EsConnectionEvent : EsEventDispatcherEvent {

}

@property(strong) EsConnection* connection;
@property(strong) NSData* data;

- (id) initWithEventType:(int) eventType connection:(EsConnection*) connection;

@end

