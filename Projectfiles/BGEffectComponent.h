//
//  BGEffectComponent.h
//  DotAHero
//
//  Created by Killua Liu on 7/10/13.
//
//

#import "CCNode.h"
#import "BGPlayingCard.h"

typedef NS_ENUM(NSInteger, BGEffectType) {
    kEffectTypeDamaged,         // 受到伤害
    kEffectTypeRestoreBlood,    // 恢复血量
    kEffectTypeGotAnger         // 获得怒气
};

@interface BGEffectComponent : CCNode

- (id)initWithPlayingCardEnum:(BGPlayingCardEnum)cardEnum andScale:(float)scale;
- (id)initWithEffectType:(BGEffectType)effectType andScale:(float)scale;
+ (id)effectCompWithPlayingCardEnum:(BGPlayingCardEnum)cardEnum andScale:(float)scale;
+ (id)effectCompWithEffectType:(BGEffectType)effectType andScale:(float)scale;

@end
