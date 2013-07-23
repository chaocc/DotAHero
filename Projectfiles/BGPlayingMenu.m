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

@property (nonatomic, weak) BGPlayer *player;
@property (nonatomic, strong) BGMenuFactory *menuFactory;

@end

@implementation BGPlayingMenu

- (id)initWithMenuType:(BGPlayingMenuType)menuType ofPlayer:(BGPlayer *)player
{
    if (self = [super init]) {
        _menuType = menuType;
        _player = player;
        _menuFactory = [BGMenuFactory menuFactory];
        
        [self createMenu];
    }
    return self;
}

+ (id)playingMenuWithMenuType:(BGPlayingMenuType)menuType ofPlayer:(BGPlayer *)player
{
    return [[self alloc] initWithMenuType:menuType ofPlayer:player];
}

#pragma mark - Playing menu creation
/*
 * Create menu according to different menu type
 */
- (void)createMenu
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
            
        case kPlayingMenuTypeStrengthen:
            [self createPlayingMenuForStrengthen];
            break;
            
        case kPlayingMenuTypeCardColor:
            [self createPlayingMenuForCardColor];
            break;
            
        default:
            break;
    }
}

- (void)addMenuNode
{
    _menu.position = ccp(SCREEN_WIDTH/2, SCREEN_HEIGHT*0.35);
    [_menu alignItemsHorizontallyWithPadding:40.0f];
    [self addChild:_menu];
    
    _menuFactory.delegate = self;
}

/*
 * Create menu items with Okay/Discard
 */
- (void)createPlayingMenuForUsing
{
    NSArray *spriteFrameNames = [NSArray arrayWithObjects:kImageOkay, kImageDiscard, nil];
    NSArray *selFrameNames = [NSArray arrayWithObjects:kImageOkaySelected, kImageDiscardSelected, nil];
    NSArray *disFrameNames = [NSArray arrayWithObjects:kImageOkayDisabled, kImageDiscardDisabled, nil];
    
    _menu = [_menuFactory createMenuWithSpriteFrameNames:spriteFrameNames
                                      selectedFrameNames:selFrameNames
                                      disabledFrameNames:disFrameNames];
    
    [[_menu.children getNSArray] enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        if (idx == 0) {
            [obj setTag:kPlayingMenuItemTagOkay];
            [obj setIsEnabled:NO];  // Disable okay menu
        } else if (idx == 1) {
            [obj setTag:kPlayingMenuItemTagDiscard];
        }
    }];
    
    [self addMenuNode];
}

/*
 * Create menu items with Okay/Cancel - Playing
 */
- (void)createPlayingMenuForPlaying
{
    NSArray *spriteFrameNames = [NSArray arrayWithObjects:kImageOkay, kImageCancel, nil];
    NSArray *selFrameNames = [NSArray arrayWithObjects:kImageOkaySelected, kImageCancelSelected, nil];
    NSArray *disFrameNames = [NSArray arrayWithObjects:kImageOkayDisabled, kImageCancelDisabled, nil];
    
    _menu = [_menuFactory createMenuWithSpriteFrameNames:spriteFrameNames
                                      selectedFrameNames:selFrameNames
                                      disabledFrameNames:disFrameNames];
    
    [[_menu.children getNSArray] enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        if (idx == 0) {
            [obj setTag:kPlayingMenuItemTagOkay];
            [obj setIsEnabled:NO];  // Disable okay menu
        } else if (idx == 1) {
            [obj setTag:kPlayingMenuItemTagCancel];
        }
    }];
    
    [self addMenuNode];
}

/*
 * Create menu items with Okay/Strengthen/Discard
 */
- (void)createPlayingMenuForStrengthen
{
    NSArray *spriteFrameNames = [NSArray arrayWithObjects:kImageOkay, kImageStrengthen, kImageDiscard, nil];
    NSArray *selFrameNames = [NSArray arrayWithObjects:kImageOkaySelected, kImageStrengthenSelected, kImageDiscardSelected, nil];
    NSArray *disFrameNames = [NSArray arrayWithObjects:kImageOkayDisabled, kImageStrengthenDisabled, kImageDiscardDisabled, nil];
    
    _menu = [_menuFactory createMenuWithSpriteFrameNames:spriteFrameNames
                                      selectedFrameNames:selFrameNames
                                      disabledFrameNames:disFrameNames];
    [_menu alignItemsHorizontallyWithPadding:20.0f];
    
    [[_menu.children getNSArray] enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        if (idx == 0) {
            [obj setTag:kPlayingMenuItemTagOkay];
            [obj setIsEnabled:NO];  // Disable okay menu
        } else if (idx == 1) {
            [obj setTag:kPlayingMenuItemTagStrengthen];
        } else if (idx == 2) {
            [obj setTag:kPlayingMenuItemTagDiscard];
        }
    }];
    
    [self addMenuNode];
}

/*
 * Create menu item with Okay
 */
- (void)createOkayPlayingMenu
{
    _menu = [_menuFactory createMenuWithSpriteFrameName:kImageOkay
                                      selectedFrameName:kImageOkaySelected
                                      disabledFrameName:kImageOkayDisabled];
    [_menu.children.lastObject setIsEnabled:NO];
    
    [self addMenuNode];
}

/*
 * Create menu item with Red/Black Color
 */
- (void)createPlayingMenuForCardColor
{
    NSArray *spriteFrameNames = [NSArray arrayWithObjects:kImageMenuHearts, kImageMenuSpades, nil];
    
    _menu = [_menuFactory createMenuWithSpriteFrameNames:spriteFrameNames
                                      selectedFrameNames:nil
                                      disabledFrameNames:nil];
    
    [[_menu.children getNSArray] enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        if (idx == 0) {
            [obj setTag:kPlayingMenuItemTagRedColor];
        } else if (idx == 1) {
            [obj setTag:kPlayingMenuItemTagBlackColor];
        }
    }];
    
    [self addMenuNode];
}

/*
 * Create menu item with Hearts/Diamonds/Spades/Clubs
 */
- (void)createPlayingMenuForCardSuits
{
    NSArray *spriteFrameNames = [NSArray arrayWithObjects:kImageMenuHearts, kImageMenuDiamonds, kImageMenuSpades, kImageMenuClubs, nil];
    
    _menu = [_menuFactory createMenuWithSpriteFrameNames:spriteFrameNames
                                      selectedFrameNames:nil
                                      disabledFrameNames:nil];
    [_menu alignItemsHorizontallyWithPadding:20.0f];
    
    [[_menu.children getNSArray] enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        if (idx == 0) {
            [obj setTag:kPlayingMenuItemTagHearts];
        } else if (idx == 1) {
            [obj setTag:kPlayingMenuItemTagDiamonds];
        } else if (idx == 2) {
            [obj setTag:kPlayingMenuItemTagSpades];
        } else if (idx == 3) {
            [obj setTag:kPlayingMenuItemTagClubs];
        }
    }];
    
    [self addMenuNode];
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
            [self touchCancelMenuItem];
            break;
            
        case kPlayingMenuItemTagStrengthen:
            [self useMagicCardWithStengthened:YES];
            break;
            
        case kPlayingMenuItemTagDiscard:
            [_menu removeFromParentAndCleanup:YES];
            [self createOkayPlayingMenu];
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
}

/*
 * Touch okay menu item. Call method according to different menu type.
 */
- (void)touchOkayMenuItem
{
    switch (_menuType) {
        case kPlayingMenuTypeCardCutting:
        case kPlayingMenuTypeCardUsing:
        case kPlayingMenuTypeCardPlaying:
            [self usePlayingCard];
            break;
            
        case kPlayingMenuTypeStrengthen:
            [self useMagicCardWithStengthened:NO];
            break;
            
        default:
            break;
    }
}

/*
 * Touch cancel menu item. Call method according to different menu type.
 */
- (void)touchCancelMenuItem
{
    switch (_menuType) {
        case kPlayingMenuTypeCardPlaying:
            [[BGClient sharedClient] sendCancelPlayingCardRequest];
            break;
            
        default:
            break;
    }
    
    [self removeFromParentAndCleanup:YES];
}

/*
 * Touch card color menu item. Call method according to different card enum.
 */
- (void)touchCardColorMenuItemWithColor:(BGCardColor)color
{
    _player.selectedColor = color;
    
    switch (_player.playerState) {
        case kPlayerStatePlaying:
            [[BGClient sharedClient] sendUsePlayingCardRequest];
            break;
            
        case kPlayerStateGuessingCardColor:
            [[BGClient sharedClient] sendGuessCardColorRequest];
            break;
            
        default:
            break;
    }
    
    [self removeFromParentAndCleanup:YES];
}

/*
 * Touch card suits menu item.
 */
- (void)touchCardSuitsMenuItemWithSuits:(BGCardSuits)suits
{
    _player.selectedSuits = suits;
    [[BGClient sharedClient] sendUsePlayingCardRequest];
    [self removeFromParentAndCleanup:YES];
}

#pragma mark - Playing card using
/*
 * Use playing card and send request to server
 */
- (void)usePlayingCard
{    
    switch (_player.playerState) {
        case kPlayerStateCutting:
            [_player.handArea useHandCardsWithBlock:^{
                [[BGClient sharedClient] sendCutPlayingCardRequest];
            }];
            break;
            
        case kPlayerStatePlaying:
            [_player.handArea useHandCardsAndRunAnimationWithBlock:^{
                [[BGClient sharedClient] sendUsePlayingCardRequest];
            }];
            break;
            
        case kPlayerStateThrowingCard:
            [_player.handArea useHandCardsWithBlock:^{
                [[BGClient sharedClient] sendDiscardPlayingCardRequest];
            }];
            break;
            
        case kPlayerStateExtractingCard:    // 贪婪强化，抽完牌还要分牌
            [_player.handArea giveSelectedCardsToTargetPlayerWithBlock:^{
                [[BGClient sharedClient] sendExtractCardRequest];
            }];
            break;
            
        default:
            break;
    }
    
    [self removeFromParentAndCleanup:YES];
}

/*
 * Use magic card with strengthen flag
 */
- (void)useMagicCardWithStengthened:(BOOL)isStrengthened
{
    [_player.handArea useHandCardsAndRunAnimationWithBlock:^{
        _player.isSelectedStrenthen = isStrengthened;
        
        BGCard *card = [BGPlayingCard cardWithCardId:[_player.selectedCardIds.lastObject integerValue]];
        switch (card.cardEnum) {
            case kPlayingCardElunesArrow:
                [_menu removeFromParentAndCleanup:YES];
                if (isStrengthened) {
                    [self createPlayingMenuForCardSuits];
                } else {
                    [self createPlayingMenuForCardColor];
                }
                break;
                
            case kPlayingCardGreed:
                if (isStrengthened) {
                    [_menu removeFromParentAndCleanup:YES];
                    [self createOkayPlayingMenu];
                } else {
                    [[BGClient sharedClient] sendUsePlayingCardRequest];
                    [self removeFromParentAndCleanup:YES];
                }
                break;
                
            default:
                [[BGClient sharedClient] sendUsePlayingCardRequest];
                [self removeFromParentAndCleanup:YES];
                break;
        }
    }];
}

@end
