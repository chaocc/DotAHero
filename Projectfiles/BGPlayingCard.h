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
#define kNeedSpecifyTarget      @"needSpecifyTarget"
#define kTargetCount            @"targetCount"
#define kCanBeStrengthened      @"canBeStrengthened"
#define kRequiredAnger          @"requiredAnger"
#define kEquipmentType          @"equipmentType"
#define kAttackRange            @"attackRange"
#define kCanBeUsedActive        @"canBeUsedActive"
#define kOnlyEquipOne           @"onlyEquipOne"
#define kDescription            @"description"
#define kTipText                @"tipText"
#define kTargetTipText          @"targetTipText"
#define kDispelTipText          @"dispelTipText"
#define kEquipTipText           @"equipTipText"

typedef NS_ENUM(NSInteger, BGPlayingCardEnum) {
    kPlayingCardInvalid = -1,
    kPlayingCardNormalAttack = 0,           // 普通攻击
    kPlayingCardFlameAttack = 1,            // 火焰攻击
    kPlayingCardChaosAttack = 2,            // 混乱攻击
    kPlayingCardEvasion = 3,                // 闪避
    kPlayingCardHealingSalve = 4,           // 治疗药膏
    
    kPlayingCardFanaticism = 5,             // 狂热
    kPlayingCardMislead = 6,                // 误导
    kPlayingCardChakra = 7,                 // 查克拉
    kPlayingCardWildAxe = 8,                // 野性之斧
    kPlayingCardDispel = 9,                 // 驱散
    kPlayingCardDisarm  = 10,               // 缴械
    kPlayingCardElunesArrow = 11,           // 月神之箭
    kPlayingCardEnergyTransport = 12,       // 能量转移
    kPlayingCardGreed = 13,                 // 贪婪
    kPlayingCardSirenSong = 14,             // 海妖之歌
    
    kPlayingCardGodsStrength = 15,          // 神之力量
    kPlayingCardViperRaid = 16,             // 蝮蛇突袭
    kPlayingCardTimeLock = 17,              // 时间静止
    kPlayingCardSunder = 18,                // 灵魂隔断
    kPlayingCardLagunaBlade = 19,           // 神灭斩
    
    kPlayingCardEyeOfSkadi = 20,            // 冰魄之眼
    kPlayingCardBladesOfAttack = 21,        // 攻击之爪
    kPlayingCardSacredRelic = 22,           // 圣者遗物
    kPlayingCardDemonEdge = 23,             // 恶魔刀锋
    kPlayingCardDiffusalBlade = 24,         // 散失之刃
    kPlayingCardLotharsEdge = 25,           // 洛萨之锋
    kPlayingCardStygianDesolator = 26,      // 黯灭之刃
    kPlayingCardSangeAndYasha = 27,         // 散夜对剑
    kPlayingCardPlunderAxe = 28,            // 掠夺之斧
    kPlayingCardMysticStaff = 29,           // 神秘法杖
    kPlayingCardEaglehorn = 30,             // 鹰角弓
    kPlayingCardQuellingBlade = 31,         // 补刀斧
    
    kPlayingCardPhyllisRing = 32,           // 菲丽丝之戒
    kPlayingCardBladeMail = 33,             // 刃甲
    kPlayingCardBootsOfSpeed = 34,          // 速度之靴
    kPlayingCardPlaneswalkersCloak = 35,    // 流浪法师斗篷
    kPlayingCardTalismanOfEvasion = 36      // 闪避护符
};

typedef NS_ENUM(NSInteger, BGCardColor) {
    kCardColorInvalid = 0,
    kCardColorRed = 1,                  // 红色
    kCardColorBlack                     // 黑色
};

typedef NS_ENUM(NSInteger, BGCardFigure) {
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

typedef NS_ENUM(NSInteger, BGCardSuits) {
    kCardSuitsInvalid = 0,
    kCardSuitsHearts = 1,               // 红桃
    kCardSuitsDiamonds,                 // 方块
    kCardSuitsSpades,                   // 黑桃
    kCardSuitsClubs                     // 梅花
};

typedef NS_ENUM(NSInteger, BGCardType) {
    kCardTypeBasic = 0,                 // 基本牌
    kCardTypeMagic,                     // 魔法牌
    kCardTypeSuperSkill,                // S技能牌
    kCardTypeEquipment                  // 装备牌
};

typedef NS_ENUM(NSInteger, BGEquipmentType) {
    kEquipmentTypeWeapon = 0,           // 武器
    kEquipmentTypeArmor                 // 防具
};

// 攻击的属性: 普通攻击，混乱攻击，火焰攻击


@interface BGPlayingCard : BGCard

@property (nonatomic, readonly) BGCardFigure cardFigure;
@property (nonatomic, readonly) BGCardSuits cardSuits;
@property (nonatomic, readonly) BGCardColor cardColor;
@property (nonatomic, copy, readonly) NSString *figureImageName;
@property (nonatomic, copy, readonly) NSString *suitsImageName;
@property (nonatomic, readonly) BGCardType cardType;
@property (nonatomic, readonly) BOOL needSpecifyTarget;     // 使用卡牌是否需要手动指定目标
@property (nonatomic, readonly) NSUInteger targetCount;     // 需要指定的目标数量
@property (nonatomic, copy, readonly) NSString *tipText;
@property (nonatomic, copy, readonly) NSString *targetTipText;
@property (nonatomic, copy, readonly) NSString *dispelTipText;
@property (nonatomic, copy, readonly) NSString *equipTipText;

// Magic
@property (nonatomic, readonly) BOOL canBeStrengthened;

// Magic|Super Skill
@property (nonatomic, readonly) NSUInteger requiredAnger;   // 强化需要怒气

// Equipment
@property (nonatomic, copy, readonly) NSString *equipImageName;
@property (nonatomic, copy, readonly) NSString *bigEquipImageName;
@property (nonatomic, readonly) BGEquipmentType equipmentType;
@property (nonatomic, readonly) NSUInteger attackRange;
@property (nonatomic, readonly) BOOL canBeUsedActive;       // 是否可以主动使用
@property (nonatomic, readonly) BOOL onlyEquipOne;          // 武器和防具是否只能装备一个

@property (nonatomic) BOOL isVerticalSet;   // 是否是竖置状态(闪避护符)
@property (nonatomic) BOOL isSelected;

+ (NSArray *)playingCardsWithCardIds:(NSArray *)cardIds;
+ (NSArray *)playingCardIdsWithCards:(NSArray *)cards;

- (NSString *)tipTextWith:(NSString *)text parameters:(NSArray *)params;

@end
