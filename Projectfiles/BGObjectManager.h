//
//  BGObjectManager.h
//  DotAHero
//
//  Created by Killua Liu on 5/29/13.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BGObject.h"
#import "BGComponent.h"

@interface BGObjectManager : NSObject

+ (id)sharedObjectManager;

- (NSInteger)generateNewObjectId;
- (BGObject *)createObject;

- (void)addComponent:(BGComponent *)component toObject:(BGObject *)object;
- (BGComponent *)getComponentOfClass:(Class)class forObject:(BGObject *)object;

- (void)removeObject:(BGObject *)object;
- (NSArray *)getAllObjectesPossessingComponentOfClass:(Class)class;

@end
