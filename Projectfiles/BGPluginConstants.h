//
//  PluginConstants.h
//  DotAHero
//
//  Created by Killua Liu on 6/13/13.
//
//

#ifndef DotAHero_PluginConstants_h
#define DotAHero_PluginConstants_h

// Extension/Plugin name and handle
#define kPluginRoom     @"ChatPlugin"
#define kPluginGame     @"GamePlugin"

// Actions
#define kAction                         @"action"               // 标识要做什么事情

//#define kActionStartGame                @"startGame"            // 开始游戏
//
//#define kActionUseCard                  @"useCard"              // 使用卡牌
//#define kActionUseHeroSkill             @"useHeroSkill"         // 使用英雄技能
//#define kActionCancel                   @"cancel"               // 取消
//#define kActionDiscard                  @"discard"              // 确定弃牌
//
//#define kActionChooseHeroId             @"chooseHeroId"         // 选择英雄牌
//#define kActionChooseCardId             @"chooseCardId"         // 选择卡牌ID
//#define kActionChooseColor              @"chooseColor"          // 选择卡牌颜色
//#define kActionChooseSuits              @"chooseSuits"          // 选择卡牌花色
//#define kActionArrangeCardId            @"arrangeCardId"        // 重新排列卡牌(如能量转移)
//
//#define kActionChoosingHeroId           @"choosing_hero_id"     // 选择英雄
//#define kActionChoosingCardId           @"choosing_card_id"     // 选择卡牌
//#define kActionChoosingColor            @"choosing_color"       // 选择颜色
//#define kActionChoosingSuits            @"choosing_suits"       // 选择花色
//#define kActionArrangingCardId          @"arranging_card_id"    // 重新排列卡牌(如能量转移)
//#define kActionPlayingCard              @"playing_card"         // 出牌阶段
//#define kActionUpdatePlayerInfo         @"update_player_info"   // 更新玩家信息

#define kParamRemainingCardCount        @"remaining_count"      // 牌堆剩余牌数
#define kParamTargetPlayerList          @"target_player_list"   // 目标玩家列表
#define kParamCardIdList                @"id_list"              // 卡牌列表(英雄牌/摸的牌/获得的牌/使用的牌/弃置的牌)
#define kParamCardIndexList             @"index_list"           // 选中的哪几张牌
#define kParamHandCardCount             @"hand_card_count"      // 玩家手牌数量
#define kParamSelectableCardCount       @"selectable_count"     // 可选择的卡牌数量
#define kParamExtractedCardCount        @"extracted_count"      // 可抽取目标的卡牌数量
#define kParamSelectedHeroId            @"selected_hero_id"     // 选中的英雄
#define kParamSelectedSkillId           @"selected_skill_id"    // 选中的英雄技能
#define kParamSelectedColor             @"selected_color"       // 选中的颜色
#define kParamSelectedSuits             @"selected_suits"       // 选中的花色
#define kParamIsStrengthened            @"is_strengthened"      // 是否被强化
#define kParamHeroBloodPoint            @"hp"                   // 血量值
#define kParamHeroAngerPoint            @"sp"                   // 怒气值

typedef NS_ENUM(NSInteger, BGAction) {
    kActionInvalid = 0,
    kActionStartGame = 2,                           // 开始游戏
    
    kActionUseHandCard = 100,                       // 使用卡牌
    kActionUseHeroSkill = 101,                      // 使用英雄技能
    kActionCancel = 102,                            // 取消
    kActionDiscard = 103,                           // 确定弃牌
    
    kActionChooseHeroId = 200,                      // 选择英雄
    kActionChooseCard = 201,                        // 选择卡牌Id/Idx
    kActionChooseColor = 202,                       // 选择卡牌颜色
    kActionChooseSuits = 203,                       // 选择卡牌花色
    kActionArrangeCardId = 204,                     // 重新排列卡牌(如能量转移)
    
    kActionUpdateDeckHero = 1000,                   // 更新桌面: 待选英雄
    kActionUpdateDeckUsedCard = 1001,               // 更新桌面: 用掉/弃掉的牌
    kActionUpdateDeckHandCard = 1002,               // 更新桌面: 目标手牌/装备
    kActionUpdateDeckPlayingCard = 1003,            // 更新桌面: 牌堆顶的牌
    
    kActionInitPlayerHero = 2000,                   // 初始化玩家: 选中的英雄
    kActionInitPlayerCard = 2001,                   // 初始化玩家: 发初始手牌
    kActionUpdatePlayerHero = 2002,                 // 更新玩家: 英雄的血量/怒气等信息
    kActionUpdatePlayerHand = 2003,                 // 更新玩家: 手牌
    kActionUpdatePlayerHandExtracted = 2004,        // 更新玩家: 手牌被抽取
    kActionUpdatePlayerEquipment = 2005,            // 更新玩家: 装备区的牌
    kActionUpdatePlayerEquipmentExtracted = 2006,   // 更新玩家: 装备去的牌被抽取
    
    kActionPlayingCard = 3000,                      // 出牌阶段
    kActionChooseCardToUse = 3001,                  // 选择卡牌: 使用
    kActionChooseCardToCompare = 3002,              // 选择卡牌: 拼点
    kActionChooseCardToExtract = 3003,              // 选择目标卡牌: 抽取
    kActionChooseCardToGive = 3004,                 // 选择卡牌: 交给其他玩家
    kActionChooseCardToDiscard = 3005,              // 选择卡牌: 弃置
    kActionChoosingColor = 3006,                    // 选择颜色阶段
    kActionChoosingSuits = 3007,                    // 选择花色阶段
    
    
    
    kActionReadyStartGame = 1,                      // 准备开始游戏
    kActionDealHeroCard = 3,                        // 发英雄牌
    kActionSelectHeroCard = 4,                      // 选中一个英雄
    kActionSendAllHeroIds = 5,                      // 发送所有玩家选中的英雄
    kActionDealRoleCard = 6,                        // 发角色牌
    kActionDealPlayingCard = 7,                     // 发起始手牌
    kActionStartTurn = 8,                           // 回合开始
    kActionStartPlay = 100,                         // 开始出牌
    kActionDrawPlayingCard = 9,                     // 开始摸牌
    kActionCutCard = 10,                            // 切牌(从牌堆抽一张牌)
    kActionSendPlayingCard = 11,                    // 发送手牌给玩家
    kActionOkToUseCard = 12,                        // 确定使用手牌
    kActionDiscardCard = 13,                        // 弃置手牌(比如月神之箭)
    kActionCancelCard = 14,                         // 取消使用手牌
    kActionRestoreBlood = 15,                       // 恢复血量 - TEMP
    kActionGotAnger = 16,                           // 得到怒气 - TEMP
    kActionLostAnger = 17,                          // 失去怒气 - TEMP
    kActionGotSpecificCard = 18,                    // 获得卡牌(比如强化的缴械) - TEMP
    kActionLostEquipment = 19,                      // 失去装备 - TEMP
    kActionContinuePlaying = 20,                    // 继续出牌 
    kActionGuessCardColor = 21,                     // 猜卡牌颜色
    kActionGotGuessedCard = 22,                     // 获得猜中的牌
    kActionExtractCard = 23,                        // 抽取手牌
    kActionGotExtractedCard = 24,                   // 获得抽取的牌
    kActionPlayMultipleEvasions = 25,               // 打出多张闪(最多3张)
    kActionStartDiscard = 26,                       // 开始弃牌
    kActionOkToDiscard = 27,                        // 确定弃牌
    kActionContinueDiscard = 28                     // 继续弃牌
};

#define kPlayerState    @"playerState"  // 标识玩家状态
typedef NS_ENUM(NSInteger, BGPlayerState) {
    kPlayerStateInvalid = 0,
    kPlayerStateCutting = 9,                        // 切牌阶段
    kPlayerStateTurnStarting = 1,                   // 回合开始
    kPlayerStateDeterming = 2,                      // 判定阶段
    kPlayerStateDrawing = 3,                        // 摸牌阶段
    kPlayerStatePlaying = 4,                        // 出牌阶段
    kPlayerStateDiscarding = 5,                     // 弃牌阶段
    kPlayerStateTurnEnding = 6,                     // 回合结束阶段
    
    kPlayerStateIsBeingAttacked = 7,                // 被攻击生效前
    kPlayerStateGuessingCardColor = 8,              // 猜卡牌颜色
    kPlayerStateWasAttacked = 10,                   // 受到攻击的伤害
    kPlayerStateWasDamaged = 11,                    // 受到1次伤害
    kPlayerStateDealedDamage = 12,                  // 造成1次伤害
    kPlayerStateIsDying = 13,                       // 濒死状态
    kPlayerStateAttacked = 14,                      // 攻击造成1次伤害
    kPlayerStateIsDead = 15,                        // 已死亡
    kPlayerStateThrowingCard = 16,                  // 弃置牌(丢掉牌)
    kPlayerStateBloodRestored = 18,                 // 恢复1点血
    kPlayerStateGreeding = 19,                      // 贪婪－抽目标玩家牌
    kPlayerStateIsBeingGreeded = 20,                // 被贪婪－抽源玩家牌
    kPlayerStateWasDisarmed = 21,                   // 已被缴械
    kPlayerStateWasExtracted = 22,                  // 已被抽牌
    kPlayerStateAngerLost = 23,                     // 丢失怒气
    kPlayerStateAngerGain = 24,                     // 获得怒气
    kPlayerStateAngerUsed = 25,                     // 使用怒气
    kPlayerStateIsBeingLagunaBladed = 26,           // 被神灭斩
    kPlayerStateIsBeingViperRaided = 27             // 被蝮蛇突袭
};

#endif
