//
//  BGMoveComponent.h
//  DotAHero
//
//  Created by Killua Liu on 6/11/13.
//
//

#import "CCNode.h"

@protocol BGMoveComponentDelegate <NSObject>

- (void)moveActionEnded:(CCNode *)node;

@end

@interface BGMoveComponent : CCNode

@property (nonatomic, weak) id<BGMoveComponentDelegate> delegate;

- (id)initWithTarget:(CGPoint)target ofNode:(CCNode *)node;
+ (id)moveWithTarget:(CGPoint)target ofNode:(CCNode *)node;

- (void)runActionEaseMoveScale;

@end
