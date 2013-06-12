//
//  EsMessageTranslator.h
//  cocoa-touch
//
//  Created by Jason von Nieda on 7/20/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "EsMessage.h"


@interface EsMessageTranslator : NSObject {

}
+ (EsMessage*) esMessageFromInputStream:(NSInputStream*) inputStream;
+ (NSData*) dataFromEsMessage:(EsMessage*) esMessage outboundId:(int) outboundId;
@end
