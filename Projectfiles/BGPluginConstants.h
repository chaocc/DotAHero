//
//  PluginConstants.h
//  DotAHero
//
//  Created by Killua Liu on 6/13/13.
//
//

#ifndef DotAHero_PluginConstants_h
#define DotAHero_PluginConstants_h

// Actions
#define kAction                         @"action"   // 标识要做什么事情
#define kError                          @"error"    // 标识错误信息

typedef NS_ENUM(NSInteger, BGAction) {
    kActionReadyStartGame = 100,                     // 准备开始游戏
    kActionStartGame = 0,                           // 开始游戏
    kActionSendSortedPlayerNames = 1,               // 发送所有玩家名
    kActionDealHeroCards = 2,                       // 发英雄牌
    kActionSelectHeroCard = 3,                      // 选中一个英雄
    kActionSendAllHeroIds = 4,                      // 发送所有玩家选中的英雄
    kActionDealRoleCards = 5,                       // 发角色牌
    kActionDealPlayingCards = 6,                    // 发手牌
    
//    kActionCutCard,                                // 切牌(从牌堆抽一张牌)
//    kActionInitialPlayer,                          // 确定初始玩家
    kActionStartTurn = 7,                           // 回合开始
    kActionDrawPlayingCards = 8,                    // 开始摸牌
    kActionOkToUseCard = 9,                         // 确定使用卡牌
    kActionOkToPlayCard = 10,                       // 确定打出手牌
    
    kActionDispel,                                  // 驱散
    kActionWaiting,                                 // 等待
    kActionOkToDiscard,                             // 确定弃牌
    kActionContinueDiscard,                         // 继续弃牌
    kActionCancel,                                  // 取消
    kActionTriggerHeroSkill,                        // 触发英雄技能
    kActionUseHeroSkill,                            // 使用英雄技能
    kActionTriggerEquipmentSkill,                   // 触发装备技能
    kActionUseEquipmentSkill                        // 使用装备技能
};


// Parameters
#define kParamSortedPlayerNames         @"sortedPlayerNames"    // 其他玩家ID - setIntArray
#define kParamToBeSelectedHeroIds       @"toBeSelectedHeroIds"  // 待选的英雄们 - setIntArray
#define kParamHeroId                    @"heroId"               // 选中的英雄ID - setInt
#define kParamAllHeroIds                @"allHeroIds"           // 所有英雄选中的英雄 - setArray
#define kParamRoleIds                   @"roleIds"              // 两个玩家的身份(自己的和下家的) － setIntArray
#define KParamPlayerName                @"playerName"           // 
#define kParamGotPlayingCardIds         @"gotPlayingCardIds"    // 得到的手牌(包括发牌、摸牌及其他方式获得的牌) - setIntArray
#define kParamUsedPlayingCardIds        @"usedPlayingCardIds"   // 用掉/弃掉的手牌或换掉的装备牌 - setIntArray
#define kParamRemainingCardCount        @"remainingCardCount"   // 牌堆剩余牌数

#define kParamPlayerId                   @"pi"      // 玩家ID - setInt
#define kParamPlayerWithHero             @"pwh"     // 玩家及其所选择的英雄 - setEsObject
#define kParamOtherPlayersWithHero       @"opwh"    // 其他玩家们及其所选择的英雄 - setEsObjectArray
#define kParamUsedEquipmentCard          @"uec"     // 使用的装备牌
#define kParamReducedCardCount           @"rcc"     // 减少的牌数 - setInt
#define kParamHeroSkillId                @"hsi"     // 英雄技能 - setInt
#define kParamTargetPlayers              @"tp"      // 指定的目标玩家们 - setIntArray

#endif
