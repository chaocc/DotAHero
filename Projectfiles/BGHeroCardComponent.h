//
//  BGCharacterCardComponent.h
//  DotAHero
//
//  Created by Killua Liu on 5/30/13.
//
//

#import "BGComponent.h"

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
    kChenYunSheng,              // 陈云生
    
    kSlayer,                    // 秀逗魔导师
    kTwinHeadDragon,            // 双头龙
    kNecrolyte,                 // 死灵法师
    kCrystalMaiden,             // 水晶室女
    kLich,                      // 巫妖
    kShadowPriest,              // 暗影牧师
    kOrgeMagi,                  // 食人魔法师
    kKeeperOfTheLight,          // 光之守卫
    kGoblinTechies,             // 哥布林工程师
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
    
    kReincarnation = 2,         // 重生
    kVampiricAura = 3,          // 吸血
    
    kWarpath = 4,               // 战意
    kBristlebackSkill = 5,      // 刚毛后背
    
    kLifeBreak = 6,             // 牺牲
    kBurningSpear = 7,          // 沸血之矛
    
    kPurification = 8,          // 洗礼
    
    kBattleHunger = 9,          // 战争饥渴
    kCounterHelix = 10,         // 反转螺旋
    
    kGuardian = 11,             // 援护
    kFaith = 12,                // 信仰
    kFatherlyLove = 13,         // 父爱
    
    kMysticSnake = 14,          // 秘术异蛇
    kManaShield = 15,           // 魔法护盾
    
    kPlasmaField = 16,          // 等离子场
    kUnstableCurrent = 17,      // 不定电流
    
    kOmnislash = 18,            // 无敌斩
    kBladeDance = 19,           // 剑舞
    
    kNetherSwap = 20,           // 移形换位
    kWaveOfTerror = 21,         // 恐怖波动
    
    kBloodrage = 22,            // 血之狂暴
    kStrygwyrsThirst = 23,      // 嗜血
    kBloodBath = 24,            // 屠戮
    
    kBattleTrance = 25,         // 战斗专注
    kFervor = 26,               // 热血战魂
    
    kHeadshot = 27,             // 爆头
    kTakeAim = 28,              // 瞄准
    
    kManaBurn = 29,             // 法力燃烧
    
    kManaBreak = 30,            // 法力损毁
    kBlink = 31,                // 闪烁
    
    kOrdeal = 32,               // 神判
    kSpecialBody = 33,          // 特殊体质
    
    kFierySoul = 34,            // 炽魂
    kLagunaBlade = 35,          // 神灭斩
    
    kHeartstopperAura = 36,     // 竭心光环
    kSadist = 37,               // 施虐之心
    
    kIcePath = 38,              // 冰封
    kLiquidFire = 39,           // 液态火
    
    kFrostbite = 40,            // 冰封禁制
    kBrillianceAura = 41,       // 辉煌光环
    
    kDarkRitual = 42,           // 邪恶祭祀
    kFrostArmor = 43,           // 霜冻护甲
    
    kShallowGrave = 44,         // 薄葬
    kShadowWave = 45,           // 暗影波
    
    kMultiCast = 46,            // 多重施法
    
    kIlluminate = 47,           // 冲击波
    kChakraMagic = 48,          // 查克拉
    kGrace = 49,                // 恩惠
    
    kRemoteMines = 50,          // 遥控炸弹
    kFocusedDetonate = 51,      // 引爆
    kSuicideSquad = 52,         // 自爆
    
    kHealingSpell = 53,         // 治疗术
    kDispelWizard = 54,         // 驱散精灵
    kMagicControl = 55          // 魔法掌控
};

typedef NS_ENUM(NSInteger, BGHeroSkillType) {
    kGeneralSkill,              // 普通技
    kRestrictedSkill,           // 限制技
    kLimitedSkill               // 限定技
};


@interface BGHeroCardComponent : BGComponent

@property (nonatomic, strong) NSArray *heroArray;

@property (nonatomic, readonly) BGHeroCard heroId;

@property (nonatomic, copy, readonly) NSString *heroName;
@property (nonatomic, readonly) BGHeroAttribute heroAttibute;
@property (nonatomic, readonly) NSUInteger healthPointLimit;
@property (nonatomic, readonly) NSUInteger manaPointLimit;
@property (nonatomic, readonly) NSUInteger handSizeLimit;   // 手牌上限
@property (nonatomic, readonly) NSArray *heroSkills;

@property (nonatomic) NSUInteger healthPoint;
@property (nonatomic) NSUInteger manaPoint;
@property (nonatomic) NSUInteger playingCardCount;

- (id)initWithHeroId:(BGHeroCard)aHeroId;
+ (id)heroCardComponentWithId:(BGHeroCard)aHeroId;

@end
