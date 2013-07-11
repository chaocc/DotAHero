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
#import "BGFileConstants.h"

@interface BGHeroArea ()

@property (nonatomic, weak) BGPlayer *player;

@end

@implementation BGHeroArea

- (id)initWithHeroCardId:(NSUInteger)cardId ofPlayer:(BGPlayer *)player
{
    if (self = [super init]) {
        _player = player;
        
        _heroCard = [BGHeroCard cardWithCardId:cardId];
        _healthPoint = _heroCard.healthPointLimit;
        _distance = 1;
        _attackRange = 1;
        _canBeTarget = YES;
        _usedSkill = -1;
        
        [self renderSelectedHero];
    }
    return self;
}

+ (id)heroAreaWithHeroCardId:(NSUInteger)cardId ofPlayer:(BGPlayer *)player
{
    return [[self alloc] initWithHeroCardId:cardId ofPlayer:player];
}

/*
 * 1. Current player's position is (0,0) at left-bottom corner, hero area's position also (0,0).
 * 2. Other player's position is setted(not 0) in class BGGameLayer, its position should be the center of player area. 
 *    But as for its hero area, it is also (0,0) at the center. Becasue hero area is child node of player.
 */
- (void)renderSelectedHero
{
    CGFloat playerAreaWidth = _player.playerAreaSize.width;
    CGFloat playerAreaHeight = _player.playerAreaSize.height;
    
//  Render hero avatar
    NSString *avatarName =( _player.isCurrentPlayer) ? _heroCard.bigAvatarName : _heroCard.avatarName;
    BGMenuFactory *menuFactory = [BGMenuFactory menuFactory];
    CCMenu *heroMenu = [menuFactory createMenuWithSpriteFrameName:avatarName
                                                selectedFrameName:nil
                                                disabledFrameName:nil];
    heroMenu.position = (_player.isCurrentPlayer) ? ccp(playerAreaWidth*0.099, playerAreaHeight*0.643) : ccp(-playerAreaWidth*0.245, playerAreaHeight*0.045);
    [self addChild:heroMenu];
    menuFactory.delegate = self;
    
//  Render hero skills
    if (_player.isCurrentPlayer) {
        
    }
    
//  Render blood and anger point of hero
    CCSpriteBatchNode *spriteBatch = [CCSpriteBatchNode batchNodeWithFile:kZlibHeroAvatar];
    [self addChild:spriteBatch];
    
    NSString *bloodImageName, *angerImageName;
    CGPoint deltaPos;
    CGFloat width, height, increment;
    
    if (_player.isCurrentPlayer) {
        bloodImageName = kImageBloodGreenBig;
        width = playerAreaWidth*0.2 / (_healthPoint + 1);
        height = playerAreaHeight*0.305;
    } else {
        bloodImageName = kImageBloodGreen;
        // Move position to left corner of player area for other players
        deltaPos = ccp(-playerAreaWidth/2, -playerAreaHeight/2);
        width = playerAreaWidth*0.5 / (_healthPoint + 1);
        height = playerAreaHeight*0.135;
    }
    
    for (NSUInteger i = 0; i < _healthPoint; i++) {
        CCSprite *bloodSprite = [CCSprite spriteWithSpriteFrameName:bloodImageName];
        bloodSprite.position = ccpAdd(deltaPos, ccp(width*(i+1), height));
        [spriteBatch addChild:bloodSprite];
    }
    
////  Render Anger
//    if (_player.isCurrentPlayer) {
//        angerImageName = kImageAngerBig;
//        width = playerAreaWidth*0.2;
//        increment = playerAreaHeight*0.83 / (3 + 1);
//        height = increment + playerAreaHeight*0.17;
//    } else {
//        angerImageName = kImageAnger;
//        width = playerAreaWidth*0.515;
//        height = playerAreaHeight / (3 + 1);
//        increment = height;
//    }
//    
//    for (NSUInteger i = 0; i < 3; i++) {
//        CCSprite *angerSprite = [CCSprite spriteWithSpriteFrameName:angerImageName];
//        angerSprite.position = ccpAdd(deltaPos, ccp(width, height+increment*i));
//        [spriteBatch addChild:angerSprite];
//    }
}

#pragma mark - Menu Factory Delegate
- (void)menuItemTouched:(CCMenuItem *)menuItem
{
    NSAssert([menuItem isKindOfClass:[CCMenuItem class]], @"Not a CCMenuItem");
    
    NSArray *playingCardIds = [NSArray arrayWithObjects:@(rand()%7), @(rand()%7), nil];
    [_player.playingArea addPlayingCardsWithCardIds:playingCardIds];
}

- (void)useSkill
{
    
}

@end
