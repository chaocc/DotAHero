//
//  EsEngine.h
//  cocoa-touch
//
//  Created by Jason von Nieda on 7/20/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "EsEventDispatcher.h"
#import "EsServer.h"
#import "EsAvailableConnection.h"
#import "EsConnection.h"
#import "EsMessage.h"


@interface EsEngine : EsEventDispatcher {
	@private
	NSMutableArray* servers_;
	NSMutableDictionary* serversById_;
	NSMutableArray* activeConnections_;
	EsConnection* defaultConnection_;
	int connectionIds_;
	BOOL connected_;
	NSMutableArray* connectionsToAttempt_;
	NSUInteger connectionAttemptIndex_;
	NSMutableDictionary* connectionsById_;
	NSString* secret_;
	NSString* username_;
	NSInteger messageSizeCompressionThreshold_;
}
- (id) init;

/**
 * After this class is configured with available connections via the servers property or the addServer method, invoking this method will attempt to connect to ElectroServer. The connections attempted varies based on parameters.
 * The most common usage is to not pass in any parameters. In this usage (no paramters) connection attempts are made by cycling through all possible connections until one is established.
 * If the server parameter is non-null and the availableConnection parameter is null, then connections attempts are made by cycling through all possible connections associated only with the server specified.
 * If the server paramteer is non-null and the availableconnection parameter is non-null then a connection is attempted only with the availableConnection specified. This can be used to establish additional connections.
 * 
 * Every attempted connection results in a ConnectionAttemptResponse event.
 * When a connection finally succeeds or if all connection attempts fail a ConnectionResponse event is fired.
 * 
 * @param	Optional Server instance. This needs to have already been added to this class via the servers property or addServer method.
 * @param	Optional AvailableConnection instance. If non-null then the 'server' parameter must be non-null and this instance must have been added to it.
 */
- (void) connect;
- (void) connectToServer:(EsServer*) server;
- (void) connectToServer:(EsServer*) server withAvailableConnection:(EsAvailableConnection*) availableConnection;

/**
 * All connections that are attempted are locally assigned an id. This method returns the Connection instance associated with the id passed in.
 * @param	Id of the Connection you want to retrieve
 * @return Connection instance
 */
- (EsConnection*) connectionWithId:(int) connectionId;

/**
 * Adds a Server instance to the list of available servers. Servers should only be added through this method or by setting a new array of servers via the 'servers' property. 
 * @param	Server instance to add.
 */
- (void) addServer:(EsServer*) server;

/**
 * Removes a server from the list of available servers.
 * @param	Server to remove
 */
- (void) removeServer:(EsServer*) server;

/**
 * Closes all active connections resulting in EsConnectionClosedEvent events for each connection.
 */
- (void) close;
- (void) sendMessage:(EsMessage*) message;

/**
 * Sends a message to the server. This is the only way to communicate with the server. If no connection is specified then the default connection is used.
 * The default connection is the first connection established.
 * @param	The message to send to the server.
 * @param	The optional connection to use for sending to the server.
 */
- (void) sendMessage:(EsMessage*) message onConnection:(EsConnection*) connection;

/**
 * Gets a Server instance by id. The server must have been previously added via the addServer method or by setting an array of servers using the 'servers' property.
 * @param	Id of the Server instance to return
 * @return Server instance
 */
- (EsServer*) serverWithId:(NSString*) serverId;

/**
 * Configures this class with a list of servers that are available. The servers array should not be modified directly. Use the addServer and removeServer methods, or set the entire array of servers using this property.
 */
- (void) setServers:(NSArray*) servers;

- (NSArray*) servers;
- (BOOL) connected;
- (NSArray*) connectionsToAttempt;
- (int) connectionAttemptIndex;
- (NSArray*) activeConnections;

/**
 * Enables or disables message encryption for all active connections. 
 * The first time encryption is enabled for a connection
 * a key exchange will take place which may take several seconds. Encryption will be
 * automatically enabled once the key exchange completes. When encryption is successfully
 * enabled or disabled for a connection a EsEncryptionStateChangeEvent will be dispatched.
 * @param encryptionEnabled
 */
- (void) setEncryptionEnabled:(BOOL) encryptionEnabled;

/**
 * Enables or disables encryption for the specified Connection. See
 * setEncryptionEnabled(boolean) for further details.
 * @param encryptionEnabled
 * @param con
 */
- (void) setEncryptionEnabled:(BOOL) encryptionEnabled connection:(EsConnection*) connection;

/**
 * Returns the state of encryption for all active connections. If encryption
 * is enabled on all connections this returns true. If it is not enabled on any
 * connection this returns false.
 * @return
 */
- (BOOL) encryptionEnabled;

/**
 * Returns the state of encryption for the specified connection.
 * @return
 */
- (BOOL) encryptionEnabled:(EsConnection*) connection;

@property BOOL ignoreUnknownMessages;

// private
- (void) attemptNextConnection;
- (EsConnection*) newConnection:(EsAvailableConnection*) availableConnection;
- (void) pruneConnectionsToAttempt;
- (void) processMessage:(EsMessage*) message connection:(EsConnection*) connection;
- (void) preProcessMessage:(EsMessage*) message connection:(EsConnection*) connection server:(EsServer*) server;
- (void) cleanConnectionListeners:(EsConnection*) con;
- (void) checkMessageOrder:(EsMessage*) message connection:(EsConnection*) connection;
	
@end
