//
//  BGRenderComponent.h
//  DotAHero
//
//  Created by Killua Liu on 5/30/13.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "BGComponent.h"

@interface BGRenderComponent : BGComponent

@property(nonatomic, strong) CCSprite *sprite;

- (id)initWithSpriteFrameName:(NSString *)spriteFrameName;
- (id)initWithSpriteFrameName:(NSString *)spriteFrameName onParentNode:(CCNode *)parentNode;

+ (id)renderWithSpriteFrameName:(NSString *)spriteFrameName;
+ (id)renderWithSpriteFrameName:(NSString *)spriteFrameName onParentNode:(CCNode *)parentNode;

@end