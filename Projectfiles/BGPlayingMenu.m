//
//  BGPlayingMenu.m
//  DotAHero
//
//  Created by Killua Liu on 7/1/13.
//
//

#import "BGPlayingMenu.h"
#import "BGPlayer.h"
#import "BGFileConstants.h"
#import "BGDefines.h"

@interface BGPlayingMenu ()

@property (nonatomic, weak) BGPlayer *player;

@end

@implementation BGPlayingMenu

- (id)initWithMenuType:(BGPlayingMenuType)menuType ofPlayer:(BGPlayer *)player
{
    if (self = [super init]) {
        _menuType = menuType;
        _player = player;
        
        [self addMenuItems];
    }
    return self;
}

+ (id)playingMenuWithMenuType:(BGPlayingMenuType)menuType ofPlayer:(BGPlayer *)player
{
    return [[self alloc] initWithMenuType:menuType ofPlayer:player];
}

- (void)addMenuItems
{
    switch (_menuType) {
        case kPlayingMenuTypeCardUsing:
            [self createPlayingMenuForUsing];
            break;
            
        case kPlayingMenuTypeCardPlaying:
            [self createPlayingMenuForPlaying];
            break;
            
        default:
            break;
    }
}

- (void)createPlayingMenuForUsing
{
    NSArray *spriteFrameNames = [NSArray arrayWithObjects:kImageOkay, kImageCancel, kImageDiscard, nil];
    NSArray *selFrameNames = [NSArray arrayWithObjects:kImageOkaySelected, kImageCancelSelected, kImageDiscardSelected, nil];
    NSArray *disFrameNames = [NSArray arrayWithObjects:kImageOkayDisabled, kImageCancelDisabled, kImageDiscardDisabled, nil];
    
    BGMenuFactory *menuFactory = [BGMenuFactory menuFactory];
    _menu = [menuFactory createMenuWithSpriteFrameNames:spriteFrameNames
                                            selectedFrameNames:selFrameNames
                                            disabledFrameNames:disFrameNames];
    _menu.position = ccp(SCREEN_WIDTH/2, SCREEN_HEIGHT*0.35);
    [_menu alignItemsHorizontallyWithPadding:20.0f];
    [self addChild:_menu];
    [[_menu.children objectAtIndex:kPlayingMenuItemTagOkay] setIsEnabled:NO]; // Okay menu is disabed initial
    
    menuFactory.delegate = self;
}

- (void)createPlayingMenuForPlaying
{
    NSArray *spriteFrameNames = [NSArray arrayWithObjects:kImageOkay, kImageCancel, nil];
    NSArray *selFrameNames = [NSArray arrayWithObjects:kImageOkaySelected, kImageCancelSelected, nil];
    NSArray *disFrameNames = [NSArray arrayWithObjects:kImageOkayDisabled, kImageCancelDisabled, nil];
    
    BGMenuFactory *menuFactory = [BGMenuFactory menuFactory];
    _menu = [menuFactory createMenuWithSpriteFrameNames:spriteFrameNames
                                     selectedFrameNames:selFrameNames
                                     disabledFrameNames:disFrameNames];
    _menu.position = ccp(SCREEN_WIDTH/2, SCREEN_HEIGHT*0.35);
    [_menu alignItemsHorizontallyWithPadding:40.0f];
    [self addChild:_menu];
    [[_menu.children objectAtIndex:kPlayingMenuItemTagOkay] setIsEnabled:NO]; // Okay menu is disabed initial
    
    menuFactory.delegate = self;
}

- (void)createOkayPlayingMenu
{
    BGMenuFactory *menuFactory = [BGMenuFactory menuFactory];
    _menu = [menuFactory createMenuWithSpriteFrameName:kImageOkay
                                     selectedFrameName:kImageOkaySelected
                                     disabledFrameName:kImageOkayDisabled];
    _menu.position = ccp(SCREEN_WIDTH/2, SCREEN_HEIGHT*0.35);
    [self addChild:_menu];
    [[_menu.children objectAtIndex:kPlayingMenuItemTagOkay] setIsEnabled:NO]; // Okay menu is disabed initial
    
    menuFactory.delegate = self;
}

#pragma mark - Menu Factory Delegate
- (void)menuItemTouched:(CCMenuItem *)menuItem
{
    switch (menuItem.tag) {
        case kPlayingMenuItemTagOkay:
//          ...TODO...
//          Send playing cards to server
            break;
            
        case kPlayingMenuItemTagDiscard:
            [_menu removeAllChildrenWithCleanup:YES];
            [self createOkayPlayingMenu];
            break;
            
        default:
            break;
    }
}


@end
