#import "EsSettingsXmlParser.h"
#import "EsServer.h"
#import "EsTransportType.h"
#import "DLOG.h"

@implementation EsSettingsXmlParser

- (id) init {
	if (self = [super init]) {
		servers_ = [[NSMutableDictionary alloc] init];
	}
	return self;
}

- (NSArray*) servers {
	return [servers_ allValues];
}

- (void)parser:(NSXMLParser *)parser 
	didStartElement:(NSString *)elementName 
	namespaceURI:(NSString *)namespaceURI 
	qualifiedName:(NSString *)qualifiedName 
	attributes:(NSDictionary *)attributeDict {
	if ([elementName isEqualToString:@"connection"]) {
		NSString* serverId = [attributeDict objectForKey:@"serverId"];
		 NSString* ip = [attributeDict objectForKey:@"host"];
        if (NULL == ip) [attributeDict objectForKey:@"ip"];
		NSString* port = [attributeDict objectForKey:@"port"];
		NSString* transport = [attributeDict objectForKey:@"transport"];
		
		EsServer* server = [servers_ objectForKey:serverId];
		if (server == nil) {
			server = [[EsServer alloc] initWithServerId:serverId];
			[servers_ setObject:server forKey:serverId];
		}
		
		EsAvailableConnection* availableConnection = [[EsAvailableConnection alloc] init];
		availableConnection.host = ip;
		availableConnection.port = [port intValue];
		availableConnection.transportType = [self transportTypeForIdentifier:transport];
		[server addAvailableConnection:availableConnection];
	}
}

- (int) transportTypeForIdentifier:(NSString*) transportTypeIdentifier {
	transportTypeIdentifier = [transportTypeIdentifier uppercaseString];
	if ([transportTypeIdentifier isEqualToString:@"BINARYTCP"]) {
		return EsTransportType_BinaryTCP;
	}
	else if ([transportTypeIdentifier isEqualToString:@"BINARYHTTP"]) {
		return EsTransportType_BinaryHTTP;
	}
	else if ([transportTypeIdentifier isEqualToString:@"RTMP"]) {
		return EsTransportType_RTMP;
	}
	else if ([transportTypeIdentifier isEqualToString:@"BINARYUDP"]) {
		return EsTransportType_BinaryUDP;
	}
	return -1;
}

- (void)parser:(NSXMLParser *)parser 
	didEndElement:(NSString *)elementName 
	namespaceURI:(NSString *)namespaceURI 
	qualifiedName:(NSString *)qName {
	
}

- (void) dealloc {
	DLOG(@"dealloc");
}

@end
