//
//  BGMoveComponent.h
//  DotAHero
//
//  Created by Killua Liu on 6/11/13.
//
//

#import "CCNode.h"


@interface BGMoveComponent : CCNode

- (id)initWithNode:(CCNode *)node;
+ (id)moveWithNode:(CCNode *)node;

- (void)runActionEaseMoveWithTarget:(CGPoint)target duration:(ccTime)t block:(void(^)())block;
- (void)runActionEaseMoveWithTarget:(CGPoint)target duration:(ccTime)t object:(id)obj blockO:(void(^)(id object))block;
- (void)runActionEaseMoveScaleWithTarget:(CGPoint)target duration:(ccTime)t scale:(float)s block:(void(^)())block;

@end
