//
//  BGClient.h
//  DotAHero
//
//  Created by Killua Liu on 7/11/13.
//
//

#import <Foundation/Foundation.h>
#import "ElectroServer.h"
#import "BGPluginConstants.h"

@interface BGClient : NSObject

@property (strong, nonatomic, readonly) ElectroServer *es;

+ (BGClient *)sharedClient;

- (void)conntectServer;
- (void)joinRoom;

@end
