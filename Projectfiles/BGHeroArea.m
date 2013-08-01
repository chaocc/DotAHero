//
//  BGHeroArea.m
//  DotAHero
//
//  Created by Killua Liu on 5/30/13.
//
//

#import "BGHeroArea.h"
#import "BGGameLayer.h"
#import "BGPlayer.h"
#import "BGHeroSkill.h"
#import "BGFileConstants.h"
#import "BGEffectComponent.h"

typedef NS_ENUM(NSInteger, BGHeroTag) {
    kHeroTagBlood,
    kHeroTagAnger
};

@interface BGHeroArea ()

@property (nonatomic, weak) BGPlayer *player;
@property (nonatomic) CGFloat playerAreaWidth, playerAreaHeight;
@property (nonatomic, strong) CCSpriteBatchNode *spriteBatch;
@property (nonatomic, strong) BGMenuFactory *menuFactory;
@property (nonatomic, strong) CCMenu *heroMenu;
@property (nonatomic, strong) CCMenu *skillMenu;

@end

@implementation BGHeroArea

- (id)initWithHeroCardId:(NSInteger)cardId ofPlayer:(BGPlayer *)player
{
    if (self = [super init]) {
        _player = player;
        
        _heroCard = [BGHeroCard cardWithCardId:cardId];
        _bloodPoint = _heroCard.bloodPointLimit;
        _angerPoint = 0;
        _distance = 1;
        _attackRange = 1;
        _canBeTarget = YES;
        
        _playerAreaWidth = _player.playerAreaSize.width;
        _playerAreaHeight = _player.playerAreaSize.height;
        
        _menuFactory = [BGMenuFactory menuFactory];
        _menuFactory.delegate = self;
        [self renderSelectedHero];
    }
    return self;
}

+ (id)heroAreaWithHeroCardId:(NSInteger)cardId ofPlayer:(BGPlayer *)player
{
    return [[self alloc] initWithHeroCardId:cardId ofPlayer:player];
}

#pragma mark - Hero avatar/skill and blood rendering
/*
 * 1. Current player's position is (0,0) at left-bottom corner, hero area's position also (0,0).
 * 2. Other player's position is setted(not 0) in class BGGameLayer, its position should be the center of player area. 
 *    But as for its hero area, it is also (0,0) at the center. Becasue hero area is child node of player.
 */
- (void)renderSelectedHero
{
    _spriteBatch = [CCSpriteBatchNode batchNodeWithFile:kZlibHeroAvatar];
    [self addChild:_spriteBatch];
    
//  Render hero avatar
    NSString *avatarName =( _player.isCurrentPlayer) ? _heroCard.bigAvatarName : _heroCard.avatarName;
    _heroMenu = [_menuFactory createMenuWithSpriteFrameName:avatarName
                                          selectedFrameName:nil
                                          disabledFrameName:nil];
    _heroMenu.position = (_player.isCurrentPlayer) ?
        ccp(_playerAreaWidth*0.099, _playerAreaHeight*0.643) :
        ccp(-_playerAreaWidth*0.245, _playerAreaHeight*0.045);
    [_heroMenu.children.lastObject setTag:_heroCard.cardId];
    [self addChild:_heroMenu];
    
//  Render hero blood point
    [self renderBloodPoint];
    
//  Render hero skills if current player
    if (_player.isCurrentPlayer) {
        [self renderHeroSkills];
    }
}

/*
 * Render hero skills of current player
 */
- (void)renderHeroSkills
{
    NSUInteger skillCount = _heroCard.heroSkills.count;
    NSMutableArray *frameNames = [NSMutableArray arrayWithCapacity:skillCount];
    NSMutableArray *selFrameNames = [NSMutableArray arrayWithCapacity:skillCount];
    
    [_heroCard.heroSkills enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        BGHeroSkill *skill = [BGHeroSkill heroSkillWithSkillId:[obj integerValue]];
        
        NSString *frameName, *selFrameName;
        if (skill.skillCategory == kHeroSkillCategoryActive) {
            frameName = [NSString stringWithFormat:@"ActiveSkill%i.png", skillCount];
            selFrameName = [NSString stringWithFormat:@"ActiveSkill%i_Selected.png", skillCount];
        } else {
            frameName = [NSString stringWithFormat:@"PassiveSkill%i.png", skillCount];
            selFrameName = [NSString stringWithFormat:@"PassiveSkill%i_Selected.png", skillCount];
        }
        [frameNames addObject:frameName];
        [selFrameNames addObject:selFrameName];
    }];
    
    _skillMenu = [_menuFactory createMenuWithSpriteFrameNames:frameNames
                                           selectedFrameNames:selFrameNames
                                           disabledFrameNames:nil];
    _skillMenu.position = ccp(_playerAreaWidth*0.114, _playerAreaHeight*0.143);
    [_skillMenu alignItemsHorizontallyWithPadding:0.0f];
    [self addChild:_skillMenu];
    
//  Add label text to menu and disable passive skill menu
    [[_skillMenu.children getNSArray] enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        CCMenuItem *menuItem = obj;
        BGHeroSkill *skill = [BGHeroSkill heroSkillWithSkillId:[_heroCard.heroSkills[idx] integerValue]];
        menuItem.tag = skill.skillId;
        
        CCLabelTTF *label = [CCLabelTTF labelWithString:skill.skillText
                                               fontName:@"Arial"
                                               fontSize:14.0f];
        label.position = ccp(menuItem.contentSize.width/2, menuItem.contentSize.height/2);
        [menuItem addChild:label];
        
        menuItem.isEnabled = (skill.skillCategory == kHeroSkillCategoryActive);
    }];
}

/*
 * Render hero blood point
 */
- (void)renderBloodPoint
{
    NSString *bloodImageName;
    CGPoint deltaPos;
    CGFloat width, height;
    
    [[_spriteBatch getChildByTag:kHeroTagBlood] removeFromParentAndCleanup:YES];
    
    if (_player.isCurrentPlayer) {
        if (_bloodPoint == 1) {
            bloodImageName = kImageBloodRedBig;
        } else if (_bloodPoint == 2) {
            bloodImageName = kImageBloodYellowBig;
        } else {
            bloodImageName = kImageBloodGreenBig;
        }
        width = _playerAreaWidth*0.2 / (_heroCard.bloodPointLimit + 1);
        height = _playerAreaHeight*0.305;
    } else {
        if (_bloodPoint == 1) {
            bloodImageName = kImageBloodRed;
        } else if (_bloodPoint == 2) {
            bloodImageName = kImageBloodYellow;
        } else {
            bloodImageName = kImageBloodGreen;
        }
//      Move position to left corner of player area for other players
        deltaPos = ccp(-_playerAreaWidth/2, -_playerAreaHeight/2);
        width = _playerAreaWidth*0.5 / (_heroCard.bloodPointLimit + 1);
        height = _playerAreaHeight*0.135;
    }
    
    [_spriteBatch removeAllChildrenWithCleanup:YES];
    for (NSUInteger i = 0; i < _heroCard.bloodPointLimit; i++) {
        if (i >= _bloodPoint) {
            bloodImageName = (_player.isCurrentPlayer) ? kImageBloodEmptyBig : kImageBloodEmpty;
        }
        
        CCSprite *bloodSprite = [CCSprite spriteWithSpriteFrameName:bloodImageName];
        bloodSprite.position = ccpAdd(deltaPos, ccp(width*(i+1), height));
        [_spriteBatch addChild:bloodSprite z:0 tag:kHeroTagBlood];
    }
}

/*
 * Render hero anger point
 */
- (void)renderAngerPoint
{
    NSString *angerImageName;
    CGPoint deltaPos;
    CGFloat width, height, increment;
    
    [[_spriteBatch getChildByTag:kHeroTagAnger] removeFromParentAndCleanup:YES];
    
    if (_player.isCurrentPlayer) {
        angerImageName = kImageAngerBig;
        width = _playerAreaWidth*0.201;
        increment = _playerAreaHeight*0.83 / (_angerPoint + 1);
        height = increment + _playerAreaHeight*0.17;
    } else {
        angerImageName = kImageAnger;
//      Move position to left corner of player area for other players
        deltaPos = ccp(-_playerAreaWidth/2, -_playerAreaHeight/2);
        width = _playerAreaWidth*0.515;
        height = _playerAreaHeight / (_angerPoint + 1);
        increment = height;
    }
    
    for (NSUInteger i = 0; i < _angerPoint; i++) {
        CCSprite *angerSprite = [CCSprite spriteWithSpriteFrameName:angerImageName];
        angerSprite.position = ccpAdd(deltaPos, ccp(width, height+increment*i));
        [_spriteBatch addChild:angerSprite z:0 tag:kHeroTagAnger];
    }
}

- (void)updateBloodPointWithCount:(NSInteger)count
{
    BGEffectType effectType = (count > 0) ? kEffectTypeRestoreBlood : kEffectTypeDamaged;
    BGEffectComponent *effect = [BGEffectComponent effectCompWithEffectType:effectType];
    effect.position = ccp(_playerAreaWidth*0.099, _playerAreaHeight*0.643);
    [self addChild:effect];
    
    _bloodPoint += count;
    _bloodPoint = (_bloodPoint > _heroCard.bloodPointLimit) ? 0 : _bloodPoint;
    [self renderBloodPoint];
}

- (void)updateAngerPointWithCount:(NSInteger)count
{
    _angerPoint += count;
    _angerPoint = (_angerPoint > _heroCard.angerPointLimit) ? 0 : _angerPoint;
    [self renderAngerPoint];
}

#pragma mark - Hero avatar and skills touching
/*
 * Menu delegate method is called while touching a skill
 */
- (void)menuItemTouched:(CCMenuItem *)menuItem
{
//    if (_player.selectedHeroId != kHeroCardDefault) {
//        NSArray *cards = [NSArray arrayWithObjects:@(1), @(2), @(3), nil];
//        [_player.handArea addHandCardsWithCardIds:cards];
//        return; // Can not touch the hero of current player
//    }
    
    if ([menuItem.parent isEqual:_heroMenu]) {
        BGGameLayer *gamePlayer = [BGGameLayer sharedGameLayer];
        CCMenuItem *okayMenu = [gamePlayer.selfPlayer.playingMenu.menu.children objectAtIndex:kPlayingMenuItemTagOkay];
        NSAssert(okayMenu, @"okayMenu Nil in %@", NSStringFromSelector(_cmd));
        
        NSAssert(gamePlayer.targetPlayerNames, @"targetPlayerNames Nil in %@", NSStringFromSelector(_cmd));
        if ([gamePlayer.targetPlayerNames containsObject:_player.playerName]) {
            [gamePlayer.targetPlayerNames removeObject:_player.playerName];
            okayMenu.isEnabled = NO;
        } else {
            [gamePlayer.targetPlayerNames addObject:_player.playerName];
            okayMenu.isEnabled = YES;
        }
    }
    else {
        _player.usedHeroSkillId = menuItem.tag;
        _player.handArea.canSelectCardCount = 2;
        
//        if (_player.usedHeroSkillId == kHeroSkillLagunaBlade) {
//            
//        }
    }
}

@end
