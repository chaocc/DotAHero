//
//  BGDensityCardComponent.h
//  DotAHero
//
//  Created by Killua Liu on 5/30/13.
//
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, BGDensityCard) {
    kShadowPunisher,            // 暗影惩戒者
    kConquerorOfHolyLight,      // 圣光征服者
    kSpreadingPlague,           // 蔓延的瘟疫
    kGameofFate,                // 命运的博弈
    kPuppetOfBackfire,          // 反噬的傀儡
    kSummonerOfDeath,           // 死神的召唤者
    kParanoidMathematician,     // 偏执的数学家
    kRoshanPossession           // Roshan附体
};


@interface BGDensityCardComponent : NSObject

@property (nonatomic, readonly) BGDensityCard densityId;

@property (nonatomic, copy, readonly) NSString *taskName;

- (id)initWithDensityId:(BGDensityCard)aDensityId;
+ (id)densityCardComponentWithId:(BGDensityCard)aDensityId;

@end
