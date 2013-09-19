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
#define kExtensionHeroServer    @"HeroServer"
#define kPluginRoom             @"RoomPlugin"
#define kPluginGame             @"GamePlugin"

// Actions
#define kAction                 @"action"               // 标识要做什么事情

typedef NS_ENUM(NSInteger, BGAction) {
    kActionInvalid = 0,
    kActionReadyStartGame = 1,                      // 准备开始游戏
    kActionStartGame = 2,                           // 开始游戏
    kActionStartRound = 3,                          // 开始牌局
    
    kActionUseHandCard = 100,                       // 使用卡牌
    kActionUseHeroSkill = 101,                      // 使用英雄技能
    kActionCancel = 102,                            // 取消
    kActionDiscard = 103,                           // 确定弃牌
    kActionOkay = 104,                              // 确定
//    kActionClearDeckCard = 105,                     // 清空桌面
    
    kActionChoseHero = 200,                         // 选择了英雄
    kActionChoseCardToUse = 201,                    // 选择了卡牌Id/Idx: 使用
    kActionChoseCardToCut = 202,                    // 选择了卡牌: 切牌
    kActionChoseCardToGet = 203,                    // 选择了目标卡牌: 抽取获得
    kActionChoseCardToDrop = 204,                   // 先择了卡牌: 丢掉
    kActionChoseCardToGive = 205,                   // 选择了卡牌: 交给其他玩家
    kActionChoseCardToDiscard = 206,                // 选择了卡牌: 弃置
    kActionChoseColor = 207,                        // 选择了卡牌颜色
    kActionChoseSuits = 208,                        // 选择了卡牌花色
    kActionAssignCard = 209,                        // 分配了卡牌(如能量转移)
    
    kActionDeckDealHeros = 1000,                    // 发待选英雄
    kActionDeckShowDroppedCard = 1001,              // 显示拆除的牌
    kActionDeckShowPlayerCard = 1002,               // 显示目标手牌(暗置)和装备
    kActionDeckShowTopPileCard = 1003,              // 显示牌堆顶的牌(如能量转移)
    kActionDeckShowAllSelectedHeros = 1004,         // 显示所有玩家选中的英雄
    kActionDeckShowAllCuttedCards = 1005,           // 显示所有玩家用于切牌拼点的牌
    
    kActionPlayerSelectedHero = 2000,               // 选中了英雄
    kActionPlayerDealCard = 2001,                   // 发初始手牌
    kActionPlayerUpdateHero = 2002,                 // 更新英雄的血量/怒气等信息
    kActionPlayerUpdateHand = 2003,                 // 更新手牌
    kActionPlayerUpdateHandGetting = 2004,          // 更新手牌-获得
    kActionPlayerUpdateEquipment = 2005,            // 更新装备区的牌
    
    kActionPlayingCard = 3000,                      // 出牌阶段(主动)
    kActionChooseCardToUse = 3001,                  // 选择卡牌: 使用(被动)
    kActionChooseCardToCut = 3002,                  // 选择卡牌: 切牌
    kActionChooseCardToGet = 3003,                  // 选择目标卡牌: 抽取获得
    kActionChooseCardToGive = 3004,                 // 选择卡牌: 交给其他玩家
    kActionChooseCardToDiscard = 3005,              // 选择卡牌: 弃置
    kActionChoosingColor = 3006,                    // 选择颜色阶段
    kActionChoosingSuits = 3007,                    // 选择花色阶段
};

// Parameters
#define kParamUserList                  @"player_list"          // 所有玩家列表
#define kParamRemainingCardCount        @"remaining_count"      // 牌堆剩余牌数
#define kParamPlayerName                @"player_name"          // 回合开始/伤害来源/出牌的玩家
#define kParamTargetPlayerList          @"target_player_list"   // 目标玩家列表
#define kParamCardIdList                @"id_list"              // 卡牌列表(英雄牌/摸的牌/获得的牌/使用的牌/弃置的牌)
#define kParamAvailableIdList           @"available_id_list"    // 可以选择使用的卡牌
#define kParamCardIndexList             @"index_list"           // 选中的哪几张牌
#define kParamMaxFigureCardId           @"biggest_card_id"      // 最大点数的卡牌
#define kParamCardCount             @"hand_card_change_amount"  // 牌数(抽取/获得/分配/失去)
#define kParamHandCardCount             @"hand_card_count"      // 玩家手牌数量
#define kParamSelectableCardCount       @"selectable_count"     // 可选择的卡牌数量
#define kParamExtractableCardCount      @"extractable_count"    // 可抽取目标的卡牌数量
#define kParamSelectedHeroId            @"id"                   // 选中的英雄
#define kParamSelectedSkillId           @"selected_skill_id"    // 选中的英雄技能
#define kParamSelectedColor             @"selected_color"       // 选中的颜色
#define kParamSelectedSuits             @"selected_suits"       // 选中的花色
#define kParamIsStrengthened            @"is_strengthened"      // 是否被强化
#define kParamHeroBloodPoint            @"hp"                   // 血量值
#define kParamHeroBloodPointChanged     @"hp_changed"           // +|-血量
#define kParamHeroAngerPoint            @"sp"                   // 怒气值
#define kParamHeroAngerPointChanged     @"sp_changed"           // +|-怒气
#define kParamPlayerCount               @"player_count"

#endif
