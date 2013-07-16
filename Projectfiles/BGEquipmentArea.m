//
//  BGEquipmentArea.m
//  DotAHero
//
//  Created by Killua Liu on 5/30/13.
//
//

#import "BGEquipmentArea.h"
#import "BGPlayer.h"
#import "BGPlayingCard.h"

@interface BGEquipmentArea ()

@property (nonatomic, weak) BGPlayer *player;

@end

@implementation BGEquipmentArea

- (id)initWithPlayer:(BGPlayer *)player
{
    if (self = [super init]) {
        _player = player;
        self.equipmentCards = [NSMutableArray arrayWithCapacity:2]; // 武器和防具
    }
    return self;
}

+ (id)equipmentAreaWithPlayer:(BGPlayer *)player
{
    return [[self alloc] initWithPlayer:player];
}

/*
 * Add a equipment card while euqipping
 */
- (void)addEquipmentWithCardId:(NSInteger)cardId
{
    BGPlayingCard *card = [BGPlayingCard cardWithCardId:cardId];
    [self renderEquipmentWithCard:card];
    [self updateEquipmentBufferWithCard:card];
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
    
    NSUInteger idx;
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

/*
 * Render the equipment card after equipped
 */
- (void)renderEquipmentWithCard:(BGPlayingCard *)card
{
    CCNode *equipmentMenu = nil;
    CGPoint menuPosition;
    CGFloat playerAreaWidth = _player.playerAreaSize.width;
    CGFloat playerAreaHeight = _player.playerAreaSize.height;
    
    BGMenuFactory *menuFactory = [BGMenuFactory menuFactory];
    NSString *imageName = (_player.isCurrentPlayer) ? card.bigEquipImageName : card.equipImageName;
    
    switch (card.equipmentType) {
        case kEquipmentTypeWeapon:
            equipmentMenu = [self getChildByTag:kEquipmentTypeWeapon];
            NSAssert([equipmentMenu isKindOfClass:[CCMenuItem class]], @"Not a CCMenuItem");
            menuPosition = (_player.isCurrentPlayer) ? ccp(playerAreaWidth*0.925, playerAreaHeight*0.575) : ccp(playerAreaWidth*0.253, playerAreaHeight*0.177);
            if (card.onlyEquipOne) {    // 圣者遗物(不能装备防具)
                [[self getChildByTag:kEquipmentTypeArmor] removeAllChildrenWithCleanup:YES];
            }
            break;
            
        case kEquipmentTypeArmor:
            equipmentMenu = [self getChildByTag:kEquipmentTypeArmor];
            NSAssert([equipmentMenu isKindOfClass:[CCMenuItem class]], @"Not a CCMenuItem");
            menuPosition = (_player.isCurrentPlayer) ? ccp(playerAreaWidth*0.925, playerAreaHeight*0.215) : ccp(playerAreaWidth*0.253, -playerAreaHeight*0.222);
            break;
            
        default:
            break;
    }
    
    [equipmentMenu removeAllChildrenWithCleanup:YES];
    equipmentMenu = [menuFactory createMenuWithSpriteFrameName:imageName
                                             selectedFrameName:nil
                                             disabledFrameName:nil];
    equipmentMenu.position = menuPosition;
    [self addChild:equipmentMenu z:card.equipmentType];
}

#pragma mark - Equipment card using
/*
 * Menu delegate method is called while touching a equipment
 */
- (void)menuItemTouched:(CCMenuItem *)menuItem
{
    
}

@end
