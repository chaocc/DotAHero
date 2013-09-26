//
//  BGActionComponent.m
//  DotAHero
//
//  Created by Killua Liu on 6/11/13.
//
//

#import "BGActionComponent.h"
#import "BGDefines.h"

@interface BGActionComponent ()

@property (nonatomic, strong) CCNode *node;

@end

@implementation BGActionComponent

- (id)initWithNode:(CCNode *)node
{
    if (self = [super init]) {
        _node = node;
    }
    return self;
}

+ (id)actionComponentWithNode:(CCNode *)node
{
    return [[self alloc] initWithNode:node];
}

#pragma mark - Action running
- (void)runEaseMoveWithTarget:(CGPoint)target duration:(ccTime)t block:(void (^)())block
{
    CCMoveTo *move = [CCMoveTo actionWithDuration:t position:target];
    CCActionEase *ease = [CCEaseExponentialOut actionWithAction:move];
    CCCallBlock *callBlock = (block) ? [CCCallBlock actionWithBlock:block] : nil;
    
    [_node runAction:[CCSequence actions:ease, callBlock, nil]];
}

- (void)runEaseMoveWithTarget:(CGPoint)target duration:(ccTime)t object:(id)obj block:(void (^)(id))block
{
    CCMoveTo *move = [CCMoveTo actionWithDuration:t position:target];
    CCActionEase *ease = [CCEaseExponentialOut actionWithAction:move];
    CCCallBlockO *callBlock = (block) ? [CCCallBlockO actionWithBlock:block object:obj] : nil;
    
    [_node runAction:[CCSequence actions:ease, callBlock, nil]];
}

- (void)runEaseMoveScaleWithTarget:(CGPoint)target duration:(ccTime)t scale:(float)s block:(void (^)())block
{
    CCMoveTo *move = [CCMoveTo actionWithDuration:t position:target];
    CCActionEase *ease = [CCEaseExponentialOut actionWithAction:move];
    
    CCScaleTo *scale = [CCScaleTo actionWithDuration:t scale:s];
    CCCallBlock *callBlock = (block) ? [CCCallBlock actionWithBlock:block] : nil;
    
    [_node runAction:ease];
    [_node runAction:[CCSequence actions:scale, callBlock, nil]];
}

- (void)runFadeInWithDuration:(ccTime)t block:(void (^)())block
{
    CCFadeIn *fade = [CCFadeIn actionWithDuration:t];
    CCCallBlock *callBlock = (block) ? [CCCallBlock actionWithBlock:block] : nil;
    
    [_node runAction:[CCSequence actions:fade, callBlock, nil]];
}

- (void)runFadeOutWithDuration:(ccTime)t block:(void (^)(CCNode *))block
{
    CCFadeOut *fade = [CCFadeOut actionWithDuration:t];
    CCCallBlockN *callBlock = (block) ? [CCCallBlockN actionWithBlock:block] : nil;

    [_node runAction:[CCSequence actions:fade, callBlock, nil]];
}

- (void)runFlipFromLeftWithDuration:(ccTime)t toNode:(CCNode *)tarNode
{
    CCOrbitCamera *orbit = [CCOrbitCamera actionWithDuration:t
                                                      radius:1.0f
                                                 deltaRadius:0.0f
                                                      angleZ:0.0f
                                                 deltaAngleZ:-90.0f
                                                      angleX:0.0f
                                                 deltaAngleX:0.0f];
    
    NSMutableArray *array = [NSMutableArray arrayWithObject:orbit];
    [array addObject:[CCCallBlock actionWithBlock:^{
        [_node removeFromParent];
        tarNode.visible = YES;
        
        CCOrbitCamera *orbit = [CCOrbitCamera actionWithDuration:t
                                                          radius:1.0f
                                                     deltaRadius:0.0f
                                                          angleZ:-270.0f
                                                     deltaAngleZ:-90.0f
                                                          angleX:0.0f
                                                     deltaAngleX:0.0f];
        [tarNode runAction:orbit];
    }]];
    
    [_node runAction:[CCSequence actionWithArray:array]];
}

- (void)runScaleUpAndReverseWithDuration:(ccTime)t scale:(float)s block:(void (^)())block
{
    CCScaleTo *scale = [CCScaleTo actionWithDuration:t scale:s];
    CCActionEase *ease = [CCEaseExponentialOut actionWithAction:scale];
    CCDelayTime *delay = [CCDelayTime actionWithDuration:DURATION_CARD_SCALE_DELAY];
    CCScaleTo *reverse = [CCScaleTo actionWithDuration:t scale:SCALE_CARD_INITIAL];
    CCCallBlock *callBlock = (block) ? [CCCallBlock actionWithBlock:block] : nil;
    
    [_node runAction:[CCSequence actions:ease, delay, reverse, callBlock, nil]];
}

- (void)runDelayWithDuration:(ccTime)time withBlock:(void (^)())block
{
    CCDelayTime *delay = [CCDelayTime actionWithDuration:time];
    CCCallBlock *callBlock = (block) ? [CCCallBlock actionWithBlock:block] : nil;
    
    [_node runAction:[CCSequence actions:delay, callBlock, nil]];
}

- (void)runProgressBarWithDuration:(ccTime)t block:(void (^)())block
{
    CCProgressFromTo *progress = [CCProgressFromTo actionWithDuration:t from:100.0f to:0.0f];
    CCCallBlock *callBlock = (block) ? [CCCallBlock actionWithBlock:block] : nil;
    
    [_node runAction:[CCSequence actions:progress, callBlock, nil]];
}

@end
