//
//  BGMoveComponent.m
//  DotAHero
//
//  Created by Killua Liu on 6/11/13.
//
//

#import "BGMoveComponent.h"

@interface BGMoveComponent ()

@property (nonatomic, strong, readonly) CCNode *node;

@end

@implementation BGMoveComponent

- (id)initWithNode:(CCNode *)node
{
    if (self = [super init]) {
        _node = node;
    }
    return self;
}

+ (id)moveWithNode:(CCNode *)node
{
    return [[self alloc] initWithNode:node];
}

- (void)runActionEaseMoveWithTarget:(CGPoint)target duration:(ccTime)t block:(void (^)())block
{
    CCMoveTo *move = [CCMoveTo actionWithDuration:t position:target];
    CCActionEase *ease = [CCEaseExponentialOut actionWithAction:move];
    
    NSMutableArray *array = [NSMutableArray array];
    [array addObject:ease];
    if (block) {
        [array addObject:[CCCallBlock actionWithBlock:block]];
    }
    
    [_node runAction:[CCSequence actionWithArray:array]];
}

- (void)runActionEaseMoveWithTarget:(CGPoint)target duration:(ccTime)t object:(id)obj blockO:(void (^)(id))block
{
    CCMoveTo *move = [CCMoveTo actionWithDuration:t position:target];
    CCActionEase *ease = [CCEaseExponentialOut actionWithAction:move];
    
    NSMutableArray *array = [NSMutableArray array];
    [array addObject:ease];
    if (block) {
        [array addObject:[CCCallBlockO actionWithBlock:block object:obj]];
    }
    
    [_node runAction:[CCSequence actionWithArray:array]];
}

- (void)runActionEaseMoveScaleWithTarget:(CGPoint)target duration:(ccTime)t scale:(float)s block:(void (^)())block
{
    CCMoveTo *move = [CCMoveTo actionWithDuration:t position:target];
    CCActionEase *ease = [CCEaseExponentialOut actionWithAction:move];
    CCScaleTo *scale = [CCScaleTo actionWithDuration:t scale:s];
    
    NSMutableArray *array = [NSMutableArray array];
    [array addObject:scale];
    if (block) {
        [array addObject:[CCCallBlock actionWithBlock:block]];
    }
    
    [_node runAction:ease];
    [_node runAction:[CCSequence actionWithArray:array]];
}

@end
