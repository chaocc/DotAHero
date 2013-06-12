/*
 * Kobold2D™ --- http://www.kobold2d.org
 *
 * Copyright (c) 2010-2011 Steffen Itterheim. 
 * Released under MIT License in Germany (LICENSE-Kobold2D.txt).
 */

#import "DotaHeroLayer.h"
#import "BGObjectManager.h"
#import "BGObjectFactory.h"
#import "BGObject.h"

@interface DotaHeroLayer (PrivateMethods)
@end

@implementation DotaHeroLayer

-(id) init
{
	if ((self = [super init]))
	{
		glClearColor(0.1f, 0.1f, 0.3f, 1.0f);
        [CCTexture2D PVRImagesHavePremultipliedAlpha:YES];
        
        CCSpriteFrameCache *spriteFrameCache = [CCSpriteFrameCache sharedSpriteFrameCache];
        [spriteFrameCache addSpriteFramesWithFile:@"test.plist"];
        
        NSArray *characters = [NSArray arrayWithObjects:@(2), @(5), @(10), @(11), nil];
        BGObjectFactory *objectFactory = [BGObjectFactory objectFactoryWithObjectManager:[BGObjectManager sharedObjectManager]];
        BGObject *humanPlayer = [objectFactory createHumanPlayer:characters];
        [self addChild:humanPlayer];
	}

	return self;
}

@end
