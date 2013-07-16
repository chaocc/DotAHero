//
//  BGPlayingMenu.m
//  DotAHero
//
//  Created by Killua Liu on 7/1/13.
//
//

#import "BGPlayingMenu.h"
#import "BGClient.h"
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

#pragma mark - Playing menu items
/*
 * Add menu items according to different menu type
 */
- (void)addMenuItems
{
    switch (_menuType) {
        case kPlayingMenuTypeCardCutting:
            [self createOkayPlayingMenu];
            break;
            
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

/*
 * Create menu items with Okay/Cancel/Discard
 */
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

/*
 * Create menu items with Okay/Cancel
 */
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

/*
 * Create menu item with Okay
 */
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

#pragma mark - Menu item touching
/*
 * Menu delegate method is called while touching a item
 */
- (void)menuItemTouched:(CCMenuItem *)menuItem
{
    switch (menuItem.tag) {
        case kPlayingMenuItemTagOkay:
            [self touchOkayMenuItem];
            break;
            
        case kPlayingMenuItemTagDiscard:
            [_menu removeFromParentAndCleanup:YES];
            [self createOkayPlayingMenu];
            break;
            
        default:
            break;
    }
}

/*
 * Touch okay menu item. Call method according to different menu type.
 */
- (void)touchOkayMenuItem
{
    switch (_menuType) {
        case kPlayingMenuTypeCardCutting:
            [self cutCard];
            break;
            
        case kPlayingMenuTypeCardUsing:
            [self useCard];
            break;
            
        case kPlayingMenuTypeCardPlaying:
            
            break;
            
        default:
            break;
    }
}

- (void)cutCard
{
    [[BGClient sharedClient] sendCutCardRequestWithPlayingCardId:[_player.playingArea.selectedCards.lastObject cardId]];
    [_player.playingArea compareCardFigure];    // 通过拼点的方式切牌
//    [self removeFromParentAndCleanup:YES];
}

- (void)useCard
{
    [[BGClient sharedClient] sendUseCardRequestWithPlayingCardId:[_player.playingArea.selectedCards.lastObject cardId]];
    [_player.playingArea usePlayingCardsAndRunAnimation];
}

@end
