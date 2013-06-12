//
//  BGObjectFactory.m
//  DotAHero
//
//  Created by Killua Liu on 5/29/13.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

#import "BGObjectFactory.h"
#import "BGHero.h"


@interface BGObjectFactory ()

@property (nonatomic, strong) BGObjectManager *objectManager;

@end

@implementation BGObjectFactory

- (id)initWithObjectManager:(BGObjectManager *)objectManager
{
    if (self = [super init]) {
        self.objectManager = objectManager;
    }
    return self;
}

+ (id)objectFactoryWithObjectManager:(BGObjectManager *)objectManager
{
    return [[self alloc] initWithObjectManager:objectManager];
}

- (BGObject *)createCardSystem
{
    BGObject *cardSystem = [_objectManager createObject];
    return cardSystem;
}

- (BGObject *)createHumanPlayer:(NSArray *)heroCards
{
    BGObject *humanPlayer = [_objectManager createObject];
    
    BGHero *hero = [BGHero heroWithHeroCards:heroCards];
    [_objectManager addComponent:hero toObject:humanPlayer];
    [humanPlayer addChild:hero];
    
    return humanPlayer;
}

- (BGObject *)createAIPlayer
{
    BGObject *aiPlayer = [_objectManager createObject];
    return aiPlayer;
}

@end
