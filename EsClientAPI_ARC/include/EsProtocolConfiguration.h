//
//  Autogenerated by CocoaTouchApiGenerator
//
//  DO NOT EDIT UNLESS YOU ARE SURE THAT YOU KNOW WHAT YOU ARE DOING
//



#import "EsMessage.h"
#import "EsMessageType.h"
#import "EsRequest.h"
#import "EsResponse.h"
#import "EsEvent.h"
#import "EsEntity.h"
#import "EsObject.h"
#import "ThriftProtocolConfiguration.h"

@interface EsProtocolConfiguration : EsEntity {
@private
	BOOL messageCompressionThreshold_set_;
	int32_t messageCompressionThreshold_;
}

@property(nonatomic) int32_t messageCompressionThreshold;

- (id) init;
- (id) initWithThriftObject: (id) thriftObject;
- (void) fromThrift: (id) thriftObject;
- (ThriftProtocolConfiguration*) toThrift;
- (id) newThrift;
@end
