//
//  BGEquipmentArea.m
//  DotAHero
//
//  Created by Killua Liu on 5/30/13.
//
//

#import "BGEquipmentArea.h"
#import "BGGameLayer.h"
#import "BGPlayer.h"
#import "BGMoveComponent.h"
#import "BGDefines.h"

@interface BGEquipmentArea ()

@property (nonatomic, weak) BGPlayer *player;
@property (nonatomic, strong) BGMenuFactory *menuFactory;
@property (nonatomic, strong) CCMenu *equipmentMenu;

@end

@implementation BGEquipmentArea

- (id)initWithPlayer:(BGPlayer *)player
{
    if (self = [super init]) {
        _player = player;
        self.equipmentCards = [NSMutableArray arrayWithCapacity:2]; // 武器和防具
        _menuFactory = [BGMenuFactory menuFactory];
    }
    return self;
}

+ (id)equipmentAreaWithPlayer:(BGPlayer *)player
{
    return [[self alloc] initWithPlayer:player];
}

/*
 * Add a equipment card with playing card while euqipping
 */
- (void)addEquipmentWithPlayingCard:(BGPlayingCard *)card
{
    [self renderEquipmentWithCard:card];
    [self updateEquipmentBufferWithCard:card];
}

/*
 * Add a equipment card with card id while euqipping
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

- (void)removeEquipmentFromBufferWithCard:(BGPlayingCard *)card
{
    [_equipmentCards removeObject:card];
}

/*
 * Render the equipment card after equipped
 * If exist same type equipment(Weapon/Armor), remove the existing one.
 */
- (void)renderEquipmentWithCard:(BGPlayingCard *)card
{
    CGPoint menuPosition;
    CGFloat playerAreaWidth = _player.playerAreaSize.width;
    CGFloat playerAreaHeight = _player.playerAreaSize.height;
    
    switch (card.equipmentType) {
        case kEquipmentTypeWeapon:
            _equipmentMenu = (CCMenu *)[self getChildByTag:kEquipmentTypeWeapon];
            menuPosition = (_player.isCurrentPlayer) ?
                ccp(playerAreaWidth*0.925, playerAreaHeight*0.575) :
                ccp(playerAreaWidth*0.253, playerAreaHeight*0.177);
            if (card.onlyEquipOne) {    // 圣者遗物(不能装备防具)
                [[self getChildByTag:kEquipmentTypeArmor] removeAllChildrenWithCleanup:YES];
            }
            break;
            
        case kEquipmentTypeArmor:
            _equipmentMenu = (CCMenu *)[self getChildByTag:kEquipmentTypeArmor];
            menuPosition = (_player.isCurrentPlayer) ?
                ccp(playerAreaWidth*0.925, playerAreaHeight*0.215) :
                ccp(playerAreaWidth*0.253, -playerAreaHeight*0.222);
            break;
            
        default:
            break;
    }
    
//  If exist same type equipment(Weapon/Armor), remove the existing one.
    if (_equipmentMenu) {
        [self removeExistingEquipmentWithCard:card];
    }
    
    NSString *imageName = (_player.isCurrentPlayer) ? card.bigEquipImageName : card.equipImageName;
    _equipmentMenu = [_menuFactory createMenuWithSpriteFrameName:imageName
                                              selectedFrameName:nil
                                              disabledFrameName:nil];
    _equipmentMenu.position = menuPosition;
    [_equipmentMenu.children.lastObject setTag:card.cardId];
    _equipmentMenu.enabled = card.canBeUsedActive;
    [self addChild:_equipmentMenu z:card.equipmentType];
    
//  Render card suits
    CCMenuItem *menuItem = _equipmentMenu.children.lastObject;
    CGFloat width = menuItem.contentSize.width;
    CGFloat height = menuItem.contentSize.height;
    
    CCSprite *figureSprite = [CCSprite spriteWithSpriteFrameName:card.figureImageName];
    figureSprite.position = ccp(width*0.11, height*0.90);
    [menuItem addChild:figureSprite];
    
    CCSprite *suitsSprite = [CCSprite spriteWithSpriteFrameName:card.suitsImageName];
    suitsSprite.position = ccp(width*0.11, height*0.75);
    [menuItem addChild:suitsSprite];
    
//  Render equipment name with label text
//    CCLabelTTF *label = [CCLabelTTF labelWithString:card.cardText
//                                           fontName:@"Arial"
//                                           fontSize:14.0f];
//    label.position = ccp(width*0.90, height/2);
//    [menuItem addChild:label];
}

- (void)removeExistingEquipmentWithCard:(BGPlayingCard *)card
{   
    BGMoveComponent *moveComp = [BGMoveComponent moveWithTarget:USED_CARD_POSITION
                                                         ofNode:_equipmentMenu];
    
    [moveComp runActionEaseMoveScaleWithDuration:CARD_MOVE_DURATION
                                           scale:0.5f
                                           block:^{
                                               [_equipmentMenu removeFromParentAndCleanup:YES];
                                               [_player.playingDeck showUsedHandCardsWithCardIds:[NSArray arrayWithObject:@(card.cardId)]];
                                           }];
}

/*
 * Lost equipment - Was greeded or disarmed
 */
- (void)lostEquipmentWithCard:(BGPlayingCard *)card
{
    BGGameLayer *gamePlayer = [BGGameLayer sharedGameLayer];
    BGPlayer *targetPlayer = [[BGGameLayer sharedGameLayer] playerWithName:gamePlayer.targetPlayerNames.lastObject];
    
    BGMoveComponent *moveComp = [BGMoveComponent moveWithTarget:targetPlayer.position
                                                         ofNode:_equipmentMenu];
    
    [moveComp runActionEaseMoveScaleWithDuration:CARD_MOVE_DURATION
                                           scale:0.5f
                                           block:^{
                                               [_equipmentMenu removeFromParentAndCleanup:YES];
                                           }];
    [self removeEquipmentFromBufferWithCard:card];
}

#pragma mark - Equipment card using
/*
 * Menu delegate method is called while touching a equipment
 */
- (void)menuItemTouched:(CCMenuItem *)menuItem
{
    
}

@end
