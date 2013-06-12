//
//  EsObject.h
//  cocoa-touch
//
//  Created by Jason von Nieda on 12/7/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.

#import <Foundation/Foundation.h>

enum {
	EsObjectDataType_String = '1',
	EsObjectDataType_Double = '2',
	EsObjectDataType_StringArray = 'c',
	EsObjectDataType_Int = '0',
	EsObjectDataType_IntArray = 'b',
	EsObjectDataType_Bool = '4',
	EsObjectDataType_Byte = '5',
	EsObjectDataType_BoolArray = 'f',
	EsObjectDataType_Float = '3',
	EsObjectDataType_FloatArray = 'e',
	EsObjectDataType_Short = '8',
	EsObjectDataType_EsObject = '9',
	EsObjectDataType_EsObjectArray = 'a',
	EsObjectDataType_ByteArray = 'g'
};

@interface EsObject : NSObject {
	@private
	NSMutableDictionary* dict_;
}

+ (EsObject*) esObjectFromData: (NSData*) data;

- (NSData*) data;

- (int) count;

- (BOOL) containsKey: (NSString*) key;

- (void) addAll: (EsObject*) object;
- (EsObject *) shallowClone;
- (EsObject *) deepClone;

- (NSString*) stringWithKey: (NSString*) key;
- (void) setString: (NSString*) val forKey: (NSString*) key;
- (NSArray*) stringArrayWithKey: (NSString*) key;
- (void) setStringArray: (NSArray*) aVal forKey: (NSString*) key;

- (double) doubleWithKey: (NSString*) key;
- (void) setDouble: (double) val forKey: (NSString*) key;

- (int32_t) intWithKey: (NSString*) key;
- (void) setInt: (int32_t) val forKey: (NSString*) key;
- (NSArray*) intArrayWithKey: (NSString*) key;
- (void) setIntArray: (NSArray*) aVal forKey: (NSString*) key;

- (BOOL) boolWithKey: (NSString*) key;
- (void) setBool: (BOOL) val forKey: (NSString*) key;
- (NSArray*) boolArrayWithKey: (NSString*) key;
- (void) setBoolArray: (NSArray*) aVal forKey: (NSString*) key;

- (uint8_t) byteWithKey: (NSString*) key;
- (void) setByte: (uint8_t) val forKey: (NSString*) key;
- (NSData*) byteArrayWithKey: (NSString*) key;
- (void) setByteArray: (NSData*) aVal forKey: (NSString*) key;

- (float) floatWithKey: (NSString*) key;
- (void) setFloat: (float) val forKey: (NSString*) key;
- (NSArray*) floatArrayWithKey: (NSString*) key;
- (void) setFloatArray: (NSArray*) aVal forKey: (NSString*) key;

- (int16_t) shortWithKey: (NSString*) key;
- (void) setShort: (int16_t) val forKey: (NSString*) key;

- (EsObject*) esObjectWithKey: (NSString*) key;
- (void) setEsObject: (EsObject*) val forKey: (NSString*) key;
- (NSArray*) esObjectArrayWithKey: (NSString*) key;
- (void) setEsObjectArray: (NSArray*) aVal forKey: (NSString*) key;

- (NSEnumerator *) enumerator;
- (NSArray*) keys;
- (id) valueForKey:(NSString*) key;

+ (void) writeBool: (BOOL) val toStream: (NSOutputStream*) stream;
+ (void) writeBoolArray: (NSArray*) val toStream: (NSOutputStream*) stream;
+ (void) writeByte: (uint8_t) val toStream: (NSOutputStream*) stream;
+ (void) writeByteArray: (NSData*) val toStream: (NSOutputStream*) stream;
+ (void) writeFloat: (float) val toStream: (NSOutputStream*) stream;
+ (void) writeFloatArray: (NSArray*) val toStream: (NSOutputStream*) stream;
+ (void) writeDouble: (double) val toStream: (NSOutputStream*) stream;
+ (void) writeInt: (int32_t) val toStream: (NSOutputStream*) stream;
+ (void) writeIntArray: (NSArray*) val toStream: (NSOutputStream*) stream;
+ (void) writeShort: (int16_t) val toStream: (NSOutputStream*) stream;
+ (void) writeString: (NSString*) val toStream: (NSOutputStream*) stream;
+ (void) writeStringArray: (NSArray*) val toStream: (NSOutputStream*) stream;
+ (void) writeEsObject: (EsObject*) val toStream: (NSOutputStream*) stream;
+ (void) writeEsObjectArray: (NSArray*) val toStream: (NSOutputStream*) stream;
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
+ (void) writeLength: (int) length toStream:(NSOutputStream*)  stream;

+ (BOOL) readBoolFromStream: (NSInputStream*) stream;
+ (NSArray*) readBoolArrayFromStream: (NSInputStream*) stream;
+ (uint8_t) readByteFromStream: (NSInputStream*) stream;
+ (NSData*) readByteArrayFromStream: (NSInputStream*) stream;
+ (float) readFloatFromStream: (NSInputStream*) stream;
+ (NSArray*) readFloatArrayFromStream: (NSInputStream*) stream;
+ (double) readDoubleFromStream: (NSInputStream*) stream;
+ (int32_t) readIntFromStream: (NSInputStream*) stream;
+ (NSArray*) readIntArrayFromStream: (NSInputStream*) stream;
+ (int16_t) readShortFromStream: (NSInputStream*) stream;
+ (NSString*) readStringFromStream: (NSInputStream*) stream;
+ (NSArray*) readStringArrayFromStream: (NSInputStream*) stream;
+ (EsObject*) readEsObjectFromStream: (NSInputStream*) stream;
+ (NSArray*) readEsObjectArrayFromStream: (NSInputStream*) stream;
+ (int64_t) readLongFromStream: (NSInputStream*) stream;
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
+ (int) readLengthFromStream:(NSInputStream*) stream;
	

+ (NSString*) hexDumpForData: (NSData*) data;
+ (NSString*) hexDumpForBytes: (uint8_t*) bytes offset: (int) offset length: (int) length;

@end

@interface EsObjectValue : NSObject {
@private
	int16_t type_;
	id value_;
}

+ (id) esObjectValueWithType: (int16_t) type value: (id) value;

- (int16_t) type;
- (id) value;

@end
