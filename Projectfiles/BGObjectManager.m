//
//  BGObjectManager.m
//  DotAHero
//
//  Created by Killua Liu on 5/29/13.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

#import "BGObjectManager.h"


@implementation BGObjectManager {
    NSMutableArray *_objects;
    NSMutableDictionary *_componentsByClass;
    NSInteger _lowestUnassignedObjectId;
}

- (id)init
{
    if (self = [super init]) {
        _objects = [NSMutableArray array];
        _componentsByClass = [NSMutableDictionary dictionary];
        _lowestUnassignedObjectId = 1;
    }
    
    return self;
}

+ (id)sharedObjectManager
{
    return [[self alloc] init];
}

- (NSInteger)generateNewObjectId
{
    if (_lowestUnassignedObjectId < NSIntegerMax) {
        return _lowestUnassignedObjectId++;
    } else {
        for (NSInteger i = 1; i < NSIntegerMax; i++) {
            if (![_objects containsObject:@(i)]) {
                return i;
            }
        }
        
        NSLog(@"ERROR: No Available ObjectIds!");
        return 0;
    }
}

- (BGObject *)createObject
{
    NSInteger objectId = [self generateNewObjectId];
    [_objects addObject:@(objectId)];
    
    return [BGObject objectWithObjectId:objectId];
}

- (void)addComponent:(BGComponent *)component toObject:(BGObject *)object
{
    NSMutableDictionary *components = _componentsByClass[NSStringFromClass(component.class)];
    if (!components) {
        components = [NSMutableDictionary dictionary];
        _componentsByClass[NSStringFromClass(component.class)] = components;
    }
    [components setObject:component forKey:@(object.objectId)];
}

- (BGComponent *)getComponentOfClass:(Class)class forObject:(BGObject *)object
{
    return _componentsByClass[NSStringFromClass(class)][@(object.objectId)];
}

- (void)removeObject:(BGObject *)object
{
    for (NSMutableDictionary *components in _componentsByClass.allValues) {
        if (components[@(object.objectId)]) {
            [components removeObjectForKey:@(object.objectId)];
        }
    }
    
    [_objects removeObject:@(object.objectId)];
}

- (NSArray *)getAllObjectesPossessingComponentOfClass:(Class)class
{
    NSMutableDictionary *components = _componentsByClass[NSStringFromClass(class)];
    if (components) {
        NSMutableArray *retval = [NSMutableArray arrayWithCapacity:components.allValues.count];
        for (NSNumber *objId in components.allKeys) {
            [retval addObject:[BGObject objectWithObjectId:objId.integerValue]];
        }
        return retval;
    } else {
        return [NSArray array];
    }
}

@end
