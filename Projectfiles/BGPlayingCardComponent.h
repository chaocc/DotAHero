//
//  BGPlayingCardComponent.h
//  DotAHero
//
//  Created by Killua Liu on 5/30/13.
//
//

#import <Foundation/Foundation.h>

#define kCardName               @"cardName"
#define kCardType               @"cardType"
#define kCardEffect             @"cardEffect"
#define kWhenToUse              @"whenToUse"
#define kMaxTargetCount         @"maxTargetCount"
#define kCanBeStrengthed        @"canBeStrengthed"
#define kRequiredMana           @"requiredMana"
#define kEquipmentType          @"equipmentType"
#define kAttackRange            @"attackRange"
#define kOnlyEquipOne           @"onlyEquipOne"

typedef NS_ENUM(NSInteger, BGPlayingCard) {
    kNormalAttack,          // 普通攻击
    kFlameAttack,           // 火焰攻击
    kChaosAttack,           // 混乱攻击
    kEvasion,               // 闪避
    kHealingSalve,          // 治疗药膏
    
    kFanaticism,            // 狂热
    kMislead,               // 误导
    kChakra,                // 查克拉
    kWildAxe,               // 野性之斧
    kDispel,                // 驱散
    kDisarm,                // 缴械
    kElunesArrow,           // 月神之箭
    kEnergyTransport,       // 能量转移
    kGreed,                 // 贪婪
    kSirenSong,             // 海妖之歌
    
    kGodsStrength,          // 神之力量
    kViperRaid,             // 蝮蛇突袭
    kTimeLock,              // 时间静止
    kSunder,                // 灵魂隔断
    kLagunaBlade,           // 神灭斩
    
    kEyeOfSkadi,            // 冰魄之眼
    kBladesOfAttack,        // 攻击之爪
    kSacredRelic,           // 圣者遗物
    kDemonEdge,             // 恶魔刀锋
    kDiffusalBlade,         // 散失之刃
    kLotharsEdge,           // 洛萨之锋
    kStygianDesolator,      // 黯灭之刃
    kSangeAndYasha,         // 散夜对剑
    kPlunderAxe,            // 掠夺之斧
    kMysticStaff,           // 神秘法杖
    kEaglehorn,             // 鹰角弓
    kQuellingBlade,         // 补刀斧
    
    kPhyllisRing,           // 菲丽丝之戒
    kBladeMail,             // 刃甲
    kBootsOfSpeed,          // 速度之靴
    kPlaneswalkersCloak,    // 流浪法师斗篷
    kTalismanOfEvasion      // 闪避护符
};

typedef NS_ENUM(NSInteger, BGCardColor) {
    kRedColor,              // 红色
    kBlackColor             // 黑色
};

typedef NS_ENUM(NSInteger, BGCardSuits) {
    kHearts,                // 红桃
    kDiamonds,              // 方块
    kSpades,                // 黑桃
    kClubs                  // 梅花
};

typedef NS_ENUM(NSInteger, BGCardFigure) {
    kFigureA = 1,
    kFigure2,
    kFigure3,
    kFigure4,
    kFigure5,
    kFigure6,
    kFigure7,
    kFigure8,
    kFigure9,
    kFigure10,
    kFigureJ,
    kFigureQ,
    kFigureK
};

typedef NS_ENUM(NSInteger, BGCardWhenToUse) {
    kDeterming = 1,         // 判定阶段
    kDrawing = 2,           // 摸牌阶段
    kPlaying = 3,           // 出牌阶段
    kDiscarding = 4,        // 弃牌阶段
    kTurnEnding = 5,        // 回合结束阶段
    
    kIsBeingAttack = 6,     // 被攻击生效前
    kUsingMagicCard = 7,    // 魔法牌生效前
    ktargetOfMagicCard = 8, // 成为任意1张魔法牌的目标时
    kWasDamaged = 9,        // 受到1次伤害时
    kIsDying = 10,          // 濒死状态
    kIsDead  = 11,          // 死亡
    
    kWasAttacked = 12,      // 使用攻击命中后
    kDealingDamage = 13,    // 造成一次伤害
    kWasDamangedX = 14,     // 受到伤害大于1
    kk
};

typedef NS_ENUM(NSInteger, BGCardType) {
    kBasicCard,             // 基本牌
    kEquipmentCard,         // 装备牌
    kMagicCard,             // 魔法牌
    kSuperSkillCard         // S技能牌
};

typedef NS_ENUM(NSInteger, BGEquipmentType) {
    kWeaponEquipment = 1,   // 武器
    kArmorEquipment = 2     // 防具
};


@interface BGPlayingCardComponent : NSObject

@property (nonatomic, readonly) BGPlayingCard playingCardId;

@property (nonatomic, readonly) BGCardSuits cardSuits;
@property (nonatomic, readonly) BGCardColor cardColor;
@property (nonatomic, readonly) BGCardFigure cardFigure;

@property (nonatomic, copy, readonly) NSString *cardName;
@property (nonatomic, readonly) BGCardType cardType;
@property (nonatomic, readonly) NSString *cardEffect;
@property (nonatomic, readonly) NSArray *whenToUse;         // 使用时机
@property (nonatomic, readonly) NSUInteger maxTargetCount;  // 最多指定的目标数量

// Magic
@property (nonatomic, readonly) BOOL canBeStrengthed;

// Magic / Super Skill
@property (nonatomic, readwrite) NSUInteger requiredMana;   // 强化需要魔法

// Equipment
@property (nonatomic, readonly) BGEquipmentType equipmentType;
@property (nonatomic, readonly) BOOL onlyEquipOne;  // 武器和防具是否只能装备一个
@property (nonatomic, readonly) NSUInteger attackRange;

- (id)initWithPlayingCardId:(BGPlayingCard)aPlayingCardId;
+ (id)playingCardComponentWithId:(BGPlayingCard)aPlayingCardId;

@end
