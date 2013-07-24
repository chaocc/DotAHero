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
        
        [self runEffectAnimationByCard];
    }
    return self;
}

+ (id)effectCompWithPlayingCardEnum:(BGPlayingCardEnum)cardEnum
{
    return [[self alloc] initWithPlayingCardEnum:cardEnum];
}

- (id)initWithEffectType:(BGEffectType)effectType
{
    if (self = [super init]) {
        _effectType = effectType;
        
        [self runEffectAnimationByEffectType];
    }
    return self;
}

+ (id)effectCompWithEffectType:(BGEffectType)effectType
{
    return [[self alloc] initWithEffectType:effectType];
}

- (void)runEffectAnimationByCard
{
    switch (_playingCardEnum) {
        case kPlayingCardNormalAttack:
            [self normalAttack];
            break;
            
        case kPlayingCardChaosAttack:
            [self normalAttack];
            break;
            
        case kPlayingCardFlameAttack:
            [self normalAttack];
            break;
            
        case kPlayingCardEvasion:
            [self evasion];
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

- (void)runEffectAnimationByEffectType
{
    switch (_playingCardEnum) {
        case kEffectTypeDamaged:
            [self damage];
            break;
            
        case kEffectTypeRestoreBlood:
            
            break;
            
        case kEffectTypeGotAnger:
            
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
               andFrameCount:15];
}

- (void)evasion
{
    [self runActionWithPlist:@"Evasion.plist"
                   frameName:@"Evasion0.png"
                      frames:@"Evasion"
               andFrameCount:12];
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
