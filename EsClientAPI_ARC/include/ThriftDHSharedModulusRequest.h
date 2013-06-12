/**
 * Autogenerated by Thrift
 *
 * DO NOT EDIT UNLESS YOU ARE SURE THAT YOU KNOW WHAT YOU ARE DOING
 */

#import <Foundation/Foundation.h>

#import "TProtocol.h"
#import "TApplicationException.h"
#import "TProtocolUtil.h"
#import "TProcessor.h"


@interface ThriftDHSharedModulusRequest : NSObject <NSCoding> {
  NSString * __number;

  BOOL __number_isset;
}

#if TARGET_OS_IPHONE || (MAC_OS_X_VERSION_MAX_ALLOWED >= MAC_OS_X_VERSION_10_5)
@property (nonatomic, strong, getter=number, setter=setNumber:) NSString * number;
#endif

- (id) initWithNumber: (NSString *) number;

- (void) read: (id <TProtocol>) inProtocol;
- (void) write: (id <TProtocol>) outProtocol;

- (NSString *) number;
- (void) setNumber: (NSString *) number;
- (BOOL) numberIsSet;

@end

@interface ThriftDHSharedModulusRequestConstants : NSObject {
}
@end
