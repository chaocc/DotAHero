//
//  BGPlayingMenu.h
//  DotAHero
//
//  Created by Killua Liu on 7/1/13.
//
//

#import "CCNode.h"
#import "BGMenuFactory.h"

typedef NS_ENUM(NSInteger, BGPlayingMenuType) {
    kPlayingMenuTypeCardOkay,       // 通过拼点切牌/交给其他玩家牌/确定弃牌
    kPlayingMenuTypeCardUsing,      // 使用
    kPlayingMenuTypeCardPlaying,    // 打出
    kPlayingMenuTypeHeroSkill,      // 英雄技能
    kPlayingMenuTypeEquipment,      // 发动装备
    kPlayingMenuTypeDispel,         // 驱散
    kPlayingMenuTypeStrengthen,     // 强化
    kPlayingMenuTypeCardColor       // 卡牌颜色
};

typedef NS_ENUM(NSInteger, BGPlayingMenuItemTag) {
    kPlayingMenuItemTagOkay,        // 确定
    kPlayingMenuItemTagCancel,      // 取消
    kPlayingMenuItemTagDiscard,     // 弃牌
    kPlayingMenuItemTagStrengthen,  // 强化
    kPlayingMenuItemTagIgnore,      // 忽略驱散
    kPlayingMenuItemTagRedColor,    // 红色
    kPlayingMenuItemTagBlackColor,  // 黑色
    kPlayingMenuItemTagHearts,      // 红桃
    kPlayingMenuItemTagDiamonds,    // 方块
    kPlayingMenuItemTagSpades,      // 黑桃
    kPlayingMenuItemTagClubs        // 梅花
};

@class BGPlayer;

@interface BGPlayingMenu : CCNode <BGMenuFactoryDelegate>

@property(nonatomic, readonly) BGPlayingMenuType menuType;
@property(nonatomic, strong, readonly) CCMenu *menu;

- (id)initWithMenuType:(BGPlayingMenuType)menuType ofPlayer:(BGPlayer *)player;
+ (id)playingMenuWithMenuType:(BGPlayingMenuType)menuType ofPlayer:(BGPlayer *)player;

@end
