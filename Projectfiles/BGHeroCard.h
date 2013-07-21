//
//  BGHeroCard.h
//  DotAHero
//
//  Created by Killua Liu on 5/30/13.
//
//

#import "BGCard.h"

#define kHeroName               @"heroName"
#define kHeroAttribute          @"heroAttribute"
#define kBloodPointLimit        @"bloodPointLimit"
#define kAngerPointLimit        @"angerPointLimit"
#define kHandSizeLimit          @"handSizeLimit"
#define kHeroSkills             @"heroSkills"
#define kHeroSkillType          @"heroSkillType"
#define kIsMandatorySkill       @"isMandatorySkill"

typedef NS_ENUM(NSInteger, BGHeroCardEnum) {
    kHeroCardDefault = -1,
    kHeroCardLordOfAvernus = 0,                 // 死亡骑士
    kHeroCardSkeletonKing = 1,                  // 骷髅王
    kHeroCardBristleback = 2,                   // 刚背兽
    kHeroCardSacredWarrior = 3,                 // 神灵武士
    kHeroCardOmniknight = 4,                    // 全能骑士
    kHeroCardAxe = 5,                           // 斧王
    kHeroCardCentaurWarchief = 6,               // 半人马酋长
    kHeroCardDragonKnight = 7,                  // 龙骑士
    kHeroCardGuardianKnight = 8,                // 守护骑士
    
    kHeroCardGorgon = 9,                        // 蛇发女妖
    kHeroCardLightningRevenant = 10,            // 闪电幽魂
    kHeroCardJuggernaut = 11,                   // 剑圣
    kHeroCardVengefulSpirit = 12,               // 复仇之魂
    kHeroCardStrygwyr = 13,                     // 血魔
    kHeroCardTrollWarlord = 14,                 // 巨魔战将
    kHeroCardDwarvenSniper = 15,                // 矮人火枪手
    kHeroCardNerubianAssassin = 16,             // 地穴刺客
    kHeroCardAntimage = 17,                     // 敌法师
    kHeroCardNerubianWeaver = 18,               // 地穴编织者
    kHeroCardUrsaWarrior = 19,                  // 熊战士
    kHeroCardChenYunSheng = 20,                 // 陈云生
    
    kHeroCardSlayer = 21,                       // 秀逗魔导师
    kHeroCardNecrolyte = 22,                    // 死灵法师
    kHeroCardTwinHeadDragon = 23,               // 双头龙
    kHeroCardCrystalMaiden = 24,                // 水晶室女
    kHeroCardLich = 25,                         // 巫妖
    kHeroCardShadowPriest = 26,                 // 暗影牧师
    kHeroCardOrgeMagi = 27,                     // 食人魔法师
    kHeroCardKeeperOfTheLight = 28,             // 光之守卫
    kHeroCardGoblinTechies = 29,                // 哥布林工程师
    kHeroCardStormSpirit = 30,                  // 风暴之灵
    kHeroCardEnchantress = 31,                  // 魅惑魔女
    kHeroCardElfLily = 32                       // 精灵莉莉
};

typedef NS_ENUM(NSInteger, BGHeroAttribute) {
    kHeroAttributeStrength,                 // 力量型
    kHeroAttributeAgility,                  // 敏捷型
    kHeroAttributeIntelligence              // 智力型
};

typedef NS_ENUM(NSInteger, BGHeroSkill) {
    kHeroSkillDefault = -1,
    kHeroSkillDeathCoil = 0,                // 死亡缠绕
    kHeroSkillFrostmourne = 1,              // 霜之哀伤
    
    kHeroSkillReincarnation = 5,            // 重生
    kHeroSkillVampiricAura = 6,             // 吸血
    
    kHeroSkillWarpath = 10,                 // 战意
    kHeroSkillBristleback = 11,             // 刚毛后背
    
    kHeroSkillLifeBreak = 15,               // 牺牲
    kHeroSkillBurningSpear = 16,            // 沸血之矛
    
    kHeroSkillPurification = 20,            // 洗礼
    kHeroSkillHolyLight = 21,               // 圣光
    
    kHeroSkillBattleHunger = 25,            // 战争饥渴
    kHeroSkillCounterHelix = 26,            // 反转螺旋
    
    kHeroSkillDoubleEdge = 30,              // 双刃剑
    
    kHeroSkillBreatheFire = 35,             // 火焰气息
    kHeroSkillDragonBlood = 36,             // 龙族血统
    
    kHeroSkillGuardian = 40,                // 援护
    kHeroSkillFaith = 41,                   // 信仰
    kHeroSkillFatherlyLove = 42,            // 父爱
    
    kHeroSkillMysticSnake = 45,             // 秘术异蛇
    kHeroSkillManaShield = 46,              // 魔法护盾
    
    kHeroSkillPlasmaField = 50,             // 等离子场
    kHeroSkillUnstableCurrent = 51,         // 不定电流
    
    kHeroSkillOmnislash = 55,               // 无敌斩
    kHeroSkillBladeDance = 56,              // 剑舞
    
    kHeroSkillNetherSwap = 60,              // 移形换位
    kHeroSkillWaveOfTerror = 61,            // 恐怖波动
    
    kHeroSkillBloodrage = 65,               // 血之狂暴
    kHeroSkillStrygwyrsThirst = 66,         // 嗜血
    kHeroSkillBloodBath = 67,               // 屠戮
    
    kHeroSkillBattleTrance = 70,            // 战斗专注
    kHeroSkillFervor = 71,                  // 热血战魂
    
    kHeroSkillHeadshot = 75,                // 爆头
    kHeroSkillTakeAim = 76,                 // 瞄准
    kHeroSkillShrapnel = 77,                // 散弹
    
    kHeroSkillManaBurn = 80,                // 法力燃烧
    kHeroSkillVendetta = 81,                // 复仇
    kHeroSkillSpikedCarapace = 82,          // 穿刺护甲
    
    kHeroSkillManaBreak = 85,               // 法力损毁
    kHeroSkillBlink = 86,                   // 闪烁
    kHeroSkillManaVoid = 87,                // 法力虚空
    
    kHeroSkillTheSwarm = 90,                // 蝗虫群
    kHeroSkillTimeLapse = 91,               // 时光倒流
    
    kHeroSkillFurySwipes = 95,              // 怒意狂击
    kHeroSkillEnrage = 96,                  // 激怒
    
    kHeroSkillOrdeal = 100,                 // 神判
    kHeroSkillSpecialBody = 101,            // 特殊体质
    
    kHeroSkillFierySoul = 105,              // 炽魂
    kHeroSkillLagunaBlade = 106,            // 神灭斩
    
    kHeroSkillHeartstopperAura = 110,       // 竭心光环
    kHeroSkillSadist = 111,                 // 施虐之心
    
    kHeroSkillIcePath = 115,                // 冰封
    kHeroSkillLiquidFire = 116,             // 液态火
    
    kHeroSkillFrostbite = 120,              // 冰封禁制
    kHeroSkillBrillianceAura = 121,         // 辉煌光环
    
    kHeroSkillDarkRitual = 125,             // 邪恶祭祀
    kHeroSkillFrostArmor = 126,             // 霜冻护甲
    
    kHeroSkillShallowGrave = 130,           // 薄葬
    kHeroSkillShadowWave = 131,             // 暗影波
    
    kHeroSkillFireblast = 135,              // 火焰爆轰
    kHeroSkillMultiCast = 136,              // 多重施法
    
    kHeroSkillIlluminate = 140,             // 冲击波
    kHeroSkillChakraMagic = 141,            // 查克拉
    kHeroSkillGrace = 142,                  // 恩惠
    
    kHeroSkillRemoteMines = 145,            // 遥控炸弹
    kHeroSkillFocusedDetonate = 146,        // 引爆
    kHeroSkillSuicideSquad = 147,           // 自爆
    
    kHeroSkillOverload = 150,               // 超负荷
    kHeroSkillBallLightning = 151,          // 球状闪电
    
    kHeroSkillUntouchable = 155,            // 不可侵犯
    kHeroSkillEnchant = 156,                // 魅惑
    kHeroSkillNaturesAttendants = 157,      // 自然之助
    
    kHeroSkillHealingSpell = 160,           // 治疗术
    kHeroSkillDispelWizard = 161,           // 驱散精灵
    kHeroSkillMagicControl = 162            // 魔法掌控
};

typedef NS_ENUM(NSInteger, BGHeroSkillCategory) {
    kHeroSkillCategoryActive,               // 主动技能
    kHeroSkillCategoryPassive,              // 被动技能
};

typedef NS_ENUM(NSInteger, BGHeroSkillType) {
    kHeroSkillTypeGeneral,                  // 普通技
    kHeroSkillTypeRestricted,               // 限制技
    kHeroSkillTypeLimited                   // 限定技
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
