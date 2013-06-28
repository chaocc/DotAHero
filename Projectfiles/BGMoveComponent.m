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

- (void)runActionEaseMoveScale
{
    CCMoveTo *move = [CCMoveTo actionWithDuration:0.5f position:_target];
    CCActionEase *ease = [CCEaseExponentialOut actionWithAction:move];
    CCScaleTo *scale = [CCScaleTo actionWithDuration:0.5f scale:0.5f];
    
    CCCallBlock *block = [CCCallBlock actionWithBlock:^{
        [_node.parent removeAllChildrenWithCleanup:YES];
        [_delegate moveActionEnded:_node];
    }];
    
	[_node runAction:ease];
    [_node runAction:[CCSequence actions: scale, block, nil]];
}

@end
