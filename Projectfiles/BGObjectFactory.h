//
//  BGObjectFactory.h
//  DotAHero
//
//  Created by Killua Liu on 5/29/13.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "BGObjectManager.h"
#import "BGObject.h"

@interface BGObjectFactory : CCNode

- (id)initWithObjectManager:(BGObjectManager *)objectManager;
+ (id)objectFactoryWithObjectManager:(BGObjectManager *)objectManager;

- (BGObject *)createCardSystem;
- (BGObject *)createHumanPlayer:(NSArray *)characterCards;
- (BGObject *)createAIPlayer;

@end
