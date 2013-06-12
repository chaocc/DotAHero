//
//  EsTransportType.h
//  cocoa-touch
//
//  Created by Jason von Nieda on 7/20/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

enum {
	EsTransportType_BinaryTCP,
	EsTransportType_BinaryHTTP,
	EsTransportType_RTMP,
	EsTransportType_BinaryUDP,
};

@interface EsTransportType : NSObject {

}

@end
