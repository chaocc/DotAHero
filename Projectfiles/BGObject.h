//
//  BGObject.h
//  DotAHero
//
//  Created by Killua Liu on 5/29/13.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"

@interface BGObject : CCNode

@property (nonatomic, readonly) NSInteger objectId;

- (id)initWithObjectId:(NSInteger)objId;
+ (id)objectWithObjectId:(NSInteger)objId;

@end
