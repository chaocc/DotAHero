//
//  BGEquipmentArea.m
//  DotAHero
//
//  Created by Killua Liu on 5/30/13.
//
//

#import "BGEquipmentArea.h"
#import "BGGameLayer.h"
#import "BGActionComponent.h"
#import "BGDefines.h"
#import "BGAudioComponent.h"

@interface BGEquipmentArea ()

@property (nonatomic, weak) BGGameLayer *gameLayer;
@property (nonatomic, weak) BGPlayer *player;
@property (nonatomic, strong) BGMenuFactory *menuFactory;
@property (nonatomic, strong) CCMenu *equipMenu;

@end

@implementation BGEquipmentArea

- (id)initWithPlayer:(BGPlayer *)player
{
    if (self = [super init]) {
        _gameLayer = [BGGameLayer sharedGameLayer];
        _player = player;
        
        self.equipmentCards = [NSMutableArray arrayWithCapacity:2]; // 武器和防具
        
        _menuFactory = [BGMenuFactory menuFactory];
        _equipMenu = [CCMenu menuWithArray:nil];
        _equipMenu.enabled = NO;
        _equipMenu.position = CGPointZero;
        [self addChild:_equipMenu];
        _menuFactory.delegate = self;
    }
    return self;
}

+ (id)equipmentAreaWithPlayer:(BGPlayer *)player
{
    return [[self alloc] initWithPlayer:player];
}

#pragma mark - Equipment updating
/*
 * Update(Add/Remove) equipment card with hand card while euqipping
 * If the card is contained in equipment cards, need remove it.
 */
- (void)updateEquipmentWithCard:(BGPlayingCard *)card
{
//    [_gameLayer.playingDeck clearAllExistingCards];
    
    if ([_equipmentCards containsObject:card]) {
        [self removeEquipmentWithCard:card];
    } else {
        [self addEquipmentWithCard:card];
    }
    
    [[BGAudioComponent sharedAudioComponent] playCardEquip];
}

- (void)updateEquipmentWithCardId:(NSInteger)cardId
{
    [self updateEquipmentWithCard:[BGPlayingCard cardWithCardId:cardId]];
}

/*
 * If exist same type equipment(Weapon/Armor), remove the existing one(Replaced).
 * Show the replaced equipment card on the deck
 */
- (void)addEquipmentWithCard:(BGPlayingCard *)card
{
    [self updateEquipmentBufferWithCard:card];
    
    NSArray *menuItems, *existingMenuItems;
    
    if (card.onlyEquipOne) {    // 圣者遗物(不能装备防具)
        NSMutableArray *existingCards = [NSMutableArray array];
        for (CCMenuItem *menuItem in _equipMenu.children) {
            [existingCards addObject:[BGPlayingCard cardWithCardId:menuItem.tag]];
        }
        existingMenuItems = [_equipMenu.children getNSArray];
        menuItems = [_menuFactory createMenuItemsWithCards:existingCards];
    }
    else {
        for (CCMenuItem *menuItem in _equipMenu.children) {
            BGPlayingCard *existingCard = [BGPlayingCard cardWithCardId:menuItem.tag];
            if (existingCard.equipmentType == card.equipmentType) {
                existingMenuItems = [NSArray arrayWithObject:menuItem];
                menuItems = [_menuFactory createMenuItemsWithCards:[NSArray arrayWithObject:existingCard]];
                break;
            }
        }
    }
    
//  Remove existing weapon/armor, show it on on the deck.
    if (menuItems) {
        [menuItems enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            CCMenuItem *existingMenuItem = existingMenuItems[idx];
            [obj setPosition:ccpAdd(_player.position, existingMenuItem.position)];
            [_equipMenu removeChild:existingMenuItem];
        }];
        [self removeEquipmentWithCardMenuItems:menuItems];
    }
    
    [self renderEquipmentWithCard:card];
}

/*
 * Remove the equipment(Is drew or disarmed by other player)
 */
- (void)removeEquipmentWithCard:(BGPlayingCard *)card
{
    [self removeEquipmentFromBufferWithCard:card];
    
    for (CCMenuItem *menuItem in _equipMenu.children) {
        if (menuItem.tag == card.cardId) {
            if (![_gameLayer.reason isEqualToString:@"m_greeded"]) {
                NSArray *menuItems = [_menuFactory createMenuItemsWithCards:[NSArray arrayWithObject:card]];
                CCNode *node = menuItems.lastObject;
                node.position = ccpAdd(_player.position, menuItem.position);
                [self removeEquipmentWithCardMenuItems:menuItems];
            }
            [menuItem removeFromParent];
            break;
        }
    }
}

/*
 * Remove equipment card: Is drew or disarmed/replaced
 * (Move card to playing deck or other player)
 */
- (void)removeEquipmentWithCardMenuItems:(NSArray *)menuItems
{
    [_gameLayer.playingDeck showUsedCardWithCardMenuItems:menuItems];
}

/*
 * Update(Add/Replace) card to equipment buffer
 */
- (void)updateEquipmentBufferWithCard:(BGPlayingCard *)card
{
    if (card.onlyEquipOne) {    // 圣者遗物(不能装备防具)
        [_equipmentCards removeAllObjects];
        [_equipmentCards addObject:card];
        return;
    }
    
    NSUInteger idx = 0;
    BOOL isExisting = NO;
    for (id obj in _equipmentCards) {
        if ([obj equipmentType] == card.equipmentType) {
            [_equipmentCards replaceObjectAtIndex:idx withObject:card];
            isExisting = YES;
            break;
        }
        idx++;
    }
    
    if (!isExisting) {
        [_equipmentCards addObject:card];
    }
}

- (void)removeEquipmentFromBufferWithCard:(BGPlayingCard *)card
{
    [_equipmentCards removeObject:card];
}

#pragma mark - Equipment rendering
/*
 * Render the equipment card after equipped
 */
- (void)renderEquipmentWithCard:(BGPlayingCard *)card
{
    CGFloat playerAreaWidth = _player.contentSize.width;
    CGFloat playerAreaHeight = _player.contentSize.height;
    
    NSString *imageName = (_player.isSelf) ? card.bigEquipImageName : card.equipImageName;
    [_menuFactory addMenuItemWithSpriteFrameName:imageName
                                       isEnabled:card.canBeUsedActive
                                          toMenu:_equipMenu];
    CCMenuItem *menuItem = _equipMenu.children.lastObject;
    menuItem.tag = card.cardId;
    
    switch (card.equipmentType) {
        case kEquipmentTypeWeapon:
            menuItem.position = (_player.isSelf) ?
                ccp(playerAreaWidth*0.93, playerAreaHeight*0.57) :
                ccp(playerAreaWidth*0.25, playerAreaHeight*0.177);
            break;
            
        case kEquipmentTypeArmor:
            menuItem.position = (_player.isSelf) ?
                ccp(playerAreaWidth*0.93, playerAreaHeight*0.21) :
                ccp(playerAreaWidth*0.25, -playerAreaHeight*0.222);
            break;
    }
    
//  Render card suits
    CGFloat width = menuItem.contentSize.width;
    CGFloat height = menuItem.contentSize.height;
    
    CCSprite *figureSprite = [CCSprite spriteWithSpriteFrameName:card.figureImageName];
    figureSprite.position = ccp(width*0.11, height*0.90);
    [menuItem addChild:figureSprite];
    
    CCSprite *suitsSprite = [CCSprite spriteWithSpriteFrameName:card.suitsImageName];
    suitsSprite.position = ccp(width*0.11, height*0.75);
    [menuItem addChild:suitsSprite];
    
//  Render equipment name with label text
    NSString *text = [NSString string];
    for (NSUInteger i = 0; i < card.cardText.length; i++) {
        text = [text stringByAppendingFormat:@"%@\n", [card.cardText substringWithRange:NSMakeRange(i, 1)]];
    }
    
    CCLabelBMFont *label = [CCLabelBMFont labelWithString:text fntFile:kFontEquipmentName];
    label.anchorPoint = ccp(0.5f, 0.4f);
    label.position = ccp(width*0.90, height/2);
    [menuItem addChild:label];
}

#pragma mark - Equipment using
/*
 * Menu delegate method is called while touching a equipment
 */
- (void)menuItemTouched:(CCMenuItem *)menuItem
{
    
}

@end
