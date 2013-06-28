//
//  BGMenuFactory.m
//  DotAHero
//
//  Created by Killua Liu on 6/25/13.
//
//

#import "BGMenuFactory.h"

@implementation BGMenuFactory

+ (id)menuFactory
{
	return [[self alloc] init];
}

- (id)createMenuWithSpriteFrameName:(NSString *)frameName selectedFrameName:(NSString *)selectedFrameName disabledFrameName:(NSString *)disabledFrameName
{
    CCSprite *normalSprite = [CCSprite spriteWithSpriteFrameName:frameName];
    CCSprite *selectedSprite = nil;
    CCSprite *disabledSprite = nil;
    if (selectedFrameName) {
        selectedSprite = [CCSprite spriteWithSpriteFrameName:selectedFrameName];
    }
    if (disabledFrameName) {
        disabledSprite = [CCSprite spriteWithSpriteFrameName:disabledFrameName];
    }
    
    CCMenuItem *menuItem = [CCMenuItemSprite itemWithNormalSprite:normalSprite
                                                   selectedSprite:selectedSprite
                                                   disabledSprite:disabledSprite
                                                            block:^(id sender) {
                                                                [_delegate menuItemTouched:sender];
                                                            }];
    return [CCMenu menuWithItems:menuItem, nil];
}

- (id)createMenuWithSpriteFrameNames:(NSArray *)frameNames
{
    NSMutableArray *menuArray = [NSMutableArray array];
    [frameNames enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        NSString *spriteFile = [NSString stringWithFormat:@"%@.png", obj];
        CCSprite *normalSprite = [CCSprite spriteWithSpriteFrameName:spriteFile];
        CCSprite *selectedSprite = [CCSprite spriteWithSpriteFrameName:spriteFile];
        selectedSprite.color = ccGRAY;
        
        CCMenuItem *menuItem = [CCMenuItemSprite itemWithNormalSprite:normalSprite
                                                       selectedSprite:selectedSprite
                                                       disabledSprite:nil
                                                                block:^(id sender) {
                                                                    [_delegate menuItemTouched:sender];
                                                                }];
        [menuArray addObject:menuItem];
    }];
    
    return [CCMenu menuWithArray:menuArray];
}

- (id)createMenuWithSpriteFrameNames:(NSArray *)spriteFrameNames ofObjects:(NSArray *)objects
{
    NSMutableArray *menuArray = [NSMutableArray array];
    [spriteFrameNames enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        NSString *spriteFileName = [NSString stringWithFormat:@"%@.png", obj];
        CCSprite *normalSprite = [CCSprite spriteWithSpriteFrameName:spriteFileName];
        CCSprite *selectedSprite = [CCSprite spriteWithSpriteFrameName:spriteFileName];
        selectedSprite.color = ccGRAY;
        
        CCMenuItem *menuItem = [CCMenuItemSprite itemWithNormalSprite:normalSprite
                                                       selectedSprite:selectedSprite
                                                       disabledSprite:nil
                                                                block:^(id sender) {
                                                                    [_delegate menuItemTouched:sender];
                                                                }];
        menuItem.tag = [objects[idx] integerValue];
        [menuArray addObject:menuItem];
    }];
    
    return [CCMenu menuWithArray:menuArray];
}

@end
