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

@interface BGPlayingMenu ()

@property (nonatomic, weak) BGGameLayer *gameLayer;
@property (nonatomic, weak) BGPlayer *player;

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

+ (id)playingMenuWithMenuType:(BGPlayingMenuType)menuType
{
    return [[self alloc] initWithMenuType:menuType];
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
}

/*
 * Create menu item with Okay
 */
- (void)createPlayingMenuForOkay
{
    _menu = [_menuFactory createMenuWithSpriteFrameName:kImageOkay
                                      selectedFrameName:kImageOkaySelected
                                      disabledFrameName:kImageOkayDisabled];
    _menu.position = POSITION_PLAYING_MENU;
    [_menu.children.lastObject setTag:kPlayingMenuItemTagOkay];
    [_menu.children.lastObject setIsEnabled:NO];
    
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
    _menu.position = POSITION_PLAYING_MENU;
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
    _menu.position = POSITION_PLAYING_MENU;
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
    _menu.position = POSITION_PLAYING_MENU;
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
    _menu.position = POSITION_PLAYING_MENU;
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
    _menu.position = POSITION_PLAYING_MENU;
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
    _menu.position = POSITION_PLAYING_MENU;
    [_menu alignItemsHorizontallyWithPadding:PADDING_SUITS_BUTTON];
    
    [[_menu.children getNSArray] enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        if (0 == idx) {
            [obj setTag:kPlayingMenuItemTagHearts];
        } else if (1 == idx) {
            [obj setTag:kPlayingMenuItemTagDiamonds];
        } else if (2 == idx) {
            [obj setTag:kPlayingMenuItemTagSpades];
        } else if (3 == idx) {
            [obj setTag:kPlayingMenuItemTagClubs];
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
    switch (menuItem.tag) {
        case kPlayingMenuItemTagOkay:
            [self touchOkayMenuItem];
            break;
            
        case kPlayingMenuItemTagCancel:
            [[BGClient sharedClient] sendCancelRequest];
            break;
            
        case kPlayingMenuItemTagStrengthen:
            [_player.handArea useHandCardWithAnimation:YES block:^{
                [[BGClient sharedClient] sendUseHandCardRequestWithIsStrengthened:YES];
            }];
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
    
    [_player removePlayingMenu];
    [_player removeProgressBar];
    [_gameLayer disablePlayerAreaForOtherPlayers];
}

/*
 * Touch okay menu item:
 * 1. Use hand card.
 * 2. Use hero skill and/or hand card.
 */
- (void)touchOkayMenuItem
{
    BOOL isRunAnimation = (kGameStatePlaying == _gameLayer.state);
    
    if (kHeroSkillInvalid == _player.selectedSkillId) {
        [_player.handArea useHandCardWithAnimation:isRunAnimation block:^{
            
        }];
        
        switch (_gameLayer.state) {
            case kGameStateCutting:
                _player.comparedCardId = [_player.selectedCardIds.lastObject integerValue];
                [[BGClient sharedClient] sendChoseCardToCutRequest];
                break;
                
            case kGameStateChoosing:
                [[BGClient sharedClient] sendChoseCardToUseRequest];
                break;
                
            case kGameStatePlaying:
                [[BGClient sharedClient] sendUseHandCardRequestWithIsStrengthened:NO];
                break;
                
            case kGameStateGiving:
                [[BGClient sharedClient] sendChoseCardToGiveRequest];
                break;
                
            case kGameStateDiscarding:
                [[BGClient sharedClient] sendDiscardRequest];
                break;
                
            default:
                [[BGClient sharedClient] sendChoseCardToUseRequest];
                break;
        }
    }
    else {
        if (0 == _player.selectedCardIds.count) {
            [[BGClient sharedClient] sendUseHeroSkillRequest];
        } else {
            [_player.handArea useHandCardWithAnimation:NO block:^{
                [[BGClient sharedClient] sendUseHeroSkillRequest];
            }];
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
