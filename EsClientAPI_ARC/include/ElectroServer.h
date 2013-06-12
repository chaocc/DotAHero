#import <Foundation/Foundation.h>
#import "EsEngine.h"
#import "EsSettingsLoader.h"
#import "EsManagerHelper.h"
#import "EsConnectionClosedEvent.h"
#import "EsApi.h"
#import "EsTransportType.h"

/**
 * This class is used as an entry point for a 2nd level convenient API. 
 * It keeps track of an ESEngine instance, used to manage
 * connections, send/receive messages, and dispatch message events. 
 * It also stores an instance of ManagerHelper which gives you
 * access to the UserManager and ZoneManager. Users, zones, rooms, user 
 * variables, room variables, buddies and their statuses are
 * all managed there. This class also gives you a simple option for connecting 
 * to ElectroServer through the loadAndConnect method.
 */
@interface ElectroServer : NSObject {
	@private
	EsEngine* engine_;
	EsSettingsLoader* settingsLoader_;
	EsManagerHelper* managerHelper_;
}

/**
 * Gets the ESEngine instance. This is used for sending/receiving messages, managing connections, and dispatching client-bound message events.
 */
@property(readonly) EsEngine* engine;

/**
 * Gets the SettingsLoader object used for loading the settings XML file
 */
@property(readonly) EsSettingsLoader* settingsLoader;

/**
 * Gets the ManagerHelper instance for accessing the managed lists of zones, rooms, users, buddies, user variables, and room variables
 */
@property(readonly) EsManagerHelper* managerHelper;

/**
 * Called when a connection is closed. If no primary connections remain then refresh the managerHelper.
 * @param	ConnectionClosedEvent object
 * @private
 */
- (void) onConnectionClosedEvent:(EsConnectionClosedEvent*) e;

/**
 * Use this method to load an XML file that contains connection information. Once loaded a connection to ElectroServer is
 * automatically attempted by cycling through all possible connections until one is established. If you want to listen for 
 * load complete or failures of the XML file, then you can do so by adding the event listeners directly to _es.settingsLoader.
 * If successfully loaded and connections are being attempted, then you will receive the ConnectionResponse and ConnectionAttemptResponse
 * events.
 * @param	Path to XML file to be loaded.
 <pre>
 <settings>
 <connection ip="somesite.com" port="9899" transport="socket" serverId="server1" />
 <connection ip="somesite.com" port="8787" transport="rtmp" serverId="server1" />
 <connection ip="somesite.com" port="8989" transport="http" serverId="server1" />
 </settings>
 </pre>
 */
- (void) loadAndConnect:(NSString*) path;

- (void) loadAndConnect;
@end
