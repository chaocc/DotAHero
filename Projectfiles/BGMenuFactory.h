//
//  BGMenuFactory.h
//  DotAHero
//
//  Created by Killua Liu on 6/25/13.
//
//

#import <Foundation/Foundation.h>

@protocol BGMenuFactoryDelegate <NSObject>

- (void)menuItemTouched:(CCMenuItem *)menuItem;

@end

@interface BGMenuFactory : NSObject

@property (nonatomic, weak) id<BGMenuFactoryDelegate> delegate;

+ (id)menuFactory;

- (id)createMenuWithSpriteFrameName:(NSString *)frameName selectedFrameName:(NSString *)selectedFrameName disabledFrameName:(NSString *)disabledFrameName;
- (id)createMenuWithSpriteFrameNames:(NSArray *)frameNames;
- (id)createMenuWithSpriteFrameNames:(NSArray *)frameNames ofObjects:(NSArray *)objects;

@end
