//
//  BGHeroArea.m
//  DotAHero
//
//  Created by Killua Liu on 5/30/13.
//
//

#import "BGHeroArea.h"
#import "BGGameLayer.h"
#import "BGHeroSkill.h"
#import "BGFileConstants.h"
#import "BGAnimationComponent.h"
#import "BGDefines.h"

typedef NS_ENUM(NSInteger, BGHeroTag) {
    kHeroTagBlood = 200,
    kHeroTagAnger = 210
};

@interface BGHeroArea ()

@property (nonatomic, weak) BGGameLayer *gameLayer;
@property (nonatomic, weak) BGPlayer *player;
@property (nonatomic) CGFloat playerAreaWidth, playerAreaHeight;
@property (nonatomic, strong) CCSpriteBatchNode *hpSpBatch;
@property (nonatomic, strong) BGMenuFactory *menuFactory;
@property (nonatomic, strong) CCMenu *heroMenu;
@property (nonatomic, strong) CCMenu *skillMenu;

@end

@implementation BGHeroArea

- (id)initWithPlayer:(BGPlayer *)player
{
    if (self = [super init]) {
        _gameLayer = [BGGameLayer sharedGameLayer];
        _player = player;
        
        _playerAreaWidth = _player.contentSize.width;
        _playerAreaHeight = _player.contentSize.height;
        
        _menuFactory = [BGMenuFactory menuFactory];
        _menuFactory.delegate = self;
        
        _hpSpBatch = [CCSpriteBatchNode batchNodeWithFile:kZlibGameArtwork];
        [self addChild:_hpSpBatch];
        
        [self scheduleUpdate];
    }
    return self;
}

+ (id)heroAreaWithPlayer:(BGPlayer *)player
{
    return [[self alloc] initWithPlayer:player];
}

#pragma mark - Hero rendering
- (void)renderHeroWithHeroId:(NSInteger)heroId
{
    _heroCard = [BGHeroCard cardWithCardId:heroId];
    _bloodPoint = _heroCard.bloodPointLimit;
    _angerPoint = 0;
    
    [self renderSelectedHero];
}

/*
 * 1. Self player's position is (0,0) at left-bottom corner, hero area's position also (0,0).
 * 2. Other player's position is setted(not 0) in class BGGameLayer, its position should be the center of player area. 
 *    But as for its hero area, it is also (0,0) at the center. Becasue hero area is child node of player.
 */
- (void)renderSelectedHero
{
//  Render hero avatar
    NSString *avatarName =( _player.isSelfPlayer) ? _heroCard.bigAvatarName : _heroCard.avatarName;
    _heroMenu = [_menuFactory createMenuWithSpriteFrameName:avatarName
                                          selectedFrameName:nil
                                          disabledFrameName:nil];
    _heroMenu.enabled = NO;
    _heroMenu.position = (_player.isSelfPlayer) ?
        ccp(_playerAreaWidth*0.09, _playerAreaHeight*0.65) :
        ccp(-_playerAreaWidth*0.26, _playerAreaHeight*0.03);
    [_heroMenu.children.lastObject setTag:_heroCard.cardId];
    [self addChild:_heroMenu];
    
//  Render hero blood point
    [self renderBloodPoint];
    
//  Render hero skills if self player
    if (_player.isSelfPlayer) {
        [self renderHeroSkills];
    }
}

/*
 * Render hero skills of self player
 */
- (void)renderHeroSkills
{
    NSUInteger skillCount = _heroCard.heroSkills.count;
    NSMutableArray *frameNames = [NSMutableArray arrayWithCapacity:skillCount];
    NSMutableArray *selFrameNames = [NSMutableArray arrayWithCapacity:skillCount];
    
    [_heroCard.heroSkills enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        BGHeroSkill *skill = [BGHeroSkill heroSkillWithSkillId:[obj integerValue]];
        
        NSString *frameName, *selFrameName;
        if (kHeroSkillCategoryActive == skill.skillCategory) {
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
    _skillMenu.enabled = NO;
    _skillMenu.position = ccp(_playerAreaWidth*0.107, _playerAreaHeight*0.14);
    [_skillMenu alignItemsHorizontallyWithPadding:PADDING_SKILL_BUTTON];
    [self addChild:_skillMenu];
    
//  Add label text to menu and disable passive skill menu
    [[_skillMenu.children getNSArray] enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        CCMenuItem *menuItem = obj;
        BGHeroSkill *skill = [BGHeroSkill heroSkillWithSkillId:[_heroCard.heroSkills[idx] integerValue]];
        menuItem.tag = skill.skillId;
        
        CGPoint anchorPoint = ccp(0.5f, 0.0f);
        if ((3 == skillCount) && (skill.skillText.length >= 4)) {
            skill.skillText = [[skill.skillText substringToIndex:2] stringByAppendingFormat:@"\n%@", [skill.skillText substringFromIndex:2]];
            anchorPoint = ccp(0.5f, 0.3f);
        }
        
        CCLabelBMFont *label = [CCLabelBMFont labelWithString:skill.skillText fntFile:kFontHeroSkillName];
        label.anchorPoint = anchorPoint;
        label.position = ccp(menuItem.contentSize.width/2, menuItem.contentSize.height/2);
        [menuItem addChild:label];
        menuItem.isEnabled = (kHeroSkillCategoryActive == skill.skillCategory);
    }];
}

/*
 * Render hero blood point
 */
- (void)renderBloodPoint
{
    NSString *bloodImageName;
    CGPoint basePos = CGPointZero;
    CGFloat width, height;
    
//  Remove previous blood sprites
    for (NSInteger i = 0; i < _heroCard.bloodPointLimit; i++) {
        [[_hpSpBatch getChildByTag:kHeroTagBlood+i] removeFromParent];
    }
    
//  Render
    if (_player.isSelfPlayer) {
        if (1 == _bloodPoint) {
            bloodImageName = kImageBloodRedBig;
        } else if (2 == _bloodPoint) {
            bloodImageName = kImageBloodYellowBig;
        } else {
            bloodImageName = kImageBloodGreenBig;
        }
        width = _playerAreaWidth*0.18 / (_heroCard.bloodPointLimit + 1);
        height = _playerAreaHeight*0.304;
    }
    else {
        if (1 == _bloodPoint) {
            bloodImageName = kImageBloodRed;
        } else if (2 == _bloodPoint) {
            bloodImageName = kImageBloodYellow;
        } else {
            bloodImageName = kImageBloodGreen;
        }
//      Move position to left corner of player area for other players
        basePos = ccp(-_playerAreaWidth/2, -_playerAreaHeight/2);
        width = _playerAreaWidth*0.47 / (_heroCard.bloodPointLimit + 1);
        height = _playerAreaHeight*0.094;
    }
    
    for (NSInteger i = 0; i < _heroCard.bloodPointLimit; i++) {
        if ((NSInteger)i >= _bloodPoint) {
            bloodImageName = (_player.isSelfPlayer) ? kImageBloodEmptyBig : kImageBloodEmpty;
        }
        
        CCSprite *bloodSprite = [CCSprite spriteWithSpriteFrameName:bloodImageName];
        bloodSprite.position = ccpAdd(basePos, ccp(width*(i+1), height));
        [_hpSpBatch addChild:bloodSprite z:0 tag:kHeroTagBlood+i];
    }
}

/*
 * Render hero anger point
 */
- (void)renderAngerPoint
{
    NSString *angerImageName;
    CGPoint basePos = CGPointZero;
    CGFloat width, height, increment;
    
//  Remove previous anger sprites
    for (NSUInteger i = 0; i < _heroCard.angerPointLimit; i++) {
        [[_hpSpBatch getChildByTag:kHeroTagAnger+i] removeFromParent];
    }
    
//  Render
    if (_player.isSelfPlayer) {
        angerImageName = kImageAngerBig;
        width = _playerAreaWidth*0.195;
        increment = _playerAreaHeight*0.83 / (_angerPoint + 1);
        height = increment + _playerAreaHeight*0.17;
    }
    else {
        angerImageName = kImageAnger;
//      Move position to left corner of player area for other players
        basePos = ccp(-_playerAreaWidth/2, -_playerAreaHeight/2);
        width = _playerAreaWidth*0.515;
        increment = _playerAreaHeight*0.95 / (_angerPoint + 1);
        height = increment;
    }
    
    for (NSUInteger i = 0; i < _angerPoint; i++) {
        CCSprite *angerSprite = [CCSprite spriteWithSpriteFrameName:angerImageName];
        angerSprite.position = ccpAdd(basePos, ccp(width, height+increment*i));
        [_hpSpBatch addChild:angerSprite z:0 tag:kHeroTagAnger+i];
    }
}

#pragma mark - Enablement and color
- (void)enableHero
{
    _heroMenu.enabled = YES;
    _skillMenu.enabled = YES;
}

- (void)disableHero
{
    _heroMenu.enabled = NO;
    _skillMenu.enabled = NO;
}

#pragma mark - Hero updating
- (void)updateBloodPointWithCount:(NSInteger)count
{
    if (count == 0) return;
    
    BGAnimationType type = (count < 0) ? kAnimationTypeDamaged : kAnimationTypeRestoreBlood;
    CGPoint position = (_player.isSelfPlayer) ?
        ccp(_playerAreaWidth*0.1, _playerAreaHeight*0.67) :
        ccp(-_playerAreaWidth*0.2, _playerAreaHeight*0.1);
    BGAnimationComponent *aniComp = [BGAnimationComponent animationComponentWithNode:self];
    [aniComp runWithAnimationType:type atPosition:position];
    
//  Re-render blood point
    _bloodPoint += count;
    [self renderBloodPoint];
    
    NSAssert(_bloodPoint <= _heroCard.bloodPointLimit, @"Blood exceed limit in %@", NSStringFromSelector(_cmd));
}

- (void)updateAngerPointWithCount:(NSInteger)count
{
    if (count == 0 || ((NSInteger)_angerPoint+count) < 0) return;
    
    _angerPoint += count;
    [self renderAngerPoint];
    
    NSAssert(_angerPoint <= _heroCard.angerPointLimit, @"Anger exceed limit in %@", NSStringFromSelector(_cmd));
}

#pragma mark - Hero avatar/skills touching
/*
 * Menu delegate method is called while touching target player's hero or self hero's skill
 */
- (void)menuItemTouched:(CCMenuItem *)menuItem
{
    if ([menuItem.parent isEqual:_heroMenu]) {
        [self selectTargetPlayerByTouchingMenuItem:menuItem];
    }
    else if ([menuItem.parent isEqual:_skillMenu]) {
        _player.selectedSkillId = menuItem.tag;
    }
}

/*
 * Select other player as target player
 * First touching is selected, second is removed.
 */
- (void)selectTargetPlayerByTouchingMenuItem:(CCMenuItem *)menuItem
{
    BGPlayer *selfPlayer = _gameLayer.selfPlayer;
    CCMenuItem *okayMenu = [selfPlayer.playingMenu menuItemByTag:kPlayingMenuItemTagOkay];
    CCMenuItem *strenMenu = [selfPlayer.playingMenu menuItemByTag:kPlayingMenuItemTagStrengthen];
    
    NSMutableArray *tarPlayerNames = _gameLayer.targetPlayerNames;
    NSAssert(tarPlayerNames, @"targetPlayerNames Nil in %@", NSStringFromSelector(_cmd));
    
    if ([tarPlayerNames containsObject:_player.playerName]) {
        [tarPlayerNames removeObject:_player.playerName];
        okayMenu.isEnabled = NO;
    }
    else {
        [tarPlayerNames addObject:_player.playerName];
//      If great than selectable target count, need remove the first selected target player.
        if (tarPlayerNames.count > selfPlayer.selectableTargetCount) {
            [tarPlayerNames removeObjectAtIndex:0];
        }
        okayMenu.isEnabled = (tarPlayerNames.count == selfPlayer.selectableTargetCount);
    }
    
    if (strenMenu) {
        strenMenu.isEnabled = okayMenu.isEnabled;
    }
}

//- (void)checkTargetPlayerOfMislead
//{
//    for (NSUInteger i = 0; i < _gameLayer.playerCount; i++) {
//        BGPlayer *player = _gameLayer.allPlayers[i];
//        
//        if (player.heroArea.angerPoint > 0) {
//            [player enablePlayerArea];
//        } else {
//            [player disablePlayerAreaWithDarkColor];
//        }
//    }
//}

#pragma mark - Gestures
- (void)update:(ccTime)delta
{
    if ([CCDirector sharedDirector].currentPlatformIsIOS) {
        [self gestureRecognition];
    }
    else if ([CCDirector sharedDirector].currentPlatformIsMac) {
        
    }
}

- (void)gestureRecognition
{
    KKInput *input = [KKInput sharedInput];
    
    if (![input isAnyTouchOnNode:_heroMenu.children.lastObject touchPhase:KKTouchPhaseAny]) {
        return;
    }
    
    if (input.gestureDoubleTapRecognizedThisFrame || input.gestureLongPressBegan) {
        
    }
}

@end
