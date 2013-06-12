//
//  EsSocketConnection.h
//  cocoa-touch
//
//  Created by Jason von Nieda on 7/20/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "EsConnection.h"

@interface EsSocketConnection : EsConnection <NSStreamDelegate> {
	@private
	BOOL handledPolicyFile_;
	BOOL failed_;
	NSInputStream* inputStream_;
	NSOutputStream* outputStream_;
	NSMutableData* incomingMessage_;
}

- (void) handleIncomingBytes: (uint8_t*) bytes length: (int) length;

@end
