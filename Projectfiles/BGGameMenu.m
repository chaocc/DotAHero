//
//  BGMenu.m
//  DotAHero
//
//  Created by Killua Liu on 6/25/13.
//
//

#import "BGGameMenu.h"
#import "BGFileConstants.h"
#import "BGDefines.h"

@implementation BGGameMenu

- (id)init
{
    if (self = [super init]) {
        BGMenuFactory *menuFactory = [BGMenuFactory menuFactory];
        CCMenu *menu = [menuFactory createMenuWithSpriteFrameName:kImageGameMenu
                                                selectedFrameName:kImageGameMenuSelected
                                                disabledFrameName:nil];
        CGSize menuSize = [menu.children.lastObject contentSize];
        menu.position = ccp(SCREEN_WIDTH - menuSize.width*0.6, SCREEN_HEIGHT - menuSize.height*0.9);
        [self addChild:menu];
        
        menuFactory.delegate = self;
    }
    
    return self;
}

+ (id)menu
{
    return [[self alloc] init];
}

#pragma mark - Game menu delegate method
- (void)menuItemTouched:(CCMenuItem *)menuItem
{
//  ...TODO...
//  Add menus with Trust/Chat/ViewGame/Setting/ExitGame
}

@end
