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
@property (nonatomic, strong) CCMenu *equipmentMenu;

@end

@implementation BGEquipmentArea

- (id)initWithPlayer:(BGPlayer *)player
{
    if (self = [super init]) {
        _gameLayer = [BGGameLayer sharedGameLayer];
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

#pragma mark - Equipment updating
/*
 * Update(Add/Remove) equipment card with hand card while euqipping
 */
- (void)updateEquipmentWithCard:(BGPlayingCard *)card
{
//  If the card is contained in equipment cards, need remove it.
    if ([_equipmentCards containsObject:card]) {
        [self removeEquipmentWithCard:card isShowingOnDeck:NO];
        [self removeEquipmentFromBufferWithCard:card];
    } else {
        [self renderEquipmentWithCard:card];
        [self updateEquipmentBufferWithCard:card];
    }
    
    [[BGAudioComponent sharedAudioComponent] playEquipCard];
}

/*
 * Remove equipment card: Is extracted or disarmed/replaced
 * Set card move target positon according to different Action
 * (Move card to playing deck or other player)
 */
- (void)removeEquipmentWithCard:(BGPlayingCard *)card isShowingOnDeck:(BOOL)isOnDeck
{
//    CGPoint targetPos;
//    if (kActionUpdatePlayerEquipment == _player.action) {
////        targetPos = USED_CARD_POSITION;
//    } else {
//        BGPlayer *targetPlayer = [_gameLayer playerWithName:_gameLayer.targetPlayerNames.lastObject];
//        targetPos = targetPlayer.position;
//    }
//    
//    BGMoveComponent *moveComp = [BGMoveComponent moveWithNode:_equipmentMenu];
//    [moveComp runActionEaseMoveWithTarget:targetPos
//                                 duration:DURATION_USED_CARD_MOVE
//                                    block:^{
//                                        [_equipmentMenu removeFromParent];
//                                        if (isOnDeck) {
//                                            [_gameLayer.playingDeck updatePlayingDeckWithCardIds:[NSArray arrayWithObject:@(card.cardId)]];
//                                        }
//                                    }];
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

#pragma mark - Equipment rendering
/*
 * Render the equipment card after equipped
 * If exist same type equipment(Weapon/Armor), remove the existing one.
 */
- (void)renderEquipmentWithCard:(BGPlayingCard *)card
{
    CGPoint menuPosition;
    CGFloat playerAreaWidth = _player.contentSize.width;
    CGFloat playerAreaHeight = _player.contentSize.height;
    
    switch (card.equipmentType) {
        case kEquipmentTypeWeapon:
            _equipmentMenu = (CCMenu *)[self getChildByTag:kEquipmentTypeWeapon];
            menuPosition = (_player.isSelfPlayer) ?
                ccp(playerAreaWidth*0.925, playerAreaHeight*0.575) :
                ccp(playerAreaWidth*0.253, playerAreaHeight*0.177);
            if (card.onlyEquipOne) {    // 圣者遗物(不能装备防具)
                [[self getChildByTag:kEquipmentTypeArmor] removeAllChildren];
            }
            break;
            
        case kEquipmentTypeArmor:
            _equipmentMenu = (CCMenu *)[self getChildByTag:kEquipmentTypeArmor];
            menuPosition = (_player.isSelfPlayer) ?
                ccp(playerAreaWidth*0.925, playerAreaHeight*0.215) :
                ccp(playerAreaWidth*0.253, -playerAreaHeight*0.222);
            break;
            
        default:
            break;
    }
    
//  If exist same type equipment(Weapon/Armor), remove the existing one.
    if (_equipmentMenu) {
        [self removeEquipmentWithCard:card isShowingOnDeck:YES];
    }
    
    NSString *imageName = (_player.isSelfPlayer) ? card.bigEquipImageName : card.equipImageName;
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

#pragma mark - Equipment using
/*
 * Menu delegate method is called while touching a equipment
 */
- (void)menuItemTouched:(CCMenuItem *)menuItem
{
    
}

@end
