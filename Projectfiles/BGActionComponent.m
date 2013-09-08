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

- (void)runEaseMoveWithTarget:(CGPoint)target duration:(ccTime)t block:(void (^)())block
{
    CCMoveTo *move = [CCMoveTo actionWithDuration:t position:target];
    CCActionEase *ease = [CCEaseExponentialOut actionWithAction:move];
    
    NSMutableArray *array = [NSMutableArray arrayWithObject:ease];
    if (block) {
        [array addObject:[CCCallBlock actionWithBlock:block]];
    }
    
    [_node runAction:[CCSequence actionWithArray:array]];
}

- (void)runEaseMoveWithTarget:(CGPoint)target duration:(ccTime)t object:(id)obj block:(void (^)(id))block
{
    CCMoveTo *move = [CCMoveTo actionWithDuration:t position:target];
    CCActionEase *ease = [CCEaseExponentialInOut actionWithAction:move];
    
    NSMutableArray *array = [NSMutableArray arrayWithObject:ease];
    if (block) {
        [array addObject:[CCCallBlockO actionWithBlock:block object:obj]];
    }
    
    [_node runAction:[CCSequence actionWithArray:array]];
}

- (void)runEaseMoveScaleWithTarget:(CGPoint)target duration:(ccTime)t scale:(float)s block:(void (^)())block
{
    CCMoveTo *move = [CCMoveTo actionWithDuration:t position:target];
    CCActionEase *ease = [CCEaseExponentialOut actionWithAction:move];
    CCScaleTo *scale = [CCScaleTo actionWithDuration:t scale:s];
    
    NSMutableArray *array = [NSMutableArray arrayWithObject:scale];
    if (block) {
        [array addObject:[CCCallBlock actionWithBlock:block]];
    }
    
    [_node runAction:ease];
    [_node runAction:[CCSequence actionWithArray:array]];
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

- (void)runScaleUpAndReverse
{
    CCScaleTo *scale = [CCScaleTo actionWithDuration:DURATION_CARD_SCALE scale:SCALE_CARD_UP];
    CCActionEase *ease = [CCEaseExponentialOut actionWithAction:scale];
    CCDelayTime *delay = [CCDelayTime actionWithDuration:DURATION_CARD_SCALE_DELAY];
    CCScaleTo *reverse = [CCScaleTo actionWithDuration:DURATION_CARD_SCALE scale:SCALE_CARD_ORGINAL];
    [_node runAction:[CCSequence actions:ease, delay, reverse, nil]];
}

- (void)runDelayWithDuration:(ccTime)time WithBlock:(void (^)())block
{
    if (block) {
        CCDelayTime *delay = [CCDelayTime actionWithDuration:time];
        CCCallBlock *callBlock = [CCCallBlock actionWithBlock:block];
        [_node runAction:[CCSequence actions:delay, callBlock, nil]];
    }
}

@end
