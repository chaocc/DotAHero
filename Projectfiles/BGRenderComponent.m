//
//  BGRenderComponent.m
//  DotAHero
//
//  Created by Killua Liu on 5/30/13.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

#import "BGRenderComponent.h"


@implementation BGRenderComponent

- (id)initWithSpriteFrameName:(NSString *)spriteFrameName
{
    if (self = [super init]) {
        self.sprite = [CCSprite spriteWithSpriteFrameName:spriteFrameName];
        [self addChild:_sprite];
        
        [self scheduleUpdate];
    }
    return self;
}

- (id)initWithSpriteFrameName:(NSString *)spriteFrameName onParentNode:(CCNode *)parentNode
{
    [parentNode addChild:self];
    return self;
}

+ (id)renderWithSpriteFrameName:(NSString *)spriteFrameName
{
    return [[self alloc] initWithSpriteFrameName:spriteFrameName];
}

+ (id)renderWithSpriteFrameName:(NSString *)spriteFrameName onParentNode:(CCNode *)parentNode
{
    return [[self alloc] initWithSpriteFrameName:spriteFrameName onParentNode:parentNode];
}

- (void)update:(ccTime)delta
{
    
}

@end
