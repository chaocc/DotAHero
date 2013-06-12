//
//  EsMessage.h
//  cocoa-touch
//
//  Created by Jason von Nieda on 7/10/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "EsEventDispatcher.h"


@interface EsMessage : EsEventDispatcherEvent {
	int messageType_;
}

@property (nonatomic) int messageType;
@property int requestId;
@property int messageNumber;
@property(strong) NSString* serverId;

- (void) fromThrift: (id) thriftObject;
- (id) newThrift;
- (id) toThrift;

@end
