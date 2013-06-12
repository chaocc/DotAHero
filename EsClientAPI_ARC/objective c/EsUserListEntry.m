//
//  Autogenerated by CocoaTouchApiGenerator
//
//  DO NOT EDIT UNLESS YOU ARE SURE THAT YOU KNOW WHAT YOU ARE DOING
//



#import "EsUserListEntry.h"
#import "EsThriftUtil.h"

@implementation EsUserListEntry

@synthesize userName = userName_;
@synthesize userVariables = userVariables_;
@synthesize sendingVideo = sendingVideo_;
@synthesize videoStreamName = videoStreamName_;
@synthesize roomOperator = roomOperator_;

- (id) initWithThriftObject: (id) thriftObject {
	if ((self = [super init])) {
		self.userVariables = [NSMutableArray array];
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
	ThriftUserListEntry* t = (ThriftUserListEntry*) thriftObject;
	if ([t userNameIsSet] && t.userName != nil) {
		self.userName = t.userName;
	}
	if ([t userVariablesIsSet] && t.userVariables != nil) {
		self.userVariables = [[NSMutableArray alloc] init];
		for (ThriftUserVariable* _tValVar_0 in t.userVariables) {
			EsUserVariable* _listDestVar_0;
			_listDestVar_0 = [[EsUserVariable alloc] initWithThriftObject:_tValVar_0];
			[self.userVariables addObject: _listDestVar_0];
		}
	}
	if ([t sendingVideoIsSet]) {
		self.sendingVideo = t.sendingVideo;
	}
	if ([t videoStreamNameIsSet] && t.videoStreamName != nil) {
		self.videoStreamName = t.videoStreamName;
	}
	if ([t roomOperatorIsSet]) {
		self.roomOperator = t.roomOperator;
	}
}

- (ThriftUserListEntry*) toThrift {
	ThriftUserListEntry* _t = [[ThriftUserListEntry alloc] init];;
	if (userName_set_ && userName_ != nil) {
		NSString* _userName;
		_userName = self.userName;
		_t.userName = _userName;
	}
	if (userVariables_set_ && userVariables_ != nil) {
		NSMutableArray* _userVariables;
		_userVariables = [[NSMutableArray alloc] init];
		for (EsUserVariable* _tValVar_0 in self.userVariables) {
			ThriftUserVariable* _listDestVar_0;
			_listDestVar_0 = [_tValVar_0 toThrift];
			[_userVariables addObject: _listDestVar_0];
		}
		_t.userVariables = _userVariables;
	}
	if (sendingVideo_set_) {
		BOOL _sendingVideo;
		_sendingVideo = self.sendingVideo;
		_t.sendingVideo = _sendingVideo;
	}
	if (videoStreamName_set_ && videoStreamName_ != nil) {
		NSString* _videoStreamName;
		_videoStreamName = self.videoStreamName;
		_t.videoStreamName = _videoStreamName;
	}
	if (roomOperator_set_) {
		BOOL _roomOperator;
		_roomOperator = self.roomOperator;
		_t.roomOperator = _roomOperator;
	}
	return _t;
}

- (id) newThrift {
	return [[ThriftUserListEntry alloc] init];
}

- (void) setUserName: (NSString*) userName {
	userName_ = userName;
	userName_set_ = true;
}

- (void) setUserVariables: (NSMutableArray*) userVariables {
	userVariables_ = userVariables;
	userVariables_set_ = true;
}

- (void) setSendingVideo: (BOOL) sendingVideo {
	sendingVideo_ = sendingVideo;
	sendingVideo_set_ = true;
}

- (void) setVideoStreamName: (NSString*) videoStreamName {
	videoStreamName_ = videoStreamName;
	videoStreamName_set_ = true;
}

- (void) setRoomOperator: (BOOL) roomOperator {
	roomOperator_ = roomOperator;
	roomOperator_set_ = true;
}

- (void) dealloc {
	self.userVariables = nil;
}

@end
