//
//  BGAnimationComponent.m
//  DotAHero
//
//  Created by Killua Liu on 7/10/13.
//
//

#import "BGAnimationComponent.h"
#import "BGDefines.h"
#import "BGFileConstants.h"
#import "BGGameLayer.h"
#import "BGAudioComponent.h"

@interface BGAnimationComponent ()

@property (nonatomic, strong) CCNode *node;
@property (nonatomic, strong) NSDictionary *aniDict;

@end

@implementation BGAnimationComponent

- (id)initWithNode:(CCNode *)node
{
    if (self = [super init]) {
        _node = node;
        
        NSString *path = [[NSBundle mainBundle] pathForResource:kPlistCardAnimation ofType:kFileTypePlist];
        self.aniDict = [NSDictionary dictionaryWithContentsOfFile:path];
    }
    return self;
}

+ (id)animationComponentWithNode:(CCNode *)node
{
    return [[self alloc] initWithNode:node];
}

#pragma mark - Animation running
- (void)runWithCard:(BGCard *)card atPosition:(CGPoint)position
{
    NSDictionary *dict = _aniDict[card.cardName];
    if (!dict) return;
    
    [self runActionWithPlist:dict[kFileName]
                   frameName:dict[kFrameName]
                      frames:dict[kFrames]
                  frameCount:[dict[kFrameCount] integerValue]
                  atPosition:position];
    
//    switch (card.cardEnum) {
//        case kPlayingCardNormalAttack:
//            
//            break;
//            
//        default:
//            break;
//    }
}

- (void)runWithAnimationType:(BGAnimationType)type atPosition:(CGPoint)position
{
    NSDictionary *dict = _aniDict[@(type).stringValue];
    
    [self runActionWithPlist:dict[kFileName]
                   frameName:dict[kFrameName]
                      frames:dict[kFrames]
                  frameCount:[dict[kFrameCount] integerValue]
                  atPosition:position];
    
    switch (type) {
        case kAnimationTypeDamaged:
            [[BGAudioComponent sharedAudioComponent] playDamage];
            break;
            
        case kAnimationTypeRestoreBlood:
            [[BGAudioComponent sharedAudioComponent] playBloodRestore];
            break;
            
        default:
            break;
    }
}

- (void)runActionWithPlist:(NSString *)plist
                 frameName:(NSString *)frameName
                    frames:(NSString *)frame
                frameCount:(NSInteger)count
                atPosition:(CGPoint)position
{
    CCSpriteFrameCache *spriteFrameCache = [CCSpriteFrameCache sharedSpriteFrameCache];
    [spriteFrameCache addSpriteFramesWithFile:plist];
    
    CCSprite *sprite = [CCSprite spriteWithSpriteFrameName:frameName];
    sprite.position = position;
    
    BGGameLayer *gameLayer = [BGGameLayer sharedGameLayer];
    float scale = (gameLayer.turnOwner.isSelf) ? SCALE_SELF_PLAYER_ANIMATION : SCALE_OTHER_PLAYER_ANIMATION;
    CCScaleTo *scaleTo = [CCScaleTo actionWithDuration:DURATION_CARD_ANIMATION_SCALE scale:scale];
    
    NSString *cacheName = frame;
    CCAnimation *animation = [[CCAnimationCache sharedAnimationCache] animationByName:cacheName];
    if (!animation) {
        animation = [CCAnimation animationWithFrames:frame frameCount:count delay:DURATION_ANIMATION_DELAY];
        [[CCAnimationCache sharedAnimationCache] addAnimation:animation name:cacheName];
    }
    CCAnimate *animate = [CCAnimate actionWithAnimation:animation];
    
    CCCallBlock *block = [CCCallBlock actionWithBlock:^{
        [sprite removeFromParent];
    }];
    
    [sprite runAction:[CCSequence actions:scaleTo, animate, block, nil]];
    [_node addChild:sprite];
}

@end
