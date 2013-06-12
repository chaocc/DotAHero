//
//  EsObject.m
//  cocoa-touch
//
//  Created by Jason von Nieda on 12/7/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "EsObject.h"
#import "DLOG.h"

@implementation EsObjectValue

+ (id) esObjectValueWithType: (int16_t) type value: (id) value {
	EsObjectValue* o = [[EsObjectValue alloc] init];
	o->type_ = type;
	o->value_ = value;
	return o;
}


- (int16_t) type {
	return type_;
}

- (id) value {
	return value_;
}

- (NSString*) description {
	return [NSString stringWithFormat:@"%c %@", type_, value_];
}

@end

// TODO revisit memory in this class, especially the read methods and the helper method
@implementation EsObject
- (id) init {
	if ((self = [super init]) != nil) {
		dict_ = [[NSMutableDictionary alloc] init];
	}
	return self;
}


+ (EsObject*) esObjectFromData: (NSData*) data {
	NSInputStream* is = [NSInputStream inputStreamWithData:data];
	[is open];
	EsObject* eso = [EsObject readEsObjectFromStream:is];
	[is close];
	return eso;
}

/*
 This should be moved into writeEsObject: toStream:
*/
- (NSData*) data {
	NSOutputStream* os = [NSOutputStream outputStreamToMemory];
	[os open];
	/*
	 1 string
	 2 double
	 c string array
	 0 int
	 b int array
	 4 bool
	 5 byte
	 f boolean array
	 3 float
	 e float array
	 8 short
	 9 esobject
	 a esobject array
	 g byte array
	 */
	
	NSString* key;
	NSEnumerator* e = [dict_ keyEnumerator];
	
	uint8_t flags = 0;
	[EsObject writeByte:flags toStream:os];
	
	[EsObject writeLength:[self count] toStream:os];
	while ((key = [e nextObject])) {
		EsObjectValue* esov = [dict_ objectForKey:key];
		[EsObject writeByte:[esov type] toStream:os];
		[EsObject writeString:key toStream:os];
		switch ([esov type]) {
			case '1':
				[EsObject writeString:[self stringWithKey:key] toStream:os];
				break;
			case '2':
				[EsObject writeDouble:[self doubleWithKey:key] toStream:os];
				break;
			case 'c':
				[EsObject writeStringArray:[self stringArrayWithKey:key] toStream:os];
				break;
			case '0':
				[EsObject writeInt:[self intWithKey:key] toStream:os];
				break;
			case 'b':
				[EsObject writeIntArray: [self intArrayWithKey:key] toStream:os];
				break;
			case '4':
				[EsObject writeBool:[self boolWithKey:key] toStream:os];
				break;
			case '5':
				[EsObject writeByte:[self byteWithKey:key] toStream:os];
				break;
			case 'f':
				[EsObject writeBoolArray:[self boolArrayWithKey:key] toStream:os];
				break;
			case '3':
				[EsObject writeFloat:[self floatWithKey:key] toStream:os];
				break;
			case 'e':
				[EsObject writeFloatArray:[self floatArrayWithKey:key] toStream:os];
				break;
			case '8':
				[EsObject writeShort:[self shortWithKey:key] toStream:os];
				break;
			case '9':
				[EsObject writeEsObject:[self esObjectWithKey:key] toStream:os];
				break;
			case 'a':
				[EsObject writeEsObjectArray:[self esObjectArrayWithKey:key] toStream:os];
				break;
			case 'g':
				[EsObject writeByteArray:[self byteArrayWithKey:key] toStream:os];
				break;
		}
	}
	[os close];
	NSData* d = [os propertyForKey:NSStreamDataWrittenToMemoryStreamKey];
	return d;
}

+ (void) writeBool: (BOOL) val toStream: (NSOutputStream*) stream {
	[EsObject writeByte:(val == TRUE ? 1 : 0) toStream:stream];
}
				 
+ (void) writeBoolArray: (NSArray*) val toStream: (NSOutputStream*) stream {
	[EsObject writeLength:[val count] toStream:stream];
	for (NSUInteger i = 0; i < [val count]; i++) {
		[EsObject writeBool:[[val objectAtIndex:i] boolValue] toStream:stream];
	}
}					 
				 
+ (void) writeByte: (uint8_t) val toStream: (NSOutputStream*) stream {
	[stream write:&val maxLength:1];
}

+ (void) writeByteArray: (NSData*) val toStream: (NSOutputStream*) stream {
	[EsObject writeLength:[val length] toStream: stream];
	[stream write:[val bytes] maxLength:[val length]];
}

+ (void) writeFloat: (float) val toStream: (NSOutputStream*) stream {
	NSSwappedFloat v = NSSwapHostFloatToBig(val);
	[stream write:(uint8_t*) &v maxLength:4];
}

+ (void) writeFloatArray: (NSArray*) val toStream: (NSOutputStream*) stream {
	[EsObject writeLength:[val count] toStream:stream];
	for (NSUInteger i = 0; i < [val count]; i++) {
		[EsObject writeFloat:[[val objectAtIndex:i] floatValue] toStream:stream];
	}
}

+ (void) writeDouble: (double) val toStream: (NSOutputStream*) stream {
	NSSwappedDouble v = NSSwapHostDoubleToBig(val);
	[stream write:(uint8_t*) &v maxLength:8];
}

+ (void) writeInt: (int32_t) val toStream: (NSOutputStream*) stream {
	int v = NSSwapHostIntToBig(val);
	[stream write:(uint8_t*) &v maxLength:4];
}

+ (void) writeIntArray: (NSArray*) val toStream: (NSOutputStream*) stream {
	[EsObject writeLength:[val count] toStream:stream];
	for (NSUInteger i = 0; i < [val count]; i++) {
		[EsObject writeInt:[[val objectAtIndex:i] intValue] toStream:stream];
	}
}

+ (void) writeShort: (int16_t) val toStream: (NSOutputStream*) stream {
	short v = NSSwapHostShortToBig(val);
	[stream write:(uint8_t*) &v maxLength:2];
}

+ (void) writeString: (NSString*) val toStream: (NSOutputStream*) stream {
	if ([val length] == 0) {
		[EsObject writeLength:0 toStream:stream];
		return;
	}
	NSData* d = [val dataUsingEncoding:NSUTF8StringEncoding];
	[EsObject writeLength:[d length] toStream:stream];
	[stream write:[d bytes] maxLength:[d length]];
}

+ (void) writeStringArray: (NSArray*) val toStream: (NSOutputStream*) stream {
	[EsObject writeLength:[val count] toStream:stream];
	for (NSUInteger i = 0; i < [val count]; i++) {
		[EsObject writeString:[val objectAtIndex:i] toStream:stream];
	}
}

+ (void) writeEsObject: (EsObject*) val toStream: (NSOutputStream*) stream {
	NSData* d = [val data];
	[stream write:[d bytes] maxLength:[d length]];
}

+ (void) writeEsObjectArray: (NSArray*) val toStream: (NSOutputStream*) stream {
	[EsObject writeLength:[val count] toStream:stream];
	for (NSUInteger i = 0; i < [val count]; i++) {
		[EsObject writeEsObject:[val objectAtIndex:i] toStream:stream];
	}
}

/**
 * Length is encoded as either 1, 2 3 or 4 bytes. The 2 most significant bits of the first
 * byte contain the length in bytes of the field and then value encoding starts immediately
 * with the next 6 bits. The field is encoded big endian. This scheme gives the following
 * maximums per byte count:
 * 1 = 63
 * 2 = 16,383
 * 3 = 4,194,303
 * 4 = 1,073,741,823
 * Values larger than 1,073,741,823 will result in an Error being thrown.
 * @param length
 * @return
 */
+ (void) writeLength: (int) length toStream:(NSOutputStream*)  stream {
	if ((length & 0x40000000) != 0) {
		DLOG(@"Length too large");
		return;
	}
	int byteCount = 1;
	if (length > 0x3fffff) {
		byteCount = 4;
	}
	else if (length > 0x3fff) {
		byteCount = 3;
	}
	else if (length > 0x3f) {
		byteCount = 2;
	}
	uint8_t b = (uint8_t) ((byteCount - 1) << 6);
	for (int i = byteCount - 1; i >= 0; i--) {
		b |= ((length >> (i * 8)) & 0xff);
		[EsObject writeByte:b toStream:stream];
		b = 0;
	}
}

+ (BOOL) readBoolFromStream: (NSInputStream*) stream {
	uint8_t val;
	[stream read:&val maxLength:1];
	return val ? TRUE : FALSE;
}

+ (NSArray*) readBoolArrayFromStream: (NSInputStream*) stream {
	int32_t count = [EsObject readLengthFromStream:stream];
	NSMutableArray* a = [NSMutableArray array];
	for (int i = 0; i < count; i++) {
		[a addObject:[NSNumber numberWithBool:[EsObject readBoolFromStream:stream]]];
	}
	return a;
}

+ (uint8_t) readByteFromStream: (NSInputStream*) stream {
	uint8_t val;
	[stream read:&val maxLength:1];
	return val;
}

+ (NSData*) readByteArrayFromStream: (NSInputStream*) stream {
	int32_t length = [EsObject readLengthFromStream:stream];
	uint8_t* buf = malloc(length);
	[stream read:buf maxLength:length];
	NSData* data = [NSData dataWithBytes:buf length:length];
    free(buf);
	return data;
}

+ (float) readFloatFromStream: (NSInputStream*) stream {
	NSSwappedFloat x;
	[stream read:(uint8_t*) &x maxLength:4];
	float val = NSSwapBigFloatToHost(x);
	return val;
}

+ (NSArray*) readFloatArrayFromStream: (NSInputStream*) stream {
    int32_t count = [EsObject readLengthFromStream:stream];
    NSMutableArray * array = [NSMutableArray array];
    for (int i = 0; i < count; i++) {
        [array addObject:[NSNumber numberWithFloat:[EsObject readFloatFromStream:stream]]];
    }
    return array;
}

+ (double) readDoubleFromStream: (NSInputStream*) stream {
	NSSwappedDouble x;
	[stream read:(uint8_t*) &x maxLength:8];
	float val = NSSwapBigDoubleToHost(x);
	return val;
}

+ (int32_t) readIntFromStream: (NSInputStream*) stream {
	int32_t val;
	[stream read:(uint8_t*) &val maxLength:4];
	val = NSSwapBigIntToHost(val);
	return val;
}

+ (NSArray*) readIntArrayFromStream: (NSInputStream*) stream {
	int32_t count = [EsObject readLengthFromStream:stream];
	NSMutableArray* a = [NSMutableArray array];
	for (int i = 0; i < count; i++) {
		[a addObject:[NSNumber numberWithInt:[EsObject readIntFromStream:stream]]];
	}
	return a;
}

+ (int16_t) readShortFromStream: (NSInputStream*) stream {
	int16_t val;
	[stream read:(uint8_t*) &val maxLength:2];
	val = NSSwapBigShortToHost(val);
	return val;
}

+ (NSString*) readStringFromStream: (NSInputStream*) stream {
	int16_t length = [EsObject readLengthFromStream:stream];
	uint8_t* buf = malloc(length);
	[stream read:buf maxLength:length];
	NSString* str = [[NSString alloc] initWithBytes:buf length:length encoding:NSUTF8StringEncoding];
	free(buf);
	return str;
}

+ (NSArray*) readStringArrayFromStream: (NSInputStream*) stream {
	int32_t count = [EsObject readLengthFromStream:stream];
	NSMutableArray* a = [NSMutableArray array];
	for (int i = 0; i < count; i++) {
		[a addObject:[EsObject readStringFromStream:stream]];
	}
	return a;
}

+ (EsObject*) readEsObjectFromStream: (NSInputStream*) stream {
	EsObject* eso = [[EsObject alloc] init];
	uint8_t flags = [EsObject readByteFromStream:stream];
    switch (flags) {
            // we don't currently use flags, but we don't want an unused
            // variable warning about it either.
    }
	int count = [EsObject readLengthFromStream:stream];
	for (int i = 0; i < count; i++) {
		uint16_t type = [EsObject readByteFromStream:stream];
		NSString* key = [EsObject readStringFromStream:stream];
		switch (type) {
			case '1':
				[eso setString:[EsObject readStringFromStream:stream] forKey:key];
				break;
			case '2':
				[eso setDouble:[EsObject readDoubleFromStream:stream] forKey:key];
				break;
			case 'c':
				[eso setStringArray:[EsObject readStringArrayFromStream:stream] forKey:key];
				break;
			case '0':
				[eso setInt:[EsObject readIntFromStream:stream] forKey:key];
				break;
			case 'b':
				[eso setIntArray:[EsObject readIntArrayFromStream:stream] forKey:key];
				break;
			case '4':
				[eso setBool:[EsObject readBoolFromStream:stream] forKey:key];
				break;
			case '5':
				[eso setByte:[EsObject readByteFromStream:stream] forKey:key];
				break;
			case 'f':
				[eso setBoolArray:[EsObject readBoolArrayFromStream:stream] forKey:key];
				break;
			case '3':
				[eso setFloat:[EsObject readFloatFromStream:stream] forKey:key];
				break;
			case 'e':
				[eso setFloatArray:[EsObject readFloatArrayFromStream:stream] forKey:key];
				break;
			case '8':
				[eso setShort:[EsObject readShortFromStream:stream] forKey:key];
				break;
			case '9':
				[eso setEsObject:[EsObject readEsObjectFromStream:stream] forKey:key];
				break;
			case 'a':
				[eso setEsObjectArray:[EsObject readEsObjectArrayFromStream:stream] forKey:key];
				break;
			case 'g':
				[eso setByteArray:[EsObject readByteArrayFromStream:stream] forKey:key];
				break;
		}
	}
	return eso;
}

+ (NSArray*) readEsObjectArrayFromStream: (NSInputStream*) stream {
	int32_t count = [EsObject readLengthFromStream:stream];
	NSMutableArray* a = [NSMutableArray array];
	for (int i = 0; i < count; i++) {
		[a addObject:[EsObject readEsObjectFromStream:stream]];
	}
	return a;
}

+ (int64_t) readLongFromStream: (NSInputStream*) stream {
	int64_t val;
	[stream read:(uint8_t*) &val maxLength:8];
	val = NSSwapBigLongLongToHost(val);
	return val;
}

/**
 * Length is encoded as either 1, 2 3 or 4 bytes. The 2 most significant bits of the first
 * byte contain the length in bytes of the field and then value encoding starts immediately
 * with the next 6 bits. The field is encoded big endian. This scheme gives the following
 * maximums per byte count:
 * 1 = 63
 * 2 = 16,383
 * 3 = 4,194,303
 * 4 = 1,073,741,823
 * Values larger than 1,073,741,823 will result in an Error being thrown.
 * @param length
 * @return
 */
+ (int) readLengthFromStream:(NSInputStream*) stream {
	uint8_t firstByte = [EsObject readByteFromStream:stream];
	int byteCount = (firstByte >> 6) & 0x03;
	int length = (firstByte & 0x3f);
	for (int i = 0; i < byteCount; i++) {
		length <<= 8;
		length |= ([EsObject readByteFromStream:stream] & 0xff);
	}
	return length;
}

- (int) count {
	return [dict_ count];
}

- (BOOL) containsKey: (NSString*) key {
	return [dict_ objectForKey:key] != nil;
}

- (void) addAll: (EsObject*) object {
    // use enumerator (it's faster!)
    NSEnumerator *enumerator = [object enumerator];
    NSString *key;
    while ((key = [enumerator nextObject])) {
        // get value and type
        EsObjectValue *esvalue = [object valueForKey:key];
        id value = [esvalue value];
        int16_t type = [esvalue type];
        
        // switch over types
        switch (type) {
            case EsObjectDataType_String:
                [self setString:value forKey:key];
                break;
            case EsObjectDataType_Double:
                [self setDouble:[((NSNumber *)value) doubleValue] forKey:key];
                break;
            case EsObjectDataType_StringArray:
                [self setStringArray:value forKey:key];
                break;
            case EsObjectDataType_Int:
                [self setInt:[((NSNumber *)value) intValue] forKey:key];
                break;
            case EsObjectDataType_IntArray:
                [self setIntArray:value forKey:key];
                break;
            case EsObjectDataType_Bool:
                [self setBool:[((NSNumber *)value) boolValue] forKey:key];
                break;
            case EsObjectDataType_Byte:
                [self setByte:[((NSNumber *)value) intValue] forKey:key];
                break;
            case EsObjectDataType_BoolArray:
                [self setBoolArray:value forKey:key];
                break;
            case EsObjectDataType_Float:
                [self setFloat:[((NSNumber *)value) floatValue] forKey:key];
                break;
            case EsObjectDataType_FloatArray:
                [self setFloatArray:value forKey:key];
                break;
            case EsObjectDataType_Short:
                [self setShort:[((NSNumber *)value) intValue] forKey:key];
                break;
            case EsObjectDataType_EsObject:
                [self setEsObject:value forKey:key];
                break;
            case EsObjectDataType_EsObjectArray:
                [self setEsObjectArray:value forKey:key];
                break;
            case EsObjectDataType_ByteArray:
                [self setByteArray:value forKey:key];
                break;
            default:
                NSLog(@"EsObject.addAll() data type not supported : %i.", type);
        }
    }
}

- (EsObject *) shallowClone {
    EsObject *object = [[EsObject alloc] init];
    [object addAll:self];
    return object;
}

- (EsObject *) deepClone {
    // start with shallow clone
    EsObject *object = [self shallowClone];

    // we need this later
    NSEnumerator *esObEnum;
    
    // enumerate over keys
    NSEnumerator *enumerator = [object enumerator];
    NSString *key;
    while ((key = [enumerator nextObject])) {
        // get EsObjectValue
        EsObjectValue *esvalue = [object valueForKey:key];
        
        // get typed value and type
        id value = [esvalue value];
        int16_t type = [esvalue type];
        
        // switch over types
        switch (type) {
            // primitives are already done
            case EsObjectDataType_String:
            case EsObjectDataType_Double:
            case EsObjectDataType_Int:
            case EsObjectDataType_Bool:    
            case EsObjectDataType_Byte:
            case EsObjectDataType_Float:
            case EsObjectDataType_Short:
                break;
            
            // for primitive arrays we can use NSArray:arrayWithArray
            case EsObjectDataType_StringArray:
                [object setStringArray:[NSArray arrayWithArray:value] forKey:key];
                break;
            case EsObjectDataType_IntArray:
                [object setIntArray:[NSArray arrayWithArray:value] forKey:key];
                break;
            case EsObjectDataType_BoolArray:
                [object setBoolArray:[NSArray arrayWithArray:value] forKey:key];
                break;
            case EsObjectDataType_FloatArray:
                [object setFloatArray:[NSArray arrayWithArray:value] forKey:key];
                break;
            case EsObjectDataType_ByteArray:
                [object setByteArray:[NSArray arrayWithArray:value] forKey:key];
                break;
            
            // recur on EsObjects
            case EsObjectDataType_EsObject:
                [object setEsObject:[((EsObject *)value) deepClone] forKey:key];
                break;
            case EsObjectDataType_EsObjectArray:
            {
                esObEnum = [((NSArray *)value) objectEnumerator];
                id obj;
                NSMutableArray *array = [NSMutableArray array];
                while ((obj = [esObEnum nextObject])) {
                    [array addObject:[((EsObject *)obj) deepClone]];
                }
                [object setEsObjectArray:array forKey:key];
            }
                break;
                
            default:
                NSLog(@"EsObject.deepClone() data type not supported : %i.", type);
                break;
        }
    }
    
    return object;
}

- (NSString*) stringWithKey: (NSString*) key {
	return [(EsObjectValue *)[dict_ objectForKey:key] value];
}

- (void) setString: (NSString*) val forKey: (NSString*) key {
	[dict_ setObject:[EsObjectValue esObjectValueWithType:'1' value:val] forKey:key];
}

- (NSArray*) stringArrayWithKey: (NSString*) key {
	return (NSArray*) [(EsObjectValue *)[dict_ objectForKey:key] value];
}

- (void) setStringArray: (NSArray*) aVal forKey: (NSString*) key {
	[dict_ setObject:[EsObjectValue esObjectValueWithType:'c' value:aVal] forKey:key];
}


- (double) doubleWithKey: (NSString*) key {
	return [[(EsObjectValue *)[dict_ objectForKey:key] value] doubleValue];
}

- (void) setDouble: (double) val forKey: (NSString*) key {
	[dict_ setObject:[EsObjectValue esObjectValueWithType:'2' value:[NSNumber numberWithDouble:val]] forKey:key];
}


- (int32_t) intWithKey: (NSString*) key {
	return [[(EsObjectValue *)[dict_ objectForKey:key] value] intValue];
}

- (void) setInt: (int32_t) val forKey: (NSString*) key {
	[dict_ setObject:[EsObjectValue esObjectValueWithType:'0' value:[NSNumber numberWithInt:val]] forKey:key];
}

- (NSArray*) intArrayWithKey: (NSString*) key {
	return (NSArray*) [(EsObjectValue *)[dict_ objectForKey:key] value];
}

- (void) setIntArray: (NSArray*) aVal forKey: (NSString*) key {
	[dict_ setObject:[EsObjectValue esObjectValueWithType:'b' value:aVal] forKey:key];
}


- (BOOL) boolWithKey: (NSString*) key {
	return [[(EsObjectValue *)[dict_ objectForKey:key] value] boolValue];
}

- (void) setBool: (BOOL) val forKey: (NSString*) key {
	[dict_ setObject:[EsObjectValue esObjectValueWithType:'4' value:[NSNumber numberWithBool:val]] forKey:key];
}

- (NSArray*) boolArrayWithKey: (NSString*) key {
	return (NSArray*) [(EsObjectValue *)[dict_ objectForKey:key] value];
}

- (void) setBoolArray: (NSArray*) aVal forKey: (NSString*) key {
	[dict_ setObject:[EsObjectValue esObjectValueWithType:'f' value:aVal] forKey:key];
}


- (uint8_t) byteWithKey: (NSString*) key {
	return [((NSNumber*) [(EsObjectValue *)[dict_ objectForKey:key] value]) unsignedCharValue];
}

- (void) setByte: (uint8_t) val forKey: (NSString*) key {
	[dict_ setObject:[EsObjectValue esObjectValueWithType:'5' value:[NSNumber numberWithUnsignedChar:val]] forKey:key];
}

- (NSData*) byteArrayWithKey: (NSString*) key {
	return (NSData*) [(EsObjectValue *)[dict_ objectForKey:key] value];
}

- (void) setByteArray: (NSData*) aVal forKey: (NSString*) key {
	[dict_ setObject:[EsObjectValue esObjectValueWithType:'g' value:aVal] forKey:key];
}


- (float) floatWithKey: (NSString*) key {
	return [((NSNumber*) [(EsObjectValue *)[dict_ objectForKey:key] value]) floatValue];
}

- (void) setFloat: (float) val forKey: (NSString*) key {
	[dict_ setObject:[EsObjectValue esObjectValueWithType:'3' value:[NSNumber numberWithFloat:val]] forKey:key];
}

- (NSArray*) floatArrayWithKey: (NSString*) key {
	return (NSArray*) [(EsObjectValue *)[dict_ objectForKey:key] value];
}

- (void) setFloatArray: (NSArray*) aVal forKey: (NSString*) key {
	[dict_ setObject:[EsObjectValue esObjectValueWithType:'e' value:aVal] forKey:key];
}


- (int16_t) shortWithKey: (NSString*) key {
	return [((NSNumber*) [(EsObjectValue *)[dict_ objectForKey:key] value]) shortValue];
}

- (void) setShort: (int16_t) val forKey: (NSString*) key {
	[dict_ setObject:[EsObjectValue esObjectValueWithType:'8' value:[NSNumber numberWithShort:val]] forKey:key];
}


- (EsObject*) esObjectWithKey: (NSString*) key {
	return (EsObject*) [(EsObjectValue *)[dict_ objectForKey:key] value];
}

- (void) setEsObject: (EsObject*) val forKey: (NSString*) key {
	[dict_ setObject:[EsObjectValue esObjectValueWithType:'9' value:val] forKey:key];
}

- (NSArray*) esObjectArrayWithKey: (NSString*) key {
	return (NSArray*) [(EsObjectValue *)[dict_ objectForKey:key] value];
}

- (void) setEsObjectArray: (NSArray*) aVal forKey: (NSString*) key {
	[dict_ setObject:[EsObjectValue esObjectValueWithType:'a' value:aVal] forKey:key];
}

- (NSString*) description {
	return [dict_ description];
}

+ (NSString*) hexDumpForData: (NSData*) data {
	return [EsObject hexDumpForBytes:(uint8_t*) [data bytes] offset:0 length:[data length]];
}

+ (NSString*) hexDumpForBytes: (uint8_t*) bytes offset: (int) offset length: (int) length {
	NSMutableString* str = [NSMutableString stringWithFormat:@"\n"];
	NSMutableString* tmp = [NSMutableString string];
	for (int i = offset; i < length; i++) {
		[str appendFormat:@"%02x ", bytes[i]];
		[tmp appendFormat:@"%c", isprint(bytes[i]) ? bytes[i] : '.'];
		if (i % 16 == 15) {
			[str appendString:tmp];
			[str appendString:@"\n"];
			tmp = [NSMutableString string];
		}
	}
	if (length % 16 < 15) {
		for (int i = 0; i < 16 - (length % 16); i++) {
			[str appendString:@"   "];
		}
		[str appendString:tmp];
	}
	return str;
}

- (NSEnumerator *) enumerator {
    return [dict_ keyEnumerator];
}

- (NSArray*) keys {
	return [dict_ allKeys];
}

- (id) valueForKey:(NSString*) key {
	return [dict_ objectForKey:key];
}

@end
