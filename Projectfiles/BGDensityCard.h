//
//  BGDensityCard.h
//  DotAHero
//
//  Created by Killua Liu on 5/30/13.
//
//

#import "BGCard.h"

#define kDescription        @"description"

typedef NS_ENUM(NSInteger, BGDensityCardEnum) {
    kDensityCardDefault = -1,
    kDensityCardShadowPunisher,            // 暗影惩戒者
    kDensityCardConquerorOfHolyLight,      // 圣光征服者
    kDensityCardSpreadingPlague,           // 蔓延的瘟疫
    kDensityCardGameofFate,                // 命运的博弈
    kDensityCardPuppetOfBackfire,          // 反噬的傀儡
    kDensityCardSummonerOfDeath,           // 死神的召唤者
    kDensityCardParanoidMathematician,     // 偏执的数学家
    kDensityCardRoshanPossession           // Roshan附体
};


@interface BGDensityCard : BGCard

@property (nonatomic, copy, readonly) NSString *description;

@end
