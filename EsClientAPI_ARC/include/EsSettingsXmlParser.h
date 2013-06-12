#import <Foundation/Foundation.h>


/**
 * This class is a utility used to parse a standard formatted server settings file. Here is an example of formatted XML:
 <pre>
 <settings>
 <connection ip="somesite.com" port="9899" transport="socket" serverId="server1" />
 <connection ip="somesite.com" port="8787" transport="rtmp" serverId="server1" />
 <connection ip="somesite.com" port="8989" transport="http" serverId="server1" />
 </settings>
 </pre>
 */
@interface EsSettingsXmlParser : NSObject <NSXMLParserDelegate> {
	NSMutableDictionary* servers_;
}

- (NSArray*) servers;

- (int) transportTypeForIdentifier:(NSString*) transportTypeIdentifier;
@end
