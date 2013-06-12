//
//  Autogenerated by CocoaTouchApiGenerator
//
//  DO NOT EDIT UNLESS YOU ARE SURE THAT YOU KNOW WHAT YOU ARE DOING
//



#import "EsGetGameTypesResponse.h"
#import "EsThriftUtil.h"

@implementation EsGetGameTypesResponse

@synthesize gameTypes = gameTypes_;

- (id) initWithThriftObject: (id) thriftObject {
	if ((self = [super init])) {
		self.messageType = EsMessageType_GetGameTypesResponse;
		self.gameTypes = [NSMutableArray array];
		if (thriftObject != nil) {
			[self fromThrift: thriftObject];
		}
	}
	return self;
}

- (id) init {
	return [self initWithThriftObject: nil];
}

- (void) fromThrift: (id) thriftObject {
	ThriftGetGameTypesResponse* t = (ThriftGetGameTypesResponse*) thriftObject;
	if ([t gameTypesIsSet] && t.gameTypes != nil) {
		self.gameTypes = [[NSMutableArray alloc] init];
		for (NSString* _tValVar_0 in t.gameTypes) {
			NSString* _listDestVar_0;
			_listDestVar_0 = _tValVar_0;
			[self.gameTypes addObject: _listDestVar_0];
		}
	}
}

- (ThriftGetGameTypesResponse*) toThrift {
	ThriftGetGameTypesResponse* _t = [[ThriftGetGameTypesResponse alloc] init];;
	if (gameTypes_set_ && gameTypes_ != nil) {
		NSMutableArray* _gameTypes;
		_gameTypes = [[NSMutableArray alloc] init];
		for (NSString* _tValVar_0 in self.gameTypes) {
			NSString* _listDestVar_0;
			_listDestVar_0 = _tValVar_0;
			[_gameTypes addObject: _listDestVar_0];
		}
		_t.gameTypes = _gameTypes;
	}
	return _t;
}

- (id) newThrift {
	return [[ThriftGetGameTypesResponse alloc] init];
}

- (void) setGameTypes: (NSMutableArray*) gameTypes {
	gameTypes_ = gameTypes;
	gameTypes_set_ = true;
}

- (void) dealloc {
	self.gameTypes = nil;
}

@end