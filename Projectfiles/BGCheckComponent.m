//
//  BGCheckComponent.m
//  DotAHero
//
//  Created by Killua Liu on 7/10/13.
//
//

#import "BGCheckComponent.h"

@implementation BGCheckComponent

- (id)initWithPlayer:(BGPlayer *)player
{
    if (self = [super init]) {
        _player = player;
    }
    return self;
}

+ (id)checkComponentWithPlayer:(BGPlayer *)player
{
    return [[self alloc] initWithPlayer:player];
}

- (void)checkAttack:(id)object
{
    
}

@end
