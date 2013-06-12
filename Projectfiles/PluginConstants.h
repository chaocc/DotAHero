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
#define kAction                     @"a"        // 标识要做什么事情
#define kError                      @"err"      // 标识错误信息

typedef NS_ENUM(NSInteger, BGAction) {
    kDealHeroCard,                              // 发英雄牌
    kSelectHeroCard,                            // 选中一个英雄
    kDealRoleCard,                              // 发角色牌
    kDealPlayingCard,                           // 发手牌
    kCutCard,                                   // 切牌(从牌堆抽一张牌)
    kInitialPlayer,                             // 确定初始玩家
    kDispel,                                    // 驱散
    kWaiting,                                   // 等待
    kOkToUseCard,                               // 确定使用卡牌
    kOkToDiscard,                               // 确定弃牌
    kContinueDiscard,                           // 继续弃牌
    kCancel,                                    // 取消
    kTriggerHeroSkill,                          // 触发英雄技能
    kUseHeroSkill,                              // 使用英雄技能
    kTriggerEquipmentSkill,                     // 触发装备技能
    kUseEquipmentSkill                          // 使用装备技能
};


// Parameters
#define kPlayerId                   @"pi"       // 玩家ID - setInt
#define kOtherPlayerIds             @"opi"      // 其他玩家ID - setIntArray
#define kToBeSelectedHeros          @"tbsh"     // 待选的英雄们 - setIntArray
#define kHeroId                     @"hi"       // 英雄ID - setInt
#define kPlayerWithHero             @"pwh"      // 玩家及其所选择的英雄 - setEsObject
#define kOtherPlayersWithHero       @"opwh"     // 其他玩家们及其所选择的英雄 - setEsObjectArray
#define kRoleIds                    @"ri"       // 两个玩家的身份(自己的和下家的) － setIntArray
#define kGotPlayingCards            @"gpc"      // 得到的手牌(包括发牌、摸牌及其他方式获得的牌) - setIntArray
#define kUsedPlayingCards           @"upc"      // 用掉的手牌或装备牌 - setIntArray
#define kUsedEquipmentCard          @"uec"      // 使用的装备牌
#define kReducedCardCount           @"rcc"      // 减少的牌数 - setInt
#define kHeroSkillId                @"hsi"      // 英雄技能 - setInt
#define kTargetPlayers              @"tp"       // 指定的目标玩家们 - setIntArray


//#define kJustJoinedPlayer           @"jjp"      // 刚刚加入房间的一个玩家 － setInt
//#define kAlreadyJoinedPlayers       @"ajp"      // 之前已经加入房间的玩家们 - setIntArray
//#define kToBeSelectedHeros          @"tbsh"     // 待选英雄 - setIntArray
//#define kSelectedHero               @"sh"       // 玩家选中的英雄 - setInt
//#define kPlayerOfSelectedHero       @"posh"     // 选中英雄的玩家 - setInt
//#define kPlayerWithSelectedHero     @"pwsh"     // 刚刚选择英雄的玩家(附带英雄ID属性) - setEsObject
//#define kPlayersWithSelectedHero    @"pswsh"    // 之前已经选择了英雄的玩家们(附带英雄ID属性) - setEsObjectArray

#endif
