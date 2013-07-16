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
    kActionReadyStartGame = 0,                      // 准备开始游戏
    kActionStartGame = 1,                           // 开始游戏
    kActionDealHeroCard = 2,                        // 发英雄牌
    kActionSelectHeroCard = 3,                      // 选中一个英雄
    kActionSendAllHeroIds = 4,                      // 发送所有玩家选中的英雄
    kActionDealRoleCard = 5,                        // 发角色牌
    kActionDealPlayingCard = 6,                     // 发手牌
    
    kActionStartTurn = 7,                           // 回合开始
    kActionDrawPlayingCard = 8,                     // 开始摸牌
    kActionCutCard = 9,                             // 切牌(从牌堆抽一张牌)
    kActionSendPlayingCard = 10,                    // 发送手牌给玩家
    kActionOkToUseCard = 11,                        // 确定使用手牌
    kActionOkToPlayCard = 12,                       // 确定打出手牌
    kActionCancelCard = 13,                         // 受到伤害
    
    
    kActionRestoreBlood = 14,                       // 恢复血量
    kActionGotAnger = 15,                           // 得到怒气
    kActionLostAnger = 16,                          // 失去怒气
    kActionGotSpecificCard = 17,                    // 获得卡牌(比如强化的缴械)
    kActionLostEquipment = 18,                      // 失去装备
    
    kActionWaiting,                                 // 等待
    kActionOkToDiscard,                             // 确定弃牌
    kActionContinueDiscard,                         // 继续弃牌
    kActionCancel,                                  // 取消
    kActionTriggerHeroSkill,                        // 触发英雄技能
    kActionUseHeroSkill,                            // 使用英雄技能
    kActionTriggerEquipmentSkill,                   // 触发装备技能
    kActionUseEquipmentSkill                        // 使用装备技能
};

#define kPlayerState    @"playerState"  // 标识玩家状态
typedef NS_ENUM(NSUInteger, BGPlayerState) {
    kTurnStarting = 1,      // 回合开始
    kDeterming = 2,         // 判定阶段
    kDrawing = 3,           // 摸牌阶段
    kPlaying = 4,           // 出牌阶段
    kDiscarding = 5,        // 弃牌阶段
    kTurnEnding = 6,        // 回合结束阶段
    
    kIsBeingAttack = 7,     // 被攻击生效前
    kUsingMagicCard = 8,    // 魔法牌生效前
    kTargetOfMagicCard = 9, // 成为任意1张魔法牌的目标时
    kWasDamaged = 10,       // 受到1次伤害时
    kIsDying = 11,          // 濒死状态
    kIsDead  = 12,          // 死亡
    
    kWasAttacked = 13,      // 使用攻击命中后
    kDealingDamage = 14,    // 造成一次伤害
    kWasDamangedX = 15,     // 受到伤害大于1
    kk
};

// Parameters
#define kParamSortedPlayerNames         @"sortedPlayerNames"    // 其他玩家ID
#define kParamToBeSelectedHeroIds       @"toBeSelectedHeroIds"  // 待选的英雄们
#define kParamHeroId                    @"heroId"               // 选中的英雄ID
#define kParamAllHeroIds                @"allHeroIds"           // 所有英雄选中的英雄
#define kParamRoleIds                   @"roleIds"              // 两个玩家的身份(自己的和下家的)
#define kParamPlayerName                @"playerName"           // 回合开始/出牌的玩家
#define kParamAllCuttingCardIds         @"allCuttingCardIds"    // 所有玩家选择的用于拼点的牌
#define kParamGotPlayingCardIds         @"gotPlayingCardIds"    // 得到的手牌(包括发牌、摸牌及其他方式获得的牌)
#define kParamUsedPlayingCardIds        @"usedPlayingCardIds"   // 用掉/弃掉的手牌或换掉的装备牌
#define kParamRemainingCardCount        @"remainingCardCount"   // 牌堆剩余牌数
#define kParamTargetPlayerNames         @"targetPlayerNames"    // 指定的目标玩家们
#define kParamBloodPointChanged         @"hpChanged"            // 血量(+/-)
#define kParamAngerPointChanged         @"spChanged"            // 怒气(+/-)
#define kParamisStrengthed              @"isStrengthed"         // 是否被强化
#define kParamTargetCard                @"targetCard"           // 目标牌(比如缴械的目标)

#define kParamPlayerId                  @"pi"      // 玩家ID - setInt
#define kParamPlayerWithHero            @"pwh"     // 玩家及其所选择的英雄 - setEsObject
#define kParamOtherPlayersWithHero      @"opwh"    // 其他玩家们及其所选择的英雄 - setEsObjectArray
#define kParamUsedEquipmentCard         @"uec"     // 使用的装备牌
#define kParamReducedCardCount          @"rcc"     // 减少的牌数 - setInt
#define kParamHeroSkillId               @"hsi"     // 英雄技能 - setInt
#define kParamTargetPlayers             @"tp"      // 指定的目标玩家们 - setIntArray

#endif
