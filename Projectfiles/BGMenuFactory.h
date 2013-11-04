//
//  BGMenuFactory.h
//  DotAHero
//
//  Created by Killua Liu on 6/25/13.
//
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, BGMenuTag) {
    kMenuTagGameMenu,
    kMenuTagTrust,
    kMenuTagChat,
    kMenuTagViewGame,
    kMenuTagSetting,
    kMenuTagExitGame,
    
    kMenuTagOkay,
    kMenuTagCancel,
    kMenuTagDiscard,
    kMenuTagIgnoreDispel
};

@protocol BGMenuFactoryDelegate <NSObject>

- (void)menuItemTouched:(CCMenuItem *)menuItem;

@end

@interface BGMenuFactory : NSObject

@property (nonatomic, weak) id<BGMenuFactoryDelegate> delegate;

+ (id)menuFactory;

- (CCMenu *)createMenuWithSpriteFrameName:(NSString *)frameName;
- (CCMenu *)createMenuWithSpriteFrameNames:(NSArray *)frameNames;
- (CCMenu *)createMenuWithSpriteFrameName:(NSString *)frameName selectedFrameName:(NSString *)selFrameName disabledFrameName:(NSString *)disFrameName;
- (CCMenu *)createMenuWithSpriteFrameNames:(NSArray *)frameNames selectedFrameNames:(NSArray *)selFrameNames disabledFrameNames:(NSArray *)disFrameNames;
- (CCMenu *)createMenuWithCards:(NSArray *)cards;
- (CCMenu *)createCardBackMenuWithCount:(NSUInteger)count;

- (NSArray *)createMenuItemsWithCards:(NSArray *)cards;
- (NSArray *)createCardBackMenuItemsWithCount:(NSUInteger)count;
- (NSArray *)createMenuitemsWithSpriteFrameNames:(NSArray *)frameNames;

- (CCMenuItem *)createMenuItemWithPlayingCard:(id)card;
- (CCMenuItem *)createMenuItemWithSpriteFrameName:(NSString *)frameName;

- (void)addMenuItemsWithCards:(NSArray *)cards toMenu:(CCMenu *)menu;
- (void)addCardBackMenuItemsWithCount:(NSUInteger)count toMenu:(CCMenu *)menu;
- (void)addMenuItemsWithSpriteFrameNames:(NSArray *)frameNames toMenu:(CCMenu *)menu;
- (void)addMenuItemWithSpriteFrameName:(NSString *)frameName isEnabled:(BOOL)isEnabled toMenu:(CCMenu *)menu;

@end
