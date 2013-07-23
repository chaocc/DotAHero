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

- (id)createMenuWithSpriteFrameName:(NSString *)frameName selectedFrameName:(NSString *)selFrameName disabledFrameName:(NSString *)disFrameName;
- (id)createMenuWithSpriteFrameNames:(NSArray *)frameNames selectedFrameNames:(NSArray *)selFrameNames disabledFrameNames:(NSArray *)disFrameNames;
- (id)createMenuWithCards:(NSArray *)cards;

- (void)addMenuItemsWithCards:(NSArray *)cards toMenu:(CCMenu *)menu;
- (void)addMenuItemWithCardBackFrameName:(NSString *)frameName toMenu:(CCMenu *)menu;

@end
