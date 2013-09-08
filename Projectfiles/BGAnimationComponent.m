//
//  BGAnimationComponent.m
//  DotAHero
//
//  Created by Killua Liu on 7/10/13.
//
//

#import "BGAnimationComponent.h"
#import "BGDefines.h"
#import "BGGameLayer.h"
#import "BGAudioComponent.h"

@interface BGAnimationComponent ()

@property (nonatomic, strong) CCNode *node;

@end

@implementation BGAnimationComponent

- (id)initWithNode:(CCNode *)node
{
    if (self = [super init]) {
        _node = node;
    }
    return self;
}

+ (id)animationComponentWithNode:(CCNode *)node
{
    return [[self alloc] initWithNode:node];
}

- (void)runWithCard:(BGCard *)card scale:(float)scale
{
//    switch (card.cardEnum) {
//        case kPlayingCardNormalAttack:
//            [self normalAttack];
//            break;
//            
//        case kPlayingCardChaosAttack:
//            [self normalAttack];
//            break;
//            
//        case kPlayingCardFlameAttack:
//            [self normalAttack];
//            break;
//            
//        case kPlayingCardEvasion:
//            [self evasion];
//            break;
//            
//        default:
//            break;
//    }
}

- (void)runWithAnimationType:(BGAnimationType)type scale:(float)scale
{
//    switch (type) {
//        case kAnimationTypeDamaged:
//            [self damage];
//            break;
//            
//        case kAnimationTypeRestoreBlood:
//            [self restoreBlood];
//            break;
//            
//        default:
//            break;
//    }
}

- (void)runActionWithPlist:(NSString *)plist
                 frameName:(NSString *)frameName
                    frames:(NSString *)frame
                frameCount:(NSUInteger)count
                atPosition:(CGPoint)position
{
    CCSpriteFrameCache *spriteFrameCache = [CCSpriteFrameCache sharedSpriteFrameCache];
    [spriteFrameCache addSpriteFramesWithFile:plist];
    
    CCSprite *sprite = [CCSprite spriteWithSpriteFrameName:frameName];
    sprite.position = position;
    
    BGGameLayer *gameLayer = [BGGameLayer sharedGameLayer];
    float scale = ([gameLayer.currPlayer isEqual:gameLayer.selfPlayer]) ? SCALE_SELF_PLAYER_ANIMATION : SCALE_OTHER_PLAYER_ANIMATION;
    CCScaleTo *scaleTo = [CCScaleTo actionWithDuration:DURATION_CARD_ANIMATION_SCALE scale:scale];
    
    NSString *cacheName = frame;
    CCAnimation *animation = [[CCAnimationCache sharedAnimationCache] animationByName:cacheName];
    if (!animation) {
        animation = [CCAnimation animationWithFrames:frame frameCount:count delay:0.08f];
        [[CCAnimationCache sharedAnimationCache] addAnimation:animation name:cacheName];
    }
    CCAnimate *animate = [CCAnimate actionWithAnimation:animation];
    
    CCCallBlock *block = [CCCallBlock actionWithBlock:^{
        [sprite removeFromParentAndCleanup:YES];
    }];
    
    [sprite runAction:[CCSequence actions:scaleTo, animate, block, nil]];
    [_node addChild:sprite];
}

//- (void)damage
//{
//    
//    [self runActionScaleWithPlist:@"Damage.plist"
//                        frameName:@"Damage0.png"
//                           frames:@"Damage"
//                       frameCount:9
//                            scale:scale];
//    
//    [[BGAudioComponent sharedAudioComponent] playDamage];
//}
//
//- (void)restoreBlood
//{
//    [self runActionWithPlist:@"RestoreBlood.plist"
//                   frameName:@"RestoreBlood0.png"
//                      frames:@"RestoreBlood"
//               andFrameCount:20];
//    
//    [[BGAudioComponent sharedAudioComponent] playRestoreBlood];
//}
//
//- (void)normalAttack
//{
//    [self runActionWithPlist:@"NormalAttack.plist"
//                   frameName:@"NormalAttack0.png"
//                      frames:@"NormalAttack"
//               andFrameCount:29];
//}
//
//- (void)evasion
//{
//    [self runActionWithPlist:@"Evasion.plist"
//                   frameName:@"Evasion0.png"
//                      frames:@"Evasion"
//               andFrameCount:14];
//}
//
//- (void)healingSalve
//{
//    
//}
//
//- (void)SangeAndYasha
//{
//    [self runActionWithPlist:@"SangeAndYasha.plist"
//                   frameName:@"SangeAndYasha0.png"
//                      frames:@"SangeAndYasha"
//               andFrameCount:18];
//}

@end
