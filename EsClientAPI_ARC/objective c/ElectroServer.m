#import "ElectroServer.h"
#import "EsConnectionEvent.h"
#import "EsManagerHelper+Internal.h"
#import "DLOG.h"


@implementation ElectroServer

@synthesize engine = engine_;
@synthesize settingsLoader = settingsLoader_;
@synthesize managerHelper = managerHelper_; 

- (id) init {
	if (self = [super init]) {
		engine_ = [[EsEngine alloc] init];
		managerHelper_ = [[EsManagerHelper alloc] initWithElectroServer:self];
		settingsLoader_ = [[EsSettingsLoader alloc] init];
		[engine_ addEventListenerWithTarget:self action:@selector(onConnectionClosedEvent:) eventIdentifier:EsConnectionEvent_ConnectionClosed priority:EsEventDispatcher_MaxPriority];
	}
	return self;
}

- (void) onConnectionClosedEvent:(EsConnectionClosedEvent*) e {
	if (!engine_.connected) {
		managerHelper_ = [[EsManagerHelper alloc] initWithElectroServer:self];
	}
}

- (void) loadAndConnect:(NSString*) path {
	DLOG(@"[Loading settings file from %@", path);
	NSArray* servers = [settingsLoader_ readServerSettingsFromFilename:path];
	[engine_ setServers:servers];
	[engine_ connect];
}

- (void) loadAndConnect {
	NSArray* servers = [settingsLoader_ readServerSettings];
	[engine_ setServers:servers];
	[engine_ connect];
}

- (void) dealloc {
	DLOG(@"dealloc");
}
@end
