//
//  BGOtherPlayer.m
//  DotAHero
//
//  Created by Killua Liu on 6/27/13.
//
//

#import "BGOtherPlayer.h"

@interface BGOtherPlayer ()

@property (nonatomic, strong) CCSpriteBatchNode *spriteBatch;
@property (nonatomic) CGSize playerAreaSize;

@end

@implementation BGOtherPlayer

- (id)initWithName:(NSString *)name andHeroCard:(BGHeroCard)card
{
    if (self = [super init]) {
        _playerName = name;
        _heroCard = [BGHeroCardComponent heroCardComponentWithId:card];
        
        [self renderPlayerArea];
        [self renderHero];
    }
    return self;
}

+ (id)otherPlayerWithName:(NSString *)name andHeroCard:(BGHeroCard)card
{
    return [[self alloc] initWithName:name andHeroCard:card];
}

- (void)renderPlayerArea
{
    CCSprite *sprite = [CCSprite spriteWithSpriteFrameName:@"OtherPlayerArea.png"];
    _playerAreaSize = sprite.contentSize;
    [self addChild:sprite];
}

- (void)renderHero
{
    self.spriteBatch = [CCSpriteBatchNode batchNodeWithFile:@"GameImage.pvr.ccz"];
    [self addChild:_spriteBatch];
    
    CGFloat deltaX = self.position.x - _playerAreaSize.width/2;
    CGFloat deltaY = self.position.y - _playerAreaSize.height/2;

    CGFloat width = _playerAreaSize.width*0.5 / (_heroCard.healthPointLimit + 1);
    for (NSUInteger i = 0; i < _heroCard.healthPointLimit; i++) {
        CCSprite *bloodSprite = [CCSprite spriteWithSpriteFrameName:@"BloodGreen.png"];
        bloodSprite.position = ccp(deltaX + width*(i+1), deltaY + _playerAreaSize.height*0.135);
        [_spriteBatch addChild:bloodSprite];
    }
    
    CGFloat height = _playerAreaSize.height / (3 + 1);
    for (NSUInteger i = 0; i < 3; i++) {
        CCSprite *manaSprite = [CCSprite spriteWithSpriteFrameName:@"Anger.png"];
        manaSprite.position = ccp(deltaX + _playerAreaSize.width*0.515, deltaY + height*(i+1));
        [_spriteBatch addChild:manaSprite];
    }
}

@end
