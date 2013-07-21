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
#define kAction         @"action"   // 标识要做什么事情
typedef NS_ENUM(NSInteger, BGAction) {
    kActionInvalid = 0,
    kActionReadyStartGame = 1,                      // 准备开始游戏
    kActionStartGame = 2,                           // 开始游戏
    kActionDealHeroCard = 3,                        // 发英雄牌
    kActionSelectHeroCard = 4,                      // 选中一个英雄
    kActionSendAllHeroIds = 5,                      // 发送所有玩家选中的英雄
    kActionDealRoleCard = 6,                        // 发角色牌
    kActionDealPlayingCard = 7,                     // 发起始手牌
    
    kActionStartTurn = 8,                           // 回合开始
    kActionDrawPlayingCard = 9,                     // 开始摸牌
    kActionCutCard = 10,                            // 切牌(从牌堆抽一张牌)
    kActionSendPlayingCard = 11,                    // 发送手牌给玩家
    kActionOkToUseCard = 12,                        // 确定使用手牌
    kActionDiscardCard = 13,                        // 弃置1张手牌(比如月神之箭)
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
    kActionMisGuessedCard = 25                      // 猜错了牌 - TEMP
    
    
//    kActionWaiting,                                 // 等待
//    kActionOkToDiscard,                             // 确定弃牌
//    kActionContinueDiscard,                         // 继续弃牌
//    kActionTriggerHeroSkill,                        // 触发英雄技能
//    kActionUseHeroSkill,                            // 使用英雄技能
//    kActionTriggerEquipmentSkill,                   // 触发装备技能
//    kActionUseEquipmentSkill                        // 使用装备技能
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
    kPlayerStateDealingDamage = 12,                 // 造成1次伤害
    kPlayerStateIsDying = 13,                       // 濒死状态
    kPlayerStateAttacked = 14,                      // 攻击造成1次伤害
    kPlayerStateIsDead = 15,                        // 已死亡
    kPlayerStateThrowingCard = 16,                  // 弃置牌(丢掉牌)
    kPlayerStateTargetOfHeroSkill = 17,             // 成为任意英雄技能的目标时
    kPlayerStateBloodRestored = 18,                 // 恢复1点血
    kPlayerStateExtractingCard = 19,                // 抽牌并暗置
    kPlayerStateTargetExtractingCard = 20,          // 目标抽牌
    kPlayerStateWasDisarmed = 21,                   // 被缴械
    kPlayerStateWasExtracted = 22                   // 被抽牌
};

// Parameters
#define kParamSortedPlayerNames         @"sortedPlayerNames"    // 其他玩家ID
#define kParamToBeSelectedHeroIds       @"toBeSelectedHeroIds"  // 待选的英雄们
#define kParamHeroId                    @"heroId"               // 选中的英雄ID
#define kParamAllHeroIds                @"allHeroIds"           // 所有英雄选中的英雄
#define kParamRoleIds                   @"roleIds"              // 两个玩家的身份(自己的和下家的)
#define kParamCurrentPlayerName         @"playerName"           // 回合开始/伤害来源/出牌的玩家
#define kParamAllCuttingCardIds         @"allCuttingCardIds"    // 所有玩家选择的用于拼点的牌
#define kParamGotPlayingCardIds         @"gotPlayingCardIds"    // 得到的手牌(包括发牌、摸牌及其他方式获得的牌)
#define kParamUsedPlayingCardIds        @"usedPlayingCardIds"   // 用掉/弃掉的手牌或换掉的装备牌
#define kParamLostPlayingCardIds        @"targetCard"           // 失去的牌(比如贪婪/缴械)
#define kParamMisGuessedCardIds         @"misGuessedCardIds"    // 猜错的牌
#define kParamExtractedCardIdxes        @"extractedCardIdxes"   // 抽取的哪几张牌
#define kParamGotCardCount              @"gotCardCount"         // 得到的牌数
#define kParamRemainingCardCount        @"remainingCardCount"   // 牌堆剩余牌数
#define kParamTargetPlayerNames         @"targetPlayerNames"    // 指定的目标玩家们
#define kParamBloodPointChanged         @"hpChanged"            // 血量(+/-)
#define kParamAngerPointChanged         @"spChanged"            // 怒气(+/-)
#define kParamIsStrengthened            @"isStrengthed"         // 是否被强化
#define kParamTargetCardColor           @"targetColor"          // 指定的颜色
#define kParamTargetCardSuits           @"targetSuits"          // 指定的花色
#define kParamGreedType                 @"greedType"            // 贪婪手牌/装备

#define kParamPlayerWithHero            @"pwh"     // 玩家及其所选择的英雄 - setEsObject
#define kParamOtherPlayersWithHero      @"opwh"    // 其他玩家们及其所选择的英雄 - setEsObjectArray
#define kParamUsedEquipmentCard         @"uec"     // 使用的装备牌
#define kParamReducedCardCount          @"rcc"     // 减少的牌数 - setInt
#define kParamHeroSkillId               @"hsi"     // 英雄技能 - setInt
#define kParamTargetPlayers             @"tp"      // 指定的目标玩家们 - setIntArray

#endif
