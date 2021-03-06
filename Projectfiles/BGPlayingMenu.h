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
    kPlayingMenuTypeOkay,           // 通过拼点切牌/交给其他玩家牌/确定弃牌
    kPlayingMenuTypePlaying,        // 自己回合开始 - 主动使用
    kPlayingMenuTypeChoosing,       // 其他玩家回合 - 被动打出
    kPlayingMenuTypeStrengthening,  // 主动使用 - 带强化
    kPlayingMenuTypeDispelling,     // 被动打出 - 带忽略驱散
    kPlayingMenuTypeCardColor,      // 卡牌颜色
    kPlayingMenuTypeCardSuits       // 卡片花色
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

@protocol BGPlayingMenuDelegate <NSObject>

- (void)playingMenuItemTouched:(CCMenuItem *)menuItem;

@end

@class BGPlayer;

@interface BGPlayingMenu : CCNode <BGMenuFactoryDelegate>

@property (nonatomic, weak) id<BGPlayingMenuDelegate> delegate;

@property (nonatomic, strong) BGMenuFactory *menuFactory;
@property (nonatomic, readonly) NSUInteger menuItemCount;
@property (nonatomic, readonly) BOOL isStrengthening;   // 是否有"强化"按钮

@property (nonatomic) CGPoint menuPosition;

- (id)initWithMenuType:(BGPlayingMenuType)menuType;
- (id)initWithMenuType:(BGPlayingMenuType)menuType isEnabled:(BOOL)isEnabled;

+ (id)playingMenuWithMenuType:(BGPlayingMenuType)menuType;
+ (id)playingMenuWithMenuType:(BGPlayingMenuType)menuType isEnabled:(BOOL)isEnabled;

- (CCMenuItem *)menuItemByTag:(NSInteger)tag;

@end
