//
//  BGAnimationComponent.h
//  DotAHero
//
//  Created by Killua Liu on 7/10/13.
//
//

#import <Foundation/Foundation.h>
#import "BGCard.h"

typedef NS_ENUM(NSInteger, BGAnimationType) {
    kAnimationTypeDamaged,          // 受到伤害
    kAnimationTypeRestoreBlood,     // 恢复血量
    kAnimationTypeGotAnger,         // 获得怒气
    kAnimationTypeLostAnger         // 失去怒气
};

@interface BGAnimationComponent : NSObject

- (id)initWithNode:(CCNode *)node;
+ (id)animationComponentWithNode:(CCNode *)node;

- (void)runWithCard:(BGCard *)card atPosition:(CGPoint)position;
- (void)runWithAnimationType:(BGAnimationType)type atPosition:(CGPoint)position;

@end
