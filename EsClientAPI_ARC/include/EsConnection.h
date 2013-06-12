//
//  EsConnection.h
//  cocoa-touch
//
//  Created by Jason von Nieda on 7/20/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "EsAvailableConnection.h"
#import "EsEventDispatcher.h"
#import "EsDhAesEncryptionContext.h"

@interface EsConnection : EsEventDispatcher {
	
}

@property int transportType;
@property(strong) NSString* host;
@property int port;
@property(strong) NSString* serverId;
@property int outboundId; // = -1
@property BOOL connected;
@property int connectionId;
@property BOOL primaryCapable;
@property(strong) EsDhAesEncryptionContext* encryptionContext;

- (id) initWithAvailableConnection: (EsAvailableConnection*) availableConnection;
- (void) connect;
- (int) nextOutboundId;
- (void) close;
- (void) send: (NSData*) data;
- (void) decrementOutboundId;	

@end
