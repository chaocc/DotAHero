//
//  BGPlayingCard.h
//  DotAHero
//
//  Created by Killua Liu on 5/30/13.
//
//

#import "BGCard.h"

#define kCardType               @"cardType"
#define kCardFigure             @"cardFigure"
#define kCardSuits              @"cardSuits"
#define kCardEffect             @"cardEffect"
#define kWhenToUse              @"whenToUse"
#define kMaxTargetCount         @"maxTargetCount"
#define kCanBeStrengthed        @"canBeStrengthed"
#define kRequiredMana           @"requiredMana"
#define kEquipmentType          @"equipmentType"
#define kAttackRange            @"attackRange"
#define kOnlyEquipOne           @"onlyEquipOne"

typedef NS_ENUM(NSUInteger, BGPlayingCardEnum) {
    kPlayingCardNormalAttack,           // 普通攻击
    kPlayingCardFlameAttack,            // 火焰攻击
    kPlayingCardChaosAttack,            // 混乱攻击
    kPlayingCardEvasion,                // 闪避
    kPlayingCardHealingSalve,           // 治疗药膏
    
    kPlayingCardFanaticism,             // 狂热
    kPlayingCardMislead,                // 误导
    kPlayingCardChakra,                 // 查克拉
    kPlayingCardWildAxe,                // 野性之斧
    kPlayingCardDispel,                 // 驱散
    kPlayingCardDisarm,                 // 缴械
    kPlayingCardElunesArrow,            // 月神之箭
    kPlayingCardEnergyTransport,        // 能量转移
    kPlayingCardGreed,                  // 贪婪
    kPlayingCardSirenSong,              // 海妖之歌
    
    kPlayingCardGodsStrength,           // 神之力量
    kPlayingCardViperRaid,              // 蝮蛇突袭
    kPlayingCardTimeLock,               // 时间静止
    kPlayingCardSunder,                 // 灵魂隔断
    kPlayingCardLagunaBlade,            // 神灭斩
    
    kPlayingCardEyeOfSkadi,             // 冰魄之眼
    kPlayingCardBladesOfAttack,         // 攻击之爪
    kPlayingCardSacredRelic,            // 圣者遗物
    kPlayingCardDemonEdge,              // 恶魔刀锋
    kPlayingCardDiffusalBlade,          // 散失之刃
    kPlayingCardLotharsEdge,            // 洛萨之锋
    kPlayingCardStygianDesolator,       // 黯灭之刃
    kPlayingCardSangeAndYasha,          // 散夜对剑
    kPlayingCardPlunderAxe,             // 掠夺之斧
    kPlayingCardMysticStaff,            // 神秘法杖
    kPlayingCardEaglehorn,              // 鹰角弓
    kPlayingCardQuellingBlade,          // 补刀斧
    
    kPlayingCardPhyllisRing,            // 菲丽丝之戒
    kPlayingCardBladeMail,              // 刃甲
    kPlayingCardBootsOfSpeed,           // 速度之靴
    kPlayingCardPlaneswalkersCloak,     // 流浪法师斗篷
    kPlayingCardTalismanOfEvasion       // 闪避护符
};

typedef NS_ENUM(NSUInteger, BGCardColor) {
    kCardColorRed,                      // 红色
    kCardColorBlack                     // 黑色
};

typedef NS_ENUM(NSUInteger, BGCardFigure) {
    kCardFigure1 = 1,
    kCardFigure2,
    kCardFigure3,
    kCardFigure4,
    kCardFigure5,
    kCardFigure6,
    kCardFigure7,
    kCardFigure8,
    kCardFigure9,
    kCardFigure10,
    kCardFigure11,
    kCardFigure12,
    kCardFigure13
};

typedef NS_ENUM(NSUInteger, BGCardSuits) {
    kCardSuitsHearts,                   // 红桃
    kCardSuitsDiamonds,                 // 方块
    kCardSuitsSpades,                   // 黑桃
    kCardSuitsClubs                     // 梅花
};

typedef NS_ENUM(NSUInteger, BGWhenToUse) {
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

typedef NS_ENUM(NSUInteger, BGCardType) {
    kCardTypeBasic,                     // 基本牌
    kCardTypeMagic,                     // 魔法牌
    kCardTypeSuperSkill,                // S技能牌
    kCardTypeEquipment                  // 装备牌
};

typedef NS_ENUM(NSUInteger, BGEquipmentType) {
    kEquipmentTypeWeapon = 1,           // 武器
    kEquipmentTypeArmor = 2             // 防具
};

// 攻击的属性: 普通攻击，混乱攻击，火焰攻击


@interface BGPlayingCard : BGCard

@property (nonatomic, readonly) BGCardFigure cardFigure;
@property (nonatomic, readonly) BGCardSuits cardSuits;
@property (nonatomic, readonly) BGCardColor cardColor;
@property (nonatomic, copy, readonly) NSString *figureImageName;
@property (nonatomic, copy, readonly) NSString *suitsImageName;

@property (nonatomic, readonly) BGCardType cardType;
@property (nonatomic, readonly) NSString *cardEffect;
@property (nonatomic, readonly) NSArray *whenToUse;         // 使用时机
@property (nonatomic, readonly) NSUInteger maxTargetCount;  // 最多指定的目标数量

// Magic
@property (nonatomic, readonly) BOOL canBeStrengthed;

// Magic / Super Skill
@property (nonatomic, readwrite) NSUInteger requiredMana;   // 强化需要魔法

// Equipment
@property (nonatomic, copy, readonly) NSString *equipImageName;
@property (nonatomic, copy, readonly) NSString *bigEquipImageName;
@property (nonatomic, readonly) BGEquipmentType equipmentType;
@property (nonatomic, readonly) NSUInteger attackRange;
@property (nonatomic, readonly) BOOL onlyEquipOne;          // 武器和防具是否只能装备一个
@property (nonatomic) BOOL isVerticalSet;                   // 是否是竖置状态(闪避护符)

@property (nonatomic) BOOL canBeUsed;
@property (nonatomic) BOOL isSelected;

@end
