//
//  BGHeroCard.h
//  DotAHero
//
//  Created by Killua Liu on 5/30/13.
//
//

#import "BGCard.h"
#import "BGHeroSkill.h"

#define kHeroName               @"heroName"
#define kHeroText               @"heroText"
#define kHeroAttribute          @"heroAttribute"
#define kBloodPointLimit        @"bloodPointLimit"
#define kAngerPointLimit        @"angerPointLimit"
#define kHandSizeLimit          @"handSizeLimit"
#define kHeroSkills             @"heroSkills"

typedef NS_ENUM(NSInteger, BGHeroCardEnum) {
    kHeroCardDefault = -1,
    kHeroCardLordOfAvernus = 0,             // 死亡骑士
    kHeroCardSkeletonKing = 1,              // 骷髅王
    kHeroCardBristleback = 2,               // 刚背兽
    kHeroCardSacredWarrior = 3,             // 神灵武士
    kHeroCardOmniknight = 4,                // 全能骑士
    kHeroCardAxe = 5,                       // 斧王
    kHeroCardCentaurWarchief = 6,           // 半人马酋长
    kHeroCardDragonKnight = 7,              // 龙骑士
    kHeroCardGuardianKnight = 8,            // 守护骑士
    
    kHeroCardGorgon = 9,                    // 蛇发女妖
    kHeroCardLightningRevenant = 10,        // 闪电幽魂
    kHeroCardJuggernaut = 11,               // 剑圣
    kHeroCardVengefulSpirit = 12,           // 复仇之魂
    kHeroCardStrygwyr = 13,                 // 血魔
    kHeroCardTrollWarlord = 14,             // 巨魔战将
    kHeroCardDwarvenSniper = 15,            // 矮人火枪手
    kHeroCardNerubianAssassin = 16,         // 地穴刺客
    kHeroCardAntimage = 17,                 // 敌法师
    kHeroCardNerubianWeaver = 18,           // 地穴编织者
    kHeroCardUrsaWarrior = 19,              // 熊战士
    kHeroCardChenYunSheng = 20,             // 陈云生
    
    kHeroCardSlayer = 21,                   // 秀逗魔导师
    kHeroCardNecrolyte = 22,                // 死灵法师
    kHeroCardTwinHeadDragon = 23,           // 双头龙
    kHeroCardCrystalMaiden = 24,            // 水晶室女
    kHeroCardLich = 25,                     // 巫妖
    kHeroCardShadowPriest = 26,             // 暗影牧师
    kHeroCardOrgeMagi = 27,                 // 食人魔法师
    kHeroCardKeeperOfTheLight = 28,         // 光之守卫
    kHeroCardGoblinTechies = 29,            // 哥布林工程师
    kHeroCardStormSpirit = 30,              // 风暴之灵
    kHeroCardEnchantress = 31,              // 魅惑魔女
    kHeroCardElfLily = 32                   // 精灵莉莉
};

typedef NS_ENUM(NSInteger, BGHeroAttribute) {
    kHeroAttributeStrength = 1,             // 力量型
    kHeroAttributeAgility,                  // 敏捷型
    kHeroAttributeIntelligence              // 智力型
};

@interface BGHeroCard : BGCard

@property (nonatomic, copy, readonly) NSString *avatarName;
@property (nonatomic, copy, readonly) NSString *bigAvatarName;

@property (nonatomic, readonly) BGHeroAttribute heroAttibute;
@property (nonatomic, readonly) NSUInteger bloodPointLimit;
@property (nonatomic, readonly) NSUInteger angerPointLimit;
@property (nonatomic, readonly) NSUInteger handSizeLimit;   // 手牌上限
@property (nonatomic, readonly) NSArray *heroSkills;

@end
