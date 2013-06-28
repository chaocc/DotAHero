//
//  BGLoginLayer.h
//  DotAHero
//
//  Created by Killua Liu on 6/19/13.
//
//

#import "CCLayer.h"
#import "ElectroServer.h"

@interface BGLoginLayer : CCLayer

@property (strong, nonatomic) ElectroServer *es;

+ (BGLoginLayer *)sharedLoginScene;

@end
