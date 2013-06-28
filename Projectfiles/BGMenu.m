//
//  BGMenu.m
//  DotAHero
//
//  Created by Killua Liu on 6/25/13.
//
//

#import "BGMenu.h"

@implementation BGMenu

- (id)init
{
    if (self = [super init]) {
        BGMenuFactory *menuFactory = [BGMenuFactory menuFactory];
        CCMenu *menu = [menuFactory createMenuWithSpriteFrameName:@"Menu.png"
                                                selectedFrameName:@"MenuSelected.png"
                                                disabledFrameName:nil];
        CGSize winSize = [[CCDirector sharedDirector] winSize];
        CGSize menuSize = [menu.children.lastObject contentSize];
        menu.position = ccp(winSize.width - menuSize.width*0.6, winSize.height - menuSize.height*0.9);
        [self addChild:menu];
        
        menuFactory.delegate = self;
    }
    
    return self;
}

+ (id)menu
{
    return [[self alloc] init];
}

#pragma mark - MenuFactory Delegate
- (void)menuItemTouched:(CCMenuItem *)menuItem
{
//  Add menus with Trust/Chat/ViewGame/Setting/ExitGame
}

@end
