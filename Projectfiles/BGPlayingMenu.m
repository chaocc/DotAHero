//
//  BGPlayingMenu.m
//  DotAHero
//
//  Created by Killua Liu on 7/1/13.
//
//

#import "BGPlayingMenu.h"
#import "BGClient.h"
#import "BGGameLayer.h"
#import "BGFileConstants.h"
#import "BGDefines.h"
#import "BGActionComponent.h"
#import "BGAudioComponent.h"

@interface BGPlayingMenu ()

@property (nonatomic, weak) BGGameLayer *gameLayer;
@property (nonatomic, weak) BGPlayer *player;

@property (nonatomic, strong) CCMenu *menu;
@property (nonatomic) BOOL isEnabled;

@end

@implementation BGPlayingMenu

- (id)initWithMenuType:(BGPlayingMenuType)menuType
{
    if (self = [super init]) {
        _menuType = menuType;
        _gameLayer = [BGGameLayer sharedGameLayer];
        _player = _gameLayer.selfPlayer;
        
        _menuFactory = [BGMenuFactory menuFactory];
        _menuFactory.delegate = self;
        
        [self createMenu];
    }
    return self;
}

- (id)initWithMenuType:(BGPlayingMenuType)menuType isEnabled:(BOOL)isEnabled
{
    _isEnabled = isEnabled;
    return [self initWithMenuType:menuType];
}

+ (id)playingMenuWithMenuType:(BGPlayingMenuType)menuType
{
    return [[self alloc] initWithMenuType:menuType];
}

+ (id)playingMenuWithMenuType:(BGPlayingMenuType)menuType isEnabled:(BOOL)isEnabled
{
    return [[self alloc] initWithMenuType:menuType isEnabled:isEnabled];
}

- (NSUInteger)menuItemCount
{
    return _menu.children.count;
}

- (void)setMenuPosition:(CGPoint)menuPosition
{
    _menu.position = menuPosition;
}

- (CCMenuItem *)menuItemByTag:(NSInteger)tag
{
    return (CCMenuItem *)[_menu getChildByTag:tag];
}

#pragma mark - Playing menu creation
/*
 * Create menu according to different menu type
 */
- (void)createMenu
{
    switch (_menuType) {
        case kPlayingMenuTypeOkay:
            [self createPlayingMenuForOkay];
            break;
            
        case kPlayingMenuTypePlaying:
            [self createPlayingMenuForPlaying];
            break;
            
        case kPlayingMenuTypeChoosing:
            [self createPlayingMenuForChoosing];
            break;
            
        case kPlayingMenuTypeStrengthening:
            [self createPlayingMenuForStrengthening];
            break;
            
        case kPlayingMenuTypeDispelling:
            [self createPlayingMenuForDispelling];
            break;
            
        case kPlayingMenuTypeCardColor:
            [self createPlayingMenuForCardColor];
            break;
            
        case kPlayingMenuTypeCardSuits:
            [self createPlayingMenuForCardSuits];
            break;
            
        default:
            break;
    }
    
    _menu.position = POSITION_PLAYING_MENU;
}

/*
 * Create menu item with Okay
 */
- (void)createPlayingMenuForOkay
{
    _menu = [_menuFactory createMenuWithSpriteFrameName:kImageOkay
                                      selectedFrameName:kImageOkaySelected
                                      disabledFrameName:kImageOkayDisabled];
    CCMenuItem *menuItem = [_menu.children objectAtIndex:0];
    menuItem.tag = kPlayingMenuItemTagOkay;
    menuItem.isEnabled = _isEnabled;
    
    [self addChild:_menu];
}

/*
 * Create menu items with Okay/Discard
 */
- (void)createPlayingMenuForPlaying
{
    NSArray *spriteFrameNames = [NSArray arrayWithObjects:kImageOkay, kImageDiscard, nil];
    NSArray *selFrameNames = [NSArray arrayWithObjects:kImageOkaySelected, kImageDiscardSelected, nil];
    NSArray *disFrameNames = [NSArray arrayWithObjects:kImageOkayDisabled, kImageDiscardDisabled, nil];
    
    _menu = [_menuFactory createMenuWithSpriteFrameNames:spriteFrameNames
                                      selectedFrameNames:selFrameNames
                                      disabledFrameNames:disFrameNames];
    [_menu alignItemsHorizontallyWithPadding:PADDING_TWO_BUTTONS];
    
    [[_menu.children getNSArray] enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        if (0 == idx) {
            [obj setTag:kPlayingMenuItemTagOkay];
            [obj setIsEnabled:NO];  // Disable okay menu
        } else if (1 == idx) {
            [obj setTag:kPlayingMenuItemTagDiscard];
        }
    }];
    
    [self addChild:_menu];
}

/*
 * Create menu items with Okay/Cancel - Choosing
 */
- (void)createPlayingMenuForChoosing
{
    NSArray *spriteFrameNames = [NSArray arrayWithObjects:kImageOkay, kImageCancel, nil];
    NSArray *selFrameNames = [NSArray arrayWithObjects:kImageOkaySelected, kImageCancelSelected, nil];
    NSArray *disFrameNames = [NSArray arrayWithObjects:kImageOkayDisabled, kImageCancelDisabled, nil];
    
    _menu = [_menuFactory createMenuWithSpriteFrameNames:spriteFrameNames
                                      selectedFrameNames:selFrameNames
                                      disabledFrameNames:disFrameNames];
    [_menu alignItemsHorizontallyWithPadding:PADDING_TWO_BUTTONS];
    
    [[_menu.children getNSArray] enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        if (0 == idx) {
            [obj setTag:kPlayingMenuItemTagOkay];
            [obj setIsEnabled:NO];  // Disable okay menu
        } else if (1 == idx) {
            [obj setTag:kPlayingMenuItemTagCancel];
        }
    }];
    
    [self addChild:_menu];
}

/*
 * Create menu items with Okay/Strengthen/Discard
 */
- (void)createPlayingMenuForStrengthening
{
    NSArray *spriteFrameNames = [NSArray arrayWithObjects:kImageOkay, kImageStrengthen, kImageDiscard, nil];
    NSArray *selFrameNames = [NSArray arrayWithObjects:kImageOkaySelected, kImageStrengthenSelected, kImageDiscardSelected, nil];
    NSArray *disFrameNames = [NSArray arrayWithObjects:kImageOkayDisabled, kImageStrengthenDisabled, kImageDiscardDisabled, nil];
    
    _menu = [_menuFactory createMenuWithSpriteFrameNames:spriteFrameNames
                                      selectedFrameNames:selFrameNames
                                      disabledFrameNames:disFrameNames];
    [_menu alignItemsHorizontallyWithPadding:PADDING_THREE_BUTTONS];
    
    [[_menu.children getNSArray] enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        if (0 == idx) {
            [obj setTag:kPlayingMenuItemTagOkay];
            [obj setIsEnabled:NO];  // Disable okay menu
        } else if (1 == idx) {
            [obj setTag:kPlayingMenuItemTagStrengthen];
            [obj setIsEnabled:NO];  // Disable strengthen menu
        } else if (2 == idx) {
            [obj setTag:kPlayingMenuItemTagDiscard];
        }
    }];
    
    [self addChild:_menu];
}

/*
 * Create menu items with Okay/Discard/IgnoreDispel
 */
- (void)createPlayingMenuForDispelling
{
    NSArray *spriteFrameNames = [NSArray arrayWithObjects:kImageOkay, kImageDiscard, nil];
    NSArray *selFrameNames = [NSArray arrayWithObjects:kImageOkaySelected, kImageDiscardSelected, nil];
    NSArray *disFrameNames = [NSArray arrayWithObjects:kImageOkayDisabled, kImageDiscardDisabled, nil];
    
    _menu = [_menuFactory createMenuWithSpriteFrameNames:spriteFrameNames
                                      selectedFrameNames:selFrameNames
                                      disabledFrameNames:disFrameNames];
    [_menu alignItemsHorizontallyWithPadding:PADDING_THREE_BUTTONS];
    
    [[_menu.children getNSArray] enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        if (0 == idx) {
            [obj setTag:kPlayingMenuItemTagOkay];
            [obj setIsEnabled:NO];  // Disable okay menu
        } else if (1 == idx) {
            [obj setTag:kPlayingMenuItemTagStrengthen];
        } else if (2 == idx) {
            [obj setTag:kPlayingMenuItemTagDiscard];
        }
    }];
    
    [self addChild:_menu];
}

/*
 * Create menu item with Red/Black Color
 */
- (void)createPlayingMenuForCardColor
{
    NSArray *spriteFrameNames = [NSArray arrayWithObjects:kImageMenuRed, kImageMenuBlack, nil];
    NSArray *selFrameNames = [NSArray arrayWithObjects:kImageMenuRedSelected, kImageMenuBlackSelected, nil];
    
    _menu = [_menuFactory createMenuWithSpriteFrameNames:spriteFrameNames
                                      selectedFrameNames:selFrameNames
                                      disabledFrameNames:nil];
    [_menu alignItemsHorizontallyWithPadding:PADDING_TWO_BUTTONS];
    
    [[_menu.children getNSArray] enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        if (0 == idx) {
            [obj setTag:kPlayingMenuItemTagRedColor];
        } else if (1 == idx) {
            [obj setTag:kPlayingMenuItemTagBlackColor];
        }
    }];
    
    [self addChild:_menu];
}
//
/*
 * Create menu item with Hearts/Diamonds/Spades/Clubs
 */
- (void)createPlayingMenuForCardSuits
{
    NSArray *spriteFrameNames = [NSArray arrayWithObjects:kImageMenuSpades, kImageMenuHearts, kImageMenuClubs, kImageMenuDiamonds, nil];
    NSArray *selFrameNames = [NSArray arrayWithObjects:kImageMenuSpadesSelected, kImageMenuHeartsSelected, kImageMenuClubsSelected, kImageMenuDiamondsSelected, nil];
    
    _menu = [_menuFactory createMenuWithSpriteFrameNames:spriteFrameNames
                                      selectedFrameNames:selFrameNames
                                      disabledFrameNames:nil];
    [_menu alignItemsHorizontallyWithPadding:PADDING_SUITS_BUTTON];
    
    [[_menu.children getNSArray] enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        if (0 == idx) {
            [obj setTag:kPlayingMenuItemTagSpades];
        } else if (1 == idx) {
            [obj setTag:kPlayingMenuItemTagHearts];
        } else if (2 == idx) {
            [obj setTag:kPlayingMenuItemTagClubs];
        } else if (3 == idx) {
            [obj setTag:kPlayingMenuItemTagDiamonds];
        }
    }];
    
    [self addChild:_menu];
}

#pragma mark - Menu item touching
/*
 * Menu delegate method is called while touching a item
 */
- (void)menuItemTouched:(CCMenuItem *)menuItem
{
    menuItem.visible = NO;
    [[BGAudioComponent sharedAudioComponent] playButtonClick];
    
    if (_delegate) {
        [_delegate playingMenuItemTouched:menuItem];
        return;
    }
    
    switch (menuItem.tag) {
        case kPlayingMenuItemTagOkay:
            [self touchOkayMenuItem];
            break;
            
        case kPlayingMenuItemTagCancel:
            [[BGClient sharedClient] sendCancelRequest];
            break;
            
        case kPlayingMenuItemTagStrengthen:
            _player.isStrengthened = YES;
            [_player useHandCard];
            break;
            
        case kPlayingMenuItemTagDiscard:
            [[BGClient sharedClient] sendDiscardRequest];
            break;
            
        case kPlayingMenuItemTagRedColor:
            [self touchCardColorMenuItemWithColor:kCardColorRed];
            break;
            
        case kPlayingMenuItemTagBlackColor:
            [self touchCardColorMenuItemWithColor:kCardColorBlack];
            break;
            
        case kPlayingMenuItemTagHearts:
            [self touchCardSuitsMenuItemWithSuits:kCardSuitsHearts];
            break;
            
        case kPlayingMenuItemTagDiamonds:
            [self touchCardSuitsMenuItemWithSuits:kCardSuitsDiamonds];
            break;
            
        case kPlayingMenuItemTagSpades:
            [self touchCardSuitsMenuItemWithSuits:kCardSuitsSpades];
            break;
            
        case kPlayingMenuItemTagClubs:
            [self touchCardSuitsMenuItemWithSuits:kCardSuitsClubs];
            break;
            
        default:
            break;
    }
    
    [_player resetAndRemoveNodes];
}

/*
 * Touch okay menu item:
 * 1. Use hand card.
 * 2. Use hero skill and/or hand card.
 */
- (void)touchOkayMenuItem
{    
    if (kHeroSkillInvalid == _player.selectedSkillId) {
        [_player useHandCard];
    }
    else {
        if (0 == _player.selectedCardIds.count) {
            [[BGClient sharedClient] sendUseHeroSkillRequest];
        } else {
            [_player useHandCardWithHeroSkill];
        }
    }
}

/*
 * Touch card color menu item.
 */
- (void)touchCardColorMenuItemWithColor:(BGCardColor)color
{
    _player.selectedColor = color;
    [[BGClient sharedClient] sendChoseColorRequest];
}

/*
 * Touch card suits menu item.
 */
- (void)touchCardSuitsMenuItemWithSuits:(BGCardSuits)suits
{
    _player.selectedSuits = suits;
    [[BGClient sharedClient] sendChoseSuitsRequest];
}

@end
