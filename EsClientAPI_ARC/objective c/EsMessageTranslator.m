//
//  EsMessageTranslator.m
//  cocoa-touch
//
//  Created by Jason von Nieda on 7/20/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "EsMessageTranslator.h"
#import "EsObject.h"
#import "EsUtility.h"
#import "TNSStreamTransport.h"
#import "TBinaryProtocol.h"
#import "TBase.h"


@implementation EsMessageTranslator
+ (EsMessage*) esMessageFromInputStream: (NSInputStream*) inputStream {
	short messageType = [EsObject readShortFromStream:inputStream];
	int messageNumber = [EsObject readIntFromStream:inputStream];
	// get the class that implements the API for this message type
	Class esMessageClass = (Class) [[EsUtility messageTypeToApiClass] objectForKey:[NSNumber numberWithInt:messageType]];
	EsMessage* message = [[esMessageClass alloc] init];
	// create a new instance of the Thrift class for this message
	id <TBase> thriftMessage = [message newThrift];
	// decode the Thrift payload
	TNSStreamTransport* tTransport = [[TNSStreamTransport alloc] initWithInputStream:inputStream];
	TBinaryProtocol* tProtocol = [[TBinaryProtocol alloc] initWithTransport:tTransport];
	[thriftMessage read:tProtocol];
	// read the Thrift data back into the api class
	[message fromThrift:thriftMessage];
	// set the previously read message number
	message.messageNumber = messageNumber;
	return message;
}

+ (NSData*) dataFromEsMessage:(EsMessage*) message outboundId:(int) outboundId {
	[message setMessageNumber:outboundId];
	id <TBase> thriftMessage = [message toThrift];
	NSOutputStream* thriftOutput = [[NSOutputStream alloc] initToMemory];
	[thriftOutput open];
	TNSStreamTransport* thriftTransport = [[TNSStreamTransport alloc] initWithOutputStream:thriftOutput];
	TBinaryProtocol* thriftProtocol = [[TBinaryProtocol alloc] initWithTransport:thriftTransport];
	[thriftMessage write:thriftProtocol];
	[thriftOutput close];
	NSData* thriftData = [thriftOutput propertyForKey:NSStreamDataWrittenToMemoryStreamKey];

	NSOutputStream* output = [[NSOutputStream alloc] initToMemory];
	[output open];
	short messageTypeIndicator = (short) [[[EsUtility messageTypeToMessageTypeIndicator] objectForKey:[NSNumber numberWithInt:[message messageType]]] intValue];
	[EsObject writeShort: messageTypeIndicator toStream:output];
	[EsObject writeInt:[message messageNumber] toStream:output];
	[output write:[thriftData bytes] maxLength:[thriftData length]];
	[output close];
	
	NSData* data = [output propertyForKey:NSStreamDataWrittenToMemoryStreamKey];
	
	return data;
}
@end
