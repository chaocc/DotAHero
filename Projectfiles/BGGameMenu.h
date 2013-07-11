//
//  BGMenu.h
//  DotAHero
//
//  Created by Killua Liu on 6/25/13.
//
//

#import "CCNode.h"
#import "BGMenuFactory.h"

@interface BGGameMenu : CCNode <BGMenuFactoryDelegate>

- (id)init;
+ (id)menu;

@end
