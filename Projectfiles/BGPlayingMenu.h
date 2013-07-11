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
    kPlayingMenuTypeCardUsing,      // 使用
    kPlayingMenuTypeCardPlaying,    // 打出
    kPlayingMenuTypeHeroSkill,
    kPlayingMenuTypeEquipment,
    kPlayingMenuTypeDispel
};

typedef NS_ENUM(NSInteger, BGPlayingMenuItemIndex) {
    kPlayingMenuItemTagOkay,        // 确定
    kPlayingMenuItemTagCancel,      // 取消
    kPlayingMenuItemTagDiscard,     // 弃牌
    kPlayingMenuItemTagIgnore       // 忽略驱散
};

@class BGPlayer;

@interface BGPlayingMenu : CCNode <BGMenuFactoryDelegate>

@property(nonatomic, readonly) BGPlayingMenuType menuType;
@property(nonatomic, strong) CCMenu *menu;

- (id)initWithMenuType:(BGPlayingMenuType)menuType ofPlayer:(BGPlayer *)player;
+ (id)playingMenuWithMenuType:(BGPlayingMenuType)menuType ofPlayer:(BGPlayer *)player;

- (void)addMenuItems;

@end
