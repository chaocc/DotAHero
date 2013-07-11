//
//  BGCheckComponent.h
//  DotAHero
//
//  Created by Killua Liu on 7/10/13.
//
//

#import <Foundation/Foundation.h>
#import "BGPlayer.h"

@interface BGCheckComponent : NSObject

@property (nonatomic, strong, readonly) BGPlayer *player;

- (id)initWithPlayer:(BGPlayer *)player;
+ (id)checkComponentWithPlayer:(BGPlayer *)player;

@end
