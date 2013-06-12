//
//  EsAvailableConnection.h
//  cocoa-touch
//
//  Created by Jason von Nieda on 7/20/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface EsAvailableConnection : NSObject {

}

@property(strong) NSString* host;
@property int port;
@property int transportType;
@property(strong) NSString* serverId;

@end
