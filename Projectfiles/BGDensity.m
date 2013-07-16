//
//  BGDensity.m
//  DotAHero
//
//  Created by Killua Liu on 6/11/13.
//
//

#import "BGDensity.h"
#import "BGFileConstants.h"

@implementation BGDensity

- (id)initWithDensityCardId:(NSInteger)cardId
{
    if (self = [super init]) {
        _densityCard = [BGDensityCard cardWithCardId:cardId];
        
        [self renderBackground];
    }
    return self;
}

+ (id)densityWithDensityCardId:(NSInteger)cardId
{
    return [[self alloc] initWithDensityCardId:cardId];
}

/*
 * Render game background according to different density task
 */
- (void)renderBackground
{
    CCSprite *sprite = [CCSprite spriteWithFile:kImageBackground];
    sprite.position = [CCDirector sharedDirector].screenCenter;
    [self addChild:sprite];
}

@end
