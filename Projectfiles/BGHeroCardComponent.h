//
//  BGHeroCardComponent.h
//  DotAHero
//
//  Created by Killua Liu on 5/30/13.
//
//

#import <Foundation/Foundation.h>

#define kHeroName               @"heroName"
#define kHeroAttribute          @"heroAttribute"
#define kHealthPointLimit       @"healthPointLimit"
#define kManaPointLimit         @"manaPointLimit"
#define kHandSizeLimit          @"handSizeLimit"
#define kHeroSkills             @"heroSkills"
#define kHeroSkillType          @"heroSkillType"
#define kIsMandatorySkill       @"isMandatorySkill"

typedef NS_ENUM(NSInteger, BGHeroCard) {
    kLordOfAvernus,             // 死亡骑士
    kSkeletonKing,              // 骷髅王
    kBristleback,               // 刚背兽
    kSacredWarrior,             // 神灵武士
    kOmniknight,                // 全能骑士
    kAxe,                       // 斧王
    kCentaurWarchief,           // 半人马酋长
    kDragonKnight,              // 龙骑士
    kGuardianKnight,            // 守护骑士
    
    kGorgon,                    // 蛇发女妖
    kLightningRevenant,         // 闪电幽魂
    kJuggernaut,                // 剑圣
    kVengefulSpirit,            // 复仇之魂
    kStrygwyr,                  // 血魔
    kTrollWarlord,              // 巨魔战将
    kDwarvenSniper,             // 矮人火枪手
    kNerubianAssassin,          // 地穴刺客
    kAntimage,                  // 敌法师
    kNerubianWeaver,            // 地穴编织者
    kUrsaWarrior,               // 熊战士
    kChenYunSheng,              // 陈云生
    
    kSlayer,                    // 秀逗魔导师
    kNecrolyte,                 // 死灵法师
    kTwinHeadDragon,            // 双头龙
    kCrystalMaiden,             // 水晶室女
    kLich,                      // 巫妖
    kShadowPriest,              // 暗影牧师
    kOrgeMagi,                  // 食人魔法师
    kKeeperOfTheLight,          // 光之守卫
    kGoblinTechies,             // 哥布林工程师
    kStormSpirit,               // 风暴之灵
    kEnchantress,               // 魅惑魔女
    kElfLily                    // 精灵莉莉
};

typedef NS_ENUM(NSInteger, BGHeroAttribute) {
    kStrength,                  // 力量型
    kAgility,                   // 敏捷型
    kIntelligence               // 智力型
};

typedef NS_ENUM(NSInteger, BGHeroSkill) {
    kDeathCoil = 0,             // 死亡缠绕
    kFrostmourne = 1,           // 霜之哀伤
    
    kReincarnation = 5,         // 重生
    kVampiricAura = 6,          // 吸血
    
    kWarpath = 10,              // 战意
    kBristlebackSkill = 11,     // 刚毛后背
    
    kLifeBreak = 15,            // 牺牲
    kBurningSpear = 16,         // 沸血之矛
    
    kPurification = 20,         // 洗礼
    kHolyLight = 21,            // 圣光
    
    kBattleHunger = 25,         // 战争饥渴
    kCounterHelix = 26,         // 反转螺旋
    
    kDoubleEdge = 30,           // 双刃剑
    
    kBreatheFire = 35,          // 火焰气息
    kDragonBlood = 36,          // 龙族血统
    
    kGuardian = 40,             // 援护
    kFaith = 41,                // 信仰
    kFatherlyLove = 42,         // 父爱
    
    kMysticSnake = 45,          // 秘术异蛇
    kManaShield = 46,           // 魔法护盾
    
    kPlasmaField = 50,          // 等离子场
    kUnstableCurrent = 51,      // 不定电流
    
    kOmnislash = 55,            // 无敌斩
    kBladeDance = 56,           // 剑舞
    
    kNetherSwap = 60,           // 移形换位
    kWaveOfTerror = 61,         // 恐怖波动
    
    kBloodrage = 65,            // 血之狂暴
    kStrygwyrsThirst = 66,      // 嗜血
    kBloodBath = 67,            // 屠戮
    
    kBattleTrance = 70,         // 战斗专注
    kFervor = 71,               // 热血战魂
    
    kHeadshot = 75,             // 爆头
    kTakeAim = 76,              // 瞄准
    kShrapnel = 77,             // 散弹
    
    kManaBurn = 80,             // 法力燃烧
    kVendetta = 81,             // 复仇
    kSpikedCarapace = 82,       // 穿刺护甲
    
    kManaBreak = 85,            // 法力损毁
    kBlink = 86,                // 闪烁
    kManaVoid = 87,             // 法力虚空
    
    kTheSwarm = 90,             // 蝗虫群
    kTimeLapse = 91,            // 时光倒流
    
    kFurySwipes = 95,           // 怒意狂击
    kEnrage = 96,               // 激怒
    
    kOrdeal = 100,              // 神判
    kSpecialBody = 101,         // 特殊体质
    
    kFierySoul = 105,           // 炽魂
    kLagunaBladeSkill = 106,    // 神灭斩
    
    kHeartstopperAura = 110,    // 竭心光环
    kSadist = 111,              // 施虐之心
    
    kIcePath = 115,             // 冰封
    kLiquidFire = 116,          // 液态火
    
    kFrostbite = 120,           // 冰封禁制
    kBrillianceAura = 121,      // 辉煌光环
    
    kDarkRitual = 125,          // 邪恶祭祀
    kFrostArmor = 126,          // 霜冻护甲
    
    kShallowGrave = 130,        // 薄葬
    kShadowWave = 131,          // 暗影波
    
    kFireblast = 135,           // 火焰爆轰
    kMultiCast = 136,           // 多重施法
    
    kIlluminate = 140,          // 冲击波
    kChakraMagic = 141,         // 查克拉
    kGrace = 142,               // 恩惠
    
    kRemoteMines = 145,         // 遥控炸弹
    kFocusedDetonate = 146,     // 引爆
    kSuicideSquad = 147,        // 自爆
    
    kOverload = 150,            // 超负荷
    kBallLightning = 151,       // 球状闪电
    
    kUntouchable = 155,         // 不可侵犯
    kEnchant = 156,             // 魅惑
    kNaturesAttendants = 157,   // 自然之助
    
    kHealingSpell = 160,        // 治疗术
    kDispelWizard = 161,        // 驱散精灵
    kMagicControl = 162         // 魔法掌控
};

typedef NS_ENUM(NSInteger, BGHeroSkillCategory) {
    kActiveSkill,               // 主动技能
    kPassiveSkill,              // 被动技能
};

typedef NS_ENUM(NSInteger, BGHeroSkillType) {
    kGeneralSkill,              // 普通技
    kRestrictedSkill,           // 限制技
    kLimitedSkill               // 限定技
};


@interface BGHeroCardComponent : NSObject

@property (nonatomic, readonly) BGHeroCard heroId;

@property (nonatomic, copy, readonly) NSString *heroName;
@property (nonatomic, readonly) BGHeroAttribute heroAttibute;
@property (nonatomic, readonly) NSUInteger healthPointLimit;
@property (nonatomic, readonly) NSUInteger manaPointLimit;
@property (nonatomic, readonly) NSUInteger handSizeLimit;   // 手牌上限
@property (nonatomic, readonly) NSArray *heroSkills;

- (id)initWithHeroId:(BGHeroCard)aHeroId;
+ (id)heroCardComponentWithId:(BGHeroCard)aHeroId;

@end
