//
//  EsSocketConnection.m
//  cocoa-touch
//
//  Created by Jason von Nieda on 7/20/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "EsSocketConnection.h"
#import "EsObject.h"
#import "EsMessageTranslator.h"
#import "EsConnectionEvent.h"
#import "DLOG.h"

@implementation EsSocketConnection

- (id) initWithAvailableConnection: (EsAvailableConnection*) availableConnection {
	if ((self = [super initWithAvailableConnection: availableConnection])) {
		self.primaryCapable = true;
		handledPolicyFile_ = false;
		incomingMessage_ = [[NSMutableData alloc] init];
	}
	return self;
}

- (void) connect {
	if (inputStream_ != nil) {
		[self close];
	}
	CFReadStreamRef inputStreamRef;
	CFWriteStreamRef outputStreamRef;
	CFStreamCreatePairWithSocketToHost(NULL, (__bridge CFStringRef) self.host, self.port, &inputStreamRef, &outputStreamRef);
	
	outputStream_ = (__bridge NSOutputStream*) outputStreamRef;
	inputStream_ = (__bridge NSInputStream*) inputStreamRef;
	
	[outputStream_ setDelegate:self];
	[inputStream_ setDelegate:self];
	
	[outputStream_ scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
	[inputStream_ scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];

	[outputStream_ open];
}

- (void) close {
	[inputStream_ close];
	[outputStream_ close];
	self.connected = false;
	[self dispatchEvent:[[EsConnectionEvent alloc] initWithEventType:EsConnectionEvent_ConnectionClosed connection:self]];
}

- (void) send: (NSData*) data {
    [outputStream_ write:[data bytes] maxLength:[data length]];
}

- (void) stream: (NSStream*) stream handleEvent: (NSStreamEvent) eventCode {
    //DLOG(@"stream handleEvent %d", eventCode);
	switch (eventCode) {
        case NSStreamEventHasSpaceAvailable: {
            //DLOG(@"NSStreamEventHasSpaceAvailable");
            if (stream == outputStream_ && [inputStream_ streamStatus] == NSStreamStatusNotOpen) {
                //DLOG(@"Output stream ready, opening input stream");
                [inputStream_ open];
            }
            break;
        }
		case NSStreamEventOpenCompleted: {
            //DLOG(@"NSStreamEventOpenCompleted");
			break;
		}
		case NSStreamEventErrorOccurred: {
            //DLOG(@"NSStreamEventErrorOccurred");
			if (self.connected) {
				[self close];
			}
			else if (!failed_) {
				failed_ = true;
				[self dispatchEvent:[[EsConnectionEvent alloc] initWithEventType:EsConnectionEvent_ConnectionFailed connection:self]];
			}
			break;
		}
		case NSStreamEventEndEncountered: {
            //DLOG(@"NSStreamEventEndEncountered");
			[self close];
			break;
		}
		case NSStreamEventHasBytesAvailable: {
			//DLOG(@"NSStreamEventHasBytesAvailable");
			uint8_t buffer[1024];
			int bytesRead = [inputStream_ read:buffer maxLength:sizeof(buffer)];
			if (bytesRead > 0) {
                //DLOG(@"Read %d bytes", bytesRead);
				[self handleIncomingBytes:(uint8_t*) buffer length:bytesRead];
			}
			break;
		}
        default:
            break;
	}
}

- (void) handleIncomingBytes: (uint8_t*) bytes length: (int) length {
	int offset = 0;
	if (!handledPolicyFile_) {
		// We have not yet found the end of the cross domain policy file, so
		// keep reading till we find a 0.
		for (; offset < length; offset++) {
			if (bytes[offset] == 0) {
				handledPolicyFile_ = true;
				self.connected = true;
				[self dispatchEvent:[[EsConnectionEvent alloc] initWithEventType:EsConnectionEvent_ConnectionEstablished connection:self]];
				offset++;
				break;
			}
		}
	}
	if (offset < length) {
		[incomingMessage_ appendBytes:(bytes + offset) length:(length - offset)];
		// The general format for a message is:
		// int32 messageLength
		// int16 messageType
		// int32 messageNumber
		// int8* thriftData
		while ([incomingMessage_ length] >= 4) {
			// If we have read at least 4 bytes we can determine the length of
			// the incoming message
			NSInputStream* messageStream = [NSInputStream inputStreamWithData:incomingMessage_];
			[messageStream open];
			NSUInteger messageLength = [EsObject readIntFromStream:messageStream];
			[messageStream close];
			if ([incomingMessage_ length] >= messageLength + 4) {
				// we're going to send a data received event
				EsConnectionEvent* event = [[EsConnectionEvent alloc] initWithEventType:EsConnectionEvent_DataReceived connection:self];
				// package up the data that makes up the received message into an NSData
				NSMutableData* messageData = [[NSMutableData alloc] init];
				[messageData appendBytes:([incomingMessage_ bytes] + 4) length:messageLength];
				event.data = messageData;
				// erase the data we just read from the remaining buffer
				[incomingMessage_ replaceBytesInRange:NSMakeRange(0, messageLength + 4) withBytes:NULL length:0];
				// dispatch the message
				[self dispatchEvent:event];
			}
            else {
                break;
            }
		}
	}
}

@end
