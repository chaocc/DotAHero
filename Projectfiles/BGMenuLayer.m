//
//  BGMenuLayer.m
//  DotAHero
//
//  Created by Killua Liu on 6/11/13.
//
//

#import "BGMenuLayer.h"

@implementation BGMenuLayer

- (id)initWithSpriteFrameNames:(NSArray *)spriteFrameNames
{
    if (self = [super init]) {
        NSMutableArray *menuArray = [NSMutableArray array];
        
        for (NSString *spriteFrameName in spriteFrameNames) {
            NSString *spriteFileName = [NSString stringWithFormat:@"%@.png", spriteFrameName];
            CCSprite *normalSprite = [CCSprite spriteWithSpriteFrameName:spriteFileName];
            CCSprite *selectedSprite = [CCSprite spriteWithSpriteFrameName:spriteFileName];
            selectedSprite.color = ccGRAY;

            CCMenuItem *menuItem = [CCMenuItemSprite itemWithNormalSprite:normalSprite
                                                           selectedSprite:selectedSprite
                                                           disabledSprite:nil
                                                                    block:^(id sender) {
                                                                        [_delegate menuItemTouched:sender];
                                                                    }];
            [menuArray addObject:menuItem];
        }
        
        self.menu = [CCMenu menuWithArray:menuArray];
        [self addChild: _menu];
    }
    return self;
}

+ (id)menuLayerWithSpriteFrameNames:(NSArray *)spriteFrameNames
{
    return [[self alloc] initWithSpriteFrameNames:spriteFrameNames];
}

@end
