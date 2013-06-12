#import "EsZoneManager+Internal.h"


@implementation EsZoneManager
- (id) init {
	if (self = [super init]) {
		zonesById_ = [[NSMutableDictionary alloc] init];
		zonesByName_ = [[NSMutableDictionary alloc] init];
	}
	return self;
}

- (EsZone*) zoneByName:(NSString*) zoneName {
	return [zonesByName_ objectForKey:zoneName];
}

- (EsZone*) zoneById:(int) zoneId {
	return [zonesById_ objectForKey:[NSNumber numberWithInt:zoneId]];
}

- (NSArray*) zones {
	return [zonesById_ allValues];
}

///
/// Internal
///

- (void) addZone:(EsZone*) zone {
	[zonesById_ setObject:zone forKey:[NSNumber numberWithInt:zone.zoneId]];
	[zonesByName_ setObject:zone forKey:zone.name];
}

- (void) removeZone:(int) zoneId {
	EsZone* zone = [self zoneById:zoneId];
	if (zone != nil) {
		[zonesById_ removeObjectForKey:[NSNumber numberWithInt:zone.zoneId]];
		[zonesByName_ removeObjectForKey:zone.name];
	}
}

@end

