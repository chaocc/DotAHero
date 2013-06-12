//
//  CryptoTools.h
//  cocoa-touch
//
//  Created by Jason von Nieda on 8/12/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface EsCryptoTools : NSObject {

}
+ (NSString*) generatePasswordHash:(NSString*) visiblePasssword hashId:(int) hashId;
@end
