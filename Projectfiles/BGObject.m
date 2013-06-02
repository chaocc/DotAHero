//
//  BGObject.m
//  DotAHero
//
//  Created by Killua Liu on 5/29/13.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

#import "BGObject.h"


@implementation BGObject

- (id)initWithObjectId:(NSInteger)objId
{
    if (self = [super init]) {
        _objectId = objId;
    }
    
    return self;
}

+ (id)objectWithObjectId:(NSInteger)objId
{
    return [[self alloc] initWithObjectId:objId];
}

@end
