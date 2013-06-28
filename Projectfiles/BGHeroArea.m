//
//  BGHeroArea.m
//  DotAHero
//
//  Created by Killua Liu on 5/30/13.
//
//

#import "BGHeroArea.h"
#import "BGCurrentPlayer.h"

@interface BGHeroArea ()

@property (nonatomic, strong) CCSpriteBatchNode *spriteBatch;
@property (nonatomic) CGRect playerAreaBox;

@end

@implementation BGHeroArea

- (id)initWithHeroCard:(BGHeroCard)card inPlayerAreaBox:(CGRect)playerAreaBox
{
    if (self = [super init]) {
        _heroCard = [BGHeroCardComponent heroCardComponentWithId:card];
        
        _healthPoint = _heroCard.healthPointLimit;
        _distance = 1;
        _attackRange = 1;
        _canBeTarget = YES;
        _usedSkill = -1;
        
        _playerAreaBox = playerAreaBox;
        [self renderSelectedHero];
    }
    return self;
}

+ (id)heroAreaWithHeroCard:(BGHeroCard)card inPlayerAreaBox:(CGRect)playerAreaBox
{
    return [[self alloc] initWithHeroCard:card inPlayerAreaBox:playerAreaBox];
}

- (void)renderSelectedHero
{
    self.spriteBatch = [CCSpriteBatchNode batchNodeWithFile:@"GameImage.pvr.ccz"];
    [self addChild:_spriteBatch];
    
    CGSize playerAreaSize = _playerAreaBox.size;
    
    CGFloat width = playerAreaSize.width*0.2 / (_healthPoint + 1);
    for (NSUInteger i = 0; i < _healthPoint; i++) {
        CCSprite *bloodSprite = [CCSprite spriteWithSpriteFrameName:@"BloodGreenBig.png"];
        bloodSprite.position = ccp(width*(i+1), playerAreaSize.height*0.305);
        [_spriteBatch addChild:bloodSprite];
    }
    
    CGFloat delta = playerAreaSize.height*0.17;
    CGFloat increment = (playerAreaSize.height - delta) / (3 + 1);
    CGFloat height = increment + delta;
    for (NSUInteger i = 0; i < 3; i++) {
        CCSprite *manaSprite = [CCSprite spriteWithSpriteFrameName:@"AngerBig.png"];
        manaSprite.position = ccp(playerAreaSize.width*0.2, height+increment*i);
        [_spriteBatch addChild:manaSprite];
    }
}

- (void)useSkill
{
    
}

@end
