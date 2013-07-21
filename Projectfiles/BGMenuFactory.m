//
//  BGMenuFactory.m
//  DotAHero
//
//  Created by Killua Liu on 6/25/13.
//
//

#import "BGMenuFactory.h"
#import "BGCard.h"

@implementation BGMenuFactory

+ (id)menuFactory
{
	return [[self alloc] init];
}

- (id)createEmptyMenu
{
    return [CCMenu menuWithItems:nil];
}

- (id)createMenuWithSpriteFrameName:(NSString *)frameName
                  selectedFrameName:(NSString *)selFrameName
                  disabledFrameName:(NSString *)disFrameName
{
    CCSprite *normalSprite = [CCSprite spriteWithSpriteFrameName:frameName];
    CCSprite *selectedSprite = nil;
    CCSprite *disabledSprite = nil;
    if (selFrameName) {
        selectedSprite = [CCSprite spriteWithSpriteFrameName:selFrameName];
    }
    if (disFrameName) {
        disabledSprite = [CCSprite spriteWithSpriteFrameName:disFrameName];
    }
    
    CCMenuItem *menuItem = [CCMenuItemSprite itemWithNormalSprite:normalSprite
                                                   selectedSprite:selectedSprite
                                                   disabledSprite:disabledSprite
                                                            block:^(id sender) {
                                                                [_delegate menuItemTouched:sender];
                                                            }];
    menuItem.tag = 0;
    return [CCMenu menuWithItems:menuItem, nil];
}

- (id)createMenuWithSpriteFrameNames:(NSArray *)frameNames
                  selectedFrameNames:(NSArray *)selFrameNames
                  disabledFrameNames:(NSArray *)disFrameNames
{
    NSMutableArray *menuArray = [NSMutableArray array];
    [frameNames enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        CCSprite *normalSprite = [CCSprite spriteWithSpriteFrameName:obj];
        CCSprite *selectedSprite = nil;
        CCSprite *disabledSprite = nil;
        
        @try {
            if (selFrameNames) {
                selectedSprite = [CCSprite spriteWithSpriteFrameName:selFrameNames[idx]];
            }
            if (selFrameNames) {
                disabledSprite = [CCSprite spriteWithSpriteFrameName:disFrameNames[idx]];
            }
        }
        @catch (NSException *exception) {
            NSLog(@"Exception: %@ in selector %@", exception.description, NSStringFromSelector(_cmd));
        }
        
        CCMenuItem *menuItem = [CCMenuItemSprite itemWithNormalSprite:normalSprite
                                                       selectedSprite:selectedSprite
                                                       disabledSprite:disabledSprite
                                                                block:^(id sender) {
                                                                    [_delegate menuItemTouched:sender];
                                                                }];
        menuItem.tag = idx;
        [menuArray addObject:menuItem];
    }];
    
    return [CCMenu menuWithArray:menuArray];
}

- (id)createMenuWithCards:(NSArray *)cards
{
    NSMutableArray *menuArray = [NSMutableArray array];
    [cards enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        NSAssert([obj isKindOfClass:[BGCard class]], @"Not a BGCard in %@", NSStringFromSelector(_cmd));
        
        CCSprite *normalSprite = [CCSprite spriteWithSpriteFrameName:[obj cardImageName]];
        CCSprite *selectedSprite = [CCSprite spriteWithSpriteFrameName:[obj cardImageName]];
        selectedSprite.color = ccGRAY;
        
        CCMenuItem *menuItem = [CCMenuItemSprite itemWithNormalSprite:normalSprite
                                                       selectedSprite:selectedSprite
                                                       disabledSprite:nil
                                                                block:^(id sender) {
                                                                    [_delegate menuItemTouched:sender];
                                                                }];
        menuItem.tag = [obj cardId];
        [menuArray addObject:menuItem];
    }];
    
    return [CCMenu menuWithArray:menuArray];
}

- (void)addMenuItemsWithCards:(NSArray *)cards toMenu:(CCMenu *)menu
{
    [cards enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        NSAssert([obj isKindOfClass:[BGCard class]], @"Not a BGCard in %@", NSStringFromSelector(_cmd));
        CCSprite *normalSprite = [CCSprite spriteWithSpriteFrameName:[obj cardImageName]];
        CCSprite *selectedSprite = [CCSprite spriteWithSpriteFrameName:[obj cardImageName]];
        selectedSprite.color = ccGRAY;
        
        CCMenuItem *menuItem = [CCMenuItemSprite itemWithNormalSprite:normalSprite
                                                       selectedSprite:selectedSprite
                                                       disabledSprite:nil
                                                                block:^(id sender) {
                                                                    [_delegate menuItemTouched:sender];
                                                                }];
        menuItem.tag = [obj cardId];
        [menu addChild:menuItem z:menu.children.count];
    }];
}

- (void)addMenuItemWithCardBackFrameName:(NSString *)frameName toMenu:(CCMenu *)menu
{
    CCSprite *normalSprite = [CCSprite spriteWithSpriteFrameName:frameName];
    CCMenuItem *menuItem = [CCMenuItemSprite itemWithNormalSprite:normalSprite
                                                   selectedSprite:nil
                                                   disabledSprite:nil
                                                            block:NULL];
    menuItem.isEnabled = NO;
    [menu addChild:menuItem z:menu.children.count];
}

@end
