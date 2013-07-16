//
//  BGEffectComponent.m
//  DotAHero
//
//  Created by Killua Liu on 7/10/13.
//
//

#import "BGEffectComponent.h"

@implementation BGEffectComponent

- (id)initWithPlayingCardEnum:(BGPlayingCardEnum)cardEnum
{
    if (self = [super init]) {
        _playingCardEnum = cardEnum;
        
        self.position = ccp(512, 650);   // Passed in
        [self runEffectAnimation];
    }
    return self;
}

+ (id)effectCompWithPlayingCardEnum:(BGPlayingCardEnum)cardEnum
{
    return [[self alloc] initWithPlayingCardEnum:cardEnum];
}

- (void)runEffectAnimation
{
    switch (_playingCardEnum) {
        case kPlayingCardNormalAttack:
            [self normalAttack];
            break;
            
        case kPlayingCardChaosAttack:
            [self damage];
            break;
            
        case kPlayingCardHealingSalve:
            [self healingSalve];
            break;
            
        case kPlayingCardSangeAndYasha:
            [self SangeAndYasha];
            break;
            
        default:
            break;
    }
}

- (void)runActionWithPlist:(NSString *)plist frameName:(NSString *)frameName frames:(NSString *)frame andFrameCount:(NSUInteger)count
{
    CCSpriteFrameCache *spriteFrameCache = [CCSpriteFrameCache sharedSpriteFrameCache];
    [spriteFrameCache addSpriteFramesWithFile:plist];
    
    CCSprite *sprite = [CCSprite spriteWithSpriteFrameName:frameName];
//    sprite.position = [CCDirector sharedDirector].screenCenter;
    
    CCScaleTo *scale = [CCScaleTo actionWithDuration:0.1f scale:1.0f];
    
    CCAnimation *animation = [CCAnimation animationWithFrames:frame frameCount:count delay:0.08f];
    CCAnimate *animate = [CCAnimate actionWithAnimation:animation];
    
    CCCallBlock *block = [CCCallBlock actionWithBlock:^{
        [self removeFromParentAndCleanup:YES];
    }];
    
    [sprite runAction:[CCSequence actions:scale, animate, block, nil]];
    [self addChild:sprite];
}

- (void)damage
{
    [self runActionWithPlist:@"Damage.plist"
                   frameName:@"Damage0.png"
                      frames:@"Damage"
               andFrameCount:9];
}

- (void)normalAttack
{
    [self runActionWithPlist:@"NormalAttack.plist"
                   frameName:@"NormalAttack0.png"
                      frames:@"NormalAttack"
               andFrameCount:14];
}

- (void)healingSalve
{
    [self runActionWithPlist:@"HealingSalve.plist"
                   frameName:@"HealingSalve0.png"
                      frames:@"HealingSalve"
               andFrameCount:20];
}

- (void)SangeAndYasha
{
    [self runActionWithPlist:@"SangeAndYasha.plist"
                   frameName:@"SangeAndYasha0.png"
                      frames:@"SangeAndYasha"
               andFrameCount:23];
}

@end
