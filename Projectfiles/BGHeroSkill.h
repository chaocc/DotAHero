//
//  BGHeroSkill.h
//  DotAHero
//
//  Created by Killua Liu on 7/29/13.
//
//

#import <Foundation/Foundation.h>

#define kHeroSkillId            @"skillEnum"
#define kHeroSkillCategory      @"skillCategory"
#define kHeroSkillType          @"skillType"
#define kHeroSkillText          @"skillText"
#define kIsMandatorySkill       @"isMandatorySkill"
#define kCanBeDispelled         @"canBeDispelled"

typedef NS_ENUM(NSInteger, BGHeroSkillEnum) {
    kHeroSkillInvalid = -1,
    kHeroSkillDeathCoil = 0,                // 死亡缠绕
    kHeroSkillFrostmourne = 1,              // 霜之哀伤
    
    kHeroSkillReincarnation = 2,            // 重生
    kHeroSkillVampiricAura = 3,             // 吸血
    
    kHeroSkillWarpath = 4,                  // 战意
    kHeroSkillBristleback = 5,              // 刚毛后背
    
    kHeroSkillLifeBreak = 6,                // 牺牲
    kHeroSkillBurningSpear = 7,             // 沸血之矛
    
    kHeroSkillPurification = 8,             // 洗礼
    kHeroSkillHolyLight = 9,                // 圣光
    
    kHeroSkillBattleHunger = 10,            // 战争饥渴
    kHeroSkillCounterHelix = 11,            // 反转螺旋
    
    kHeroSkillDoubleEdge = 12,              // 双刃剑
    
    kHeroSkillBreatheFire = 13,             // 火焰气息
    kHeroSkillDragonBlood = 14,             // 龙族血统

    kHeroSkillGuardian = 15,                // 援护
    kHeroSkillFaith = 16,                   // 信仰
    kHeroSkillFatherlyLove = 17,            // 父爱
    
    kHeroSkillMysticSnake = 18,             // 秘术异蛇
    kHeroSkillManaShield = 19,              // 魔法护盾
    
    kHeroSkillPlasmaField = 20,             // 等离子场
    kHeroSkillUnstableCurrent = 21,         // 不定电流
    
    kHeroSkillOmnislash = 22,               // 无敌斩
    kHeroSkillBladeDance = 23,              // 剑舞
    
    kHeroSkillNetherSwap = 24,              // 移形换位
    kHeroSkillWaveOfTerror = 25,            // 恐怖波动
    
    kHeroSkillBloodrage = 26,               // 血之狂暴
    kHeroSkillStrygwyrsThirst = 27,         // 嗜血
    kHeroSkillBloodBath = 28,               // 屠戮
    
    kHeroSkillBattleTrance = 29,            // 战斗专注
    kHeroSkillFervor = 30,                  // 热血战魂
    
    kHeroSkillHeadshot = 31,                // 爆头
    kHeroSkillTakeAim = 32,                 // 瞄准
    kHeroSkillShrapnel = 33,                // 散弹
    
    kHeroSkillManaBurn = 34,                // 法力燃烧
    kHeroSkillVendetta = 35,                // 复仇
    kHeroSkillSpikedCarapace = 36,          // 穿刺护甲
    
    kHeroSkillManaBreak = 37,               // 法力损毁
    kHeroSkillBlink = 38,                   // 闪烁
    kHeroSkillManaVoid = 39,                // 法力虚空
    
    kHeroSkillTheSwarm = 40,                // 蝗虫群
    kHeroSkillTimeLapse = 41,               // 时光倒流
    
    kHeroSkillFurySwipes = 42,              // 怒意狂击
    kHeroSkillEnrage = 43,                  // 激怒
    
    kHeroSkillOrdeal = 44,                  // 神判
    kHeroSkillSpecialBody = 45,             // 特殊体质
    
    kHeroSkillFierySoul = 46,               // 炽魂
    kHeroSkillLagunaBlade = 47,             // 神灭斩
    kHeroSkillFanaticismHeart = 48,         // 狂热之心
    
    kHeroSkillHeartstopperAura = 49,        // 竭心光环
    kHeroSkillSadist = 50,                  // 施虐之心
    
    kHeroSkillIcePath = 51,                 // 冰封
    kHeroSkillLiquidFire = 52,              // 液态火
    
    kHeroSkillFrostbite = 53,               // 冰封禁制
    kHeroSkillBrillianceAura = 54,          // 辉煌光环
    
    kHeroSkillDarkRitual = 55,              // 邪恶祭祀
    kHeroSkillFrostArmor = 56,              // 霜冻护甲
    
    kHeroSkillShallowGrave = 57,            // 薄葬
    kHeroSkillShadowWave = 58,              // 暗影波
    
    kHeroSkillFireblast = 59,               // 火焰爆轰
    kHeroSkillMultiCast = 60,               // 多重施法
    
    kHeroSkillIlluminate = 61,              // 冲击波
    kHeroSkillChakraMagic = 62,             // 查克拉
    kHeroSkillGrace = 63,                   // 恩惠
    
    kHeroSkillRemoteMines = 64,             // 遥控炸弹
    kHeroSkillFocusedDetonate = 65,         // 引爆
    kHeroSkillSuicideSquad = 66,            // 自爆
    
    kHeroSkillOverload = 67,                // 超负荷
    kHeroSkillBallLightning = 68,           // 球状闪电
    
    kHeroSkillUntouchable = 69,             // 不可侵犯
    kHeroSkillEnchant = 70,                 // 魅惑
    kHeroSkillNaturesAttendants = 71,       // 自然之助
    
    kHeroSkillHealingSpell = 72,            // 治疗术
    kHeroSkillDispelWizard = 73,            // 驱散精灵
    kHeroSkillMagicControl = 74             // 魔法掌控
};

typedef NS_ENUM(NSInteger, BGHeroSkillCategory) {
    kHeroSkillCategoryActive = 0,           // 主动技能
    kHeroSkillCategoryPassive,              // 被动技能
};

typedef NS_ENUM(NSInteger, BGHeroSkillType) {
    kHeroSkillTypeGeneral = 0,              // 普通技
    kHeroSkillTypeRestricted,               // 限制技
    kHeroSkillTypeLimited                   // 限定技
};

@interface BGHeroSkill : NSObject

@property (nonatomic, readonly) NSInteger skillId;
@property (nonatomic, readonly) BGHeroSkillEnum skillEnum;
@property (nonatomic, readonly) BGHeroSkillCategory skillCategory;
@property (nonatomic, readonly) BGHeroSkillType skillType;
@property (nonatomic, copy) NSString *skillText;
@property (nonatomic, readonly) BOOL isMandatorySkill;
@property (nonatomic, readonly) BOOL canBeDispeled;

- (id)initWithSkillId:(NSInteger)aSkillId;
+ (id)heroSkillWithSkillId:(NSInteger)aSkillId;

@end
