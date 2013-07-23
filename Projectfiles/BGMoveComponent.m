//
//  BGMoveComponent.m
//  DotAHero
//
//  Created by Killua Liu on 6/11/13.
//
//

#import "BGMoveComponent.h"

@interface BGMoveComponent ()

@property (nonatomic, readonly) CGPoint target;
@property (nonatomic, strong, readonly) CCNode *node;

@end

@implementation BGMoveComponent

- (id)initWithTarget:(CGPoint)target ofNode:(CCNode *)node
{
    if (self = [super init]) {
        _target = target;
        _node = node;
    }
    return self;
}

+ (id)moveWithTarget:(CGPoint)target ofNode:(CCNode *)node
{
    return [[self alloc] initWithTarget:target ofNode:node];
}

- (void)runActionEaseMoveWithDuration:(ccTime)t block:(void (^)())block
{
    CCMoveTo *move = [CCMoveTo actionWithDuration:t position:_target];
    CCActionEase *ease = [CCEaseExponentialOut actionWithAction:move];
    CCCallBlock *callBlock = [CCCallBlock actionWithBlock:block];
    
    [_node runAction:[CCSequence actions: ease, callBlock, nil]];
}

- (void)runActionEaseMoveScaleWithDuration:(ccTime)t scale:(float)s block:(void (^)())block
{
    CCMoveTo *move = [CCMoveTo actionWithDuration:t position:_target];
    CCActionEase *ease = [CCEaseExponentialOut actionWithAction:move];
    CCScaleTo *scale = [CCScaleTo actionWithDuration:t scale:s];
    CCCallBlock *callBlock = [CCCallBlock actionWithBlock:block];
    
	[_node runAction:ease];
    [_node runAction:[CCSequence actions: scale, callBlock, nil]];
}

@end
