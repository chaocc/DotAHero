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
#define kParamSelectableCardCount       @"selectable_count"     // 可选择的卡牌数量
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
    kActionChooseCardId = 201,                      // 选择卡牌
    kActionChooseColor = 202,                       // 选择卡牌颜色
    kActionChooseSuits = 203,                       // 选择卡牌花色
    kActionArrangeCardId = 204,                     // 重新排列卡牌(如能量转移)
    
    kActionUpdateDeckHero = 1000,                   // 更新桌面: 待选英雄
    kActionUpdateDeckCard = 1001,                   // 更新桌面: 手牌/用掉的牌
    kActionInitPlayerHero = 1002,                   // 初始化: 选中的英雄
    kActionInitPlayerHand = 1003,                   // 初始化: 手牌
    kActionUpdatePlayerHero = 1004,                 // 更新玩家: 英雄的血量/怒气等信息
    kActionUpdatePlayerHand = 1005,                 // 更新玩家: 手牌
    
    kActionPlayingCard = 2000,                      // 出牌阶段
    kActionChooseCardToUse = 2001,                  // 选择卡牌: 使用
    kActionChooseCardToCompare = 2002,              // 选择卡牌: 拼点
    kActionChooseCardToDiscard = 2003,              // 选择卡牌: 弃置
    kActionChoosingColor = 2204,                    // 选择颜色阶段
    kActionChoosingSuits = 2205,                    // 选择花色阶段
    kActionArrangingCardId = 2206,                  // 重新排列卡牌阶段(如能量转移)
    
    
    
    kActionReadyStartGame = 1,                      // 准备开始游戏
//    kActionStartGame = 2,                           // 开始游戏
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
    kActionContinueDiscard = 28,                    // 继续弃牌
//    kActionUseHeroSkill = 30,                       // 使用英雄技能
    kActionMisGuessedCard = 99                      // 猜错了牌 - TEMP
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
//    kPlayerStateTargetOfHeroSkill = 17,             // 成为任意英雄技能的目标时
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

// Parameters
#define kParamSortedPlayerNames         @"sortedPlayerNames"    // 其他玩家ID
#define kParamToBeSelectedHeroIds       @"toBeSelectedHeroIds"  // 待选的英雄们
#define kParamHeroId                    @"heroId"               // 选中的英雄ID
#define kParamAllHeroIds                @"allHeroIds"           // 所有英雄选中的英雄
#define kParamRoleIds                   @"roleIds"              // 两个玩家的身份(自己的和下家的)
#define kParamSourcePlayerName          @"playerName"           // 回合开始/伤害来源/出牌的玩家
#define kParamAllCuttingCardIds         @"allCuttingCardIds"    // 所有玩家选择的用于拼点的牌
#define kParamGotPlayingCardIds         @"gotPlayingCardIds"    // 得到的手牌(包括发牌、摸牌及其他方式获得的牌)
#define kParamUsedPlayingCardIds        @"usedPlayingCardIds"   // 用掉/弃掉的手牌或换掉的装备牌
#define kParamMisGuessedCardIds         @"misGuessedCardIds"    // 猜错的牌
#define kParamExtractedCardIdxes        @"extractedCardIdxes"   // 抽取的哪几张牌
#define kParamExtractedCardIds          @"targetCard"           // 抽取的装备
#define kParamLostPlayingCardIds        @"greedLoseCardIds"     // 失去的牌(比如贪婪/缴械)
#define kParamTransferedCardIds         @"transferedCardIds"    // 交给目标的牌
#define kParamGotCardCount              @"gotCardCount"         // 得到的牌数
//#define kParamRemainingCardCount        @"remainingCardCount"   // 牌堆剩余牌数
#define kParamTargetPlayerNames         @"targetPlayerNames"    // 指定的目标玩家们
#define kParamBloodPointChanged         @"hpChanged"            // 血量(+/-)
#define kParamAngerPointChanged         @"spChanged"            // 怒气(+/-)
#define kParamTargetCardColor           @"targetColor"          // 指定的颜色
#define kParamTargetCardSuits           @"targetSuits"          // 指定的花色
#define kParamGreedType                 @"greedType"            // 贪婪手牌/装备
#define kParamUsedHeroSkillId           @"usedSkillId"          // 使用的英雄技能

#define kParamHandCardIds               @"handCardIds"          // 手牌列表 - TEMP
#define kParamHeroBlood                 @"heroHP"               // 英雄当前血量 - TEMP

#endif
