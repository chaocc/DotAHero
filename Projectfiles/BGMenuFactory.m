//
//  BGMenuFactory.m
//  DotAHero
//
//  Created by Killua Liu on 6/25/13.
//
//

#import "BGMenuFactory.h"
#import "BGPlayingCard.h"
#import "BGDefines.h"

@implementation BGMenuFactory

+ (id)menuFactory
{
	return [[self alloc] init];
}

#pragma mark - Create menu
- (CCMenu *)createMenuWithSpriteFrameName:(NSString *)frameName
{
    return [CCMenu menuWithItems:[self createMenuItemWithSpriteFrameName:frameName], nil];
}

- (CCMenu *)createMenuWithSpriteFrameNames:(NSArray *)frameNames
{
    NSMutableArray *menuItems = [NSMutableArray array];
    [frameNames enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        CCMenuItem *menuItem = [self createMenuItemWithSpriteFrameName:obj];
        menuItem.tag = idx;
        [menuItems addObject:menuItem];
    }];
    
    return [CCMenu menuWithArray:menuItems];
}

- (CCMenu *)createMenuWithSpriteFrameName:(NSString *)frameName
                        selectedFrameName:(NSString *)selFrameName
                        disabledFrameName:(NSString *)disFrameName
{
    CCMenuItem *menuItem = [self createMenuItemWithSpriteFrameName:frameName
                                                 selectedFrameName:selFrameName
                                                 disabledFrameName:disFrameName];
    return [CCMenu menuWithItems:menuItem, nil];
}

- (CCMenu *)createMenuWithSpriteFrameNames:(NSArray *)frameNames
                        selectedFrameNames:(NSArray *)selFrameNames
                        disabledFrameNames:(NSArray *)disFrameNames
{
    NSMutableArray *menuItems = [NSMutableArray array];
    [frameNames enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        CCMenuItem *menuItem = [self createMenuItemWithSpriteFrameName:obj
                                                     selectedFrameName:selFrameNames[idx]
                                                     disabledFrameName:disFrameNames[idx]];
        menuItem.tag = idx;
        [menuItems addObject:menuItem];
    }];
    
    return [CCMenu menuWithArray:menuItems];
}

- (CCMenu *)createMenuWithCards:(NSArray *)cards
{
    NSMutableArray *menuItems = [NSMutableArray array];
    [cards enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        NSAssert([obj isKindOfClass:[BGCard class]], @"Not a BGCard in %@", NSStringFromSelector(_cmd));
        [menuItems addObject:[self createMenuItemWithPlayingCard:obj]];
    }];
    
    return [CCMenu menuWithArray:menuItems];
}

#pragma mark - Create menu item
- (CCMenuItem *)createMenuItemWithSpriteFrameName:(NSString *)frameName
{
    CCSprite *normalSprite = [CCSprite spriteWithSpriteFrameName:frameName];
    CCSprite *selectedSprite = [CCSprite spriteWithSpriteFrameName:frameName];
    selectedSprite.color = ccGRAY;
    
    return [CCMenuItemSprite itemWithNormalSprite:normalSprite
                                   selectedSprite:selectedSprite
                                            block:^(id sender) {
                                                [_delegate menuItemTouched:sender];
                                            }];
}

- (CCMenuItem *)createMenuItemWithSpriteFrameName:(NSString *)frameName
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
    
    return [CCMenuItemSprite itemWithNormalSprite:normalSprite
                                   selectedSprite:selectedSprite
                                   disabledSprite:disabledSprite
                                            block:^(id sender) {
                                                [_delegate menuItemTouched:sender];
                                            }];
}

- (CCMenuItem *)createMenuItemWithPlayingCard:(id)card
{
    CCSprite *normalSprite = [CCSprite spriteWithSpriteFrameName:[card cardImageName]];
    
    CCMenuItem *menuItem = [CCMenuItemSprite itemWithNormalSprite:normalSprite
                                                   selectedSprite:nil
                                                   disabledSprite:nil
                                                            block:^(id sender) {
                                                                [_delegate menuItemTouched:sender];
                                                            }];
    menuItem.tag =[card cardId];
    
//  Render playing card figure and suits
    if ([card isPlayingCard]) {
        CCSprite *figure = [CCSprite spriteWithSpriteFrameName:[card figureImageName]];
        figure.position = ccp(PLAYING_CARD_WIDTH*0.11, PLAYING_CARD_HEIGHT*0.92);
        [menuItem addChild:figure];
        
        CCSprite *suits = [CCSprite spriteWithSpriteFrameName:[card suitsImageName]];
        suits.position = ccp(PLAYING_CARD_WIDTH*0.11, PLAYING_CARD_HEIGHT*0.84);
        [menuItem addChild:suits];
    }
    
    return menuItem;
}

- (NSArray *)createMenuItemsWithCards:(NSArray *)cards
{
    NSMutableArray *menuItems = [NSMutableArray array];
    [cards enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        NSAssert([obj isKindOfClass:[BGCard class]], @"Not a BGCard in %@", NSStringFromSelector(_cmd));
        [menuItems addObject:[self createMenuItemWithPlayingCard:obj]];
    }];
    
    return menuItems;
}

- (NSArray *)createMenuitemsWithSpriteFrameNames:(NSArray *)frameNames
{
    NSMutableArray *menuItems = [NSMutableArray array];
    [frameNames enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        [menuItems addObject:[self createMenuItemWithSpriteFrameName:obj]];
    }];
    
    return menuItems;
}

#pragma mark - Add menu items
- (void)addMenuItemsWithCards:(NSArray *)cards toMenu:(CCMenu *)menu
{
    [cards enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        NSAssert([obj isKindOfClass:[BGCard class]], @"Not a BGCard in %@", NSStringFromSelector(_cmd));
        [menu addChild:[self createMenuItemWithPlayingCard:obj] z:menu.children.count];
    }];
}

- (void)addMenuItemsWithSpriteFrameNames:(NSArray *)frameNames toMenu:(CCMenu *)menu
{
    [frameNames enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        [menu addChild:[self createMenuItemWithSpriteFrameName:obj] z:menu.children.count];
    }];
}

- (void)addMenuItemWithSpriteFrameName:(NSString *)frameName isEnabled:(BOOL)isEnabled toMenu:(CCMenu *)menu
{
    CCMenuItem *menuItem = [self createMenuItemWithSpriteFrameName:frameName];
    menuItem.isEnabled = isEnabled;
    [menu addChild:menuItem z:menu.children.count];
}

@end
