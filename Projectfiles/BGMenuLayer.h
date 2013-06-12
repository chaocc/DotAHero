//
//  BGMenuLayer.h
//  DotAHero
//
//  Created by Killua Liu on 6/11/13.
//
//

#import "CCLayer.h"

@protocol BGMenuLayerDelegate <NSObject>

- (void)menuItemTouched:(CCMenuItem *)menuItem;

@end

@interface BGMenuLayer : CCLayer

@property (nonatomic, weak) id<BGMenuLayerDelegate> delegate;
@property (nonatomic, strong) CCMenu *menu;

- (id)initWithSpriteFrameNames:(NSArray *)spriteFrameNames;

+ (id)menuLayerWithSpriteFrameNames:(NSArray *)spriteFrameNames;

@end
