#import "EsSettingsLoader.h"
#import "EsSettingsXmlParser.h"
#import "DLOG.h"

@implementation EsSettingsLoader
- (NSArray*) readServerSettings {
	NSString* path = [[NSBundle mainBundle] pathForResource:@"settings" ofType:@"xml"];
	return [self readServerSettingsFromFilename:path];
}

- (NSArray*) readServerSettingsFromFilename:(NSString*) filename {
	DLOG(@"[Loading settings file from %@", filename);
	
	NSURL* url = [NSURL fileURLWithPath:filename];
	
	NSXMLParser* parser = [[NSXMLParser alloc] initWithContentsOfURL:url];
	
	EsSettingsXmlParser* settingsParser = [[EsSettingsXmlParser alloc] init];
	
	[parser setDelegate:settingsParser];
	[parser parse];
	
	NSArray* servers = [settingsParser servers];
	
	return servers;
}

- (void) dealloc {
	DLOG(@"dealloc");
}
@end
