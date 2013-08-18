//
//  BGEffectComponent.m
//  DotAHero
//
//  Created by Killua Liu on 7/10/13.
//
//

#import "BGEffectComponent.h"
#import "BGAudioComponent.h"

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
//            [self healingSalve];
            break;
            
        case kPlayingCardSangeAndYasha:
//            [self SangeAndYasha];
            break;
            
        default:
            break;
    }
}

- (void)runEffectAnimationByEffectType
{
    switch (_effectType) {
        case kEffectTypeDamaged:
            [self damage];
            break;
            
        case kEffectTypeRestoreBlood:
            [self restoreBlood];
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
    
    [[BGAudioComponent sharedAudioComponent] playDamage];
}

- (void)restoreBlood
{
    [self runActionWithPlist:@"RestoreBlood.plist"
                   frameName:@"RestoreBlood0.png"
                      frames:@"RestoreBlood"
               andFrameCount:20];
    
    [[BGAudioComponent sharedAudioComponent] playRestoreBlood];
}

- (void)normalAttack
{
    [self runActionWithPlist:@"NormalAttack.plist"
                   frameName:@"NormalAttack0.png"
                      frames:@"NormalAttack"
               andFrameCount:29];
}

- (void)evasion
{
    [self runActionWithPlist:@"Evasion.plist"
                   frameName:@"Evasion0.png"
                      frames:@"Evasion"
               andFrameCount:14];
}

- (void)healingSalve
{
    
}

- (void)SangeAndYasha
{
    [self runActionWithPlist:@"SangeAndYasha.plist"
                   frameName:@"SangeAndYasha0.png"
                      frames:@"SangeAndYasha"
               andFrameCount:18];
}

@end
