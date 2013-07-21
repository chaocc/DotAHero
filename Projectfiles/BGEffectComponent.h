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

@property (nonatomic, readonly) BGPlayingCardEnum playingCardEnum;
@property (nonatomic, readonly) BGEffectType *effectType;

- (id)initWithPlayingCardEnum:(BGPlayingCardEnum)cardEnum;
- (id)initWithEffectType:(BGEffectType)effectType;
+ (id)effectCompWithPlayingCardEnum:(BGPlayingCardEnum)cardEnum;
+ (id)effectCompWithEffectType:(BGEffectType)effectType;

@end
