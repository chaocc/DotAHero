//
//  BGLoginLayer.h
//  DotAHero
//
//  Created by Killua Liu on 6/19/13.
//
//

#import "CCLayer.h"
#import "ElectroServer.h"
#import "BGPluginConstants.h"

@interface BGLoginLayer : CCLayer

@property (nonatomic, strong, readonly) ElectroServer *es;
@property (nonatomic, copy, readonly) NSString *userName;

+ (BGLoginLayer *)sharedLoginLayer;

@end
