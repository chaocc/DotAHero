//
//  EsQueuedMessage.h
//  cocoa-touch
//
//  Created by Jason von Nieda on 7/20/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "EsMessage.h"
#import "EsConnection.h"


@interface EsQueuedMessage : NSObject {

}

@property(strong) EsMessage* message;
@property(strong) EsConnection* connection;

- initWithMessage:(EsMessage*) message connection:(EsConnection*) connection;
@end
