//
//  EsObjectCodec.m
//  cocoa-touch
//
//  Created by Jason von Nieda on 9/20/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "EsObjectCodec.h"


@implementation EsObjectCodec
+ (EsFlattenedEsObject*) flattenEsObject: (EsObject*) esObject {
	NSOutputStream* stream = [NSOutputStream outputStreamToMemory];
	[stream open];
	[EsObject writeEsObject:esObject toStream:stream];
	[stream close];
	NSData* streamData = [stream propertyForKey:NSStreamDataWrittenToMemoryStreamKey];
	const unsigned char* streamBytes = [streamData bytes];
	NSMutableArray* bytes = [NSMutableArray array];
	for (NSUInteger i = 0; i < [streamData length]; i++) {
		[bytes addObject:[NSNumber numberWithUnsignedChar:streamBytes[i]]];
	}
	EsFlattenedEsObject* fEsObject = [[EsFlattenedEsObject alloc] init];
	
	fEsObject.encodedEntries = bytes;
	return fEsObject;
}

+ (EsFlattenedEsObjectRO*) flattenEsObjectRO: (EsObject*) esObject {
	NSOutputStream* stream = [NSOutputStream outputStreamToMemory];
	[stream open];
	[EsObject writeEsObject:esObject toStream:stream];
	[stream close];
	NSData* streamData = [stream propertyForKey:NSStreamDataWrittenToMemoryStreamKey];
	const unsigned char* streamBytes = [streamData bytes];
	NSMutableArray* bytes = [NSMutableArray array];
	for (NSUInteger i = 0; i < [streamData length]; i++) {
		[bytes addObject:[NSNumber numberWithUnsignedChar:streamBytes[i]]];
	}
	EsFlattenedEsObjectRO* fEsObject = [[EsFlattenedEsObjectRO alloc] init];
    
	fEsObject.encodedEntries = bytes;
	return fEsObject;
}

+ (EsObject*) unflattenEsObject: (EsFlattenedEsObject*) fEsObject {
	NSMutableData* data = [NSMutableData data];
	for (NSUInteger i = 0; i < [fEsObject.encodedEntries count]; i++) {
		unsigned char b = [[fEsObject.encodedEntries objectAtIndex:i] unsignedCharValue];
		[data appendBytes:&b length:1];
	}
	NSInputStream* stream = [NSInputStream inputStreamWithData:data];
	[stream open];
	EsObject* esObject = [EsObject readEsObjectFromStream:stream];
	[stream close];
	return esObject;
}

+ (EsObject*) unflattenEsObjectRO: (EsFlattenedEsObjectRO*) fEsObject {
	NSMutableData* data = [NSMutableData data];
	for (NSUInteger i = 0; i < [fEsObject.encodedEntries count]; i++) {
		unsigned char b = [[fEsObject.encodedEntries objectAtIndex:i] unsignedCharValue];
		[data appendBytes:&b length:1];
	}
	NSInputStream* stream = [NSInputStream inputStreamWithData:data];
	[stream open];
	EsObject* esObject = [EsObject readEsObjectFromStream:stream];
	[stream close];
	return esObject;
}
@end
