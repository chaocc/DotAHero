//
//  BGActionComponent.h
//  DotAHero
//
//  Created by Killua Liu on 6/11/13.
//
//

#import <Foundation/Foundation.h>

@interface BGActionComponent : NSObject

- (id)initWithNode:(CCNode *)node;
+ (id)actionComponentWithNode:(CCNode *)node;

- (void)runEaseMoveWithTarget:(CGPoint)target duration:(ccTime)t block:(void(^)())block;
- (void)runEaseMoveWithTarget:(CGPoint)target duration:(ccTime)t object:(id)obj block:(void(^)(id object))block;
- (void)runEaseMoveScaleWithTarget:(CGPoint)target duration:(ccTime)t scale:(float)s block:(void(^)())block;

- (void)runFlipFromLeftWithDuration:(ccTime)t toNode:(CCNode *)tarNode;
- (void)runScaleUpAndReverse;
- (void)runDelayWithDuration:(ccTime)time WithBlock:(void (^)())block;

@end
