//
//  BGCharacterComponent.m
//  DotAHero
//
//  Created by Killua Liu on 5/30/13.
//
//

#import "BGHero.h"

@implementation BGHero

- (id)initWithHeroCards:(NSArray *)heroCards
{
    if (self = [super init]) {
        NSMutableArray *cardNames = [NSMutableArray array];
        for (NSNumber *heroId in heroCards) {
            BGHeroCardComponent *heroComponent = [BGHeroCardComponent heroCardComponentWithId:heroId.integerValue];
            [cardNames addObject:heroComponent.heroName];
        }
        
        BGMenuLayer *menuLayer = [BGMenuLayer menuLayerWithSpriteFrameNames:cardNames];
        menuLayer.menu.position = [CCDirector sharedDirector].screenCenter;
        [menuLayer.menu alignItemsHorizontally];
        [self addChild:menuLayer];
    }
    return self;
}

+ (id)heroWithHeroCards:(NSArray *)heroCards
{
    return [[self alloc] initWithHeroCards:heroCards];
}

- (void)useSkill
{
    
}

#pragma mark - MenuLayer Delegate
- (void)menuItemTouched:(CCMenuItem *)menuItem
{
    
}

@end
