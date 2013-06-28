//
//  BGObjectFactory.m
//  DotAHero
//
//  Created by Killua Liu on 5/29/13.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

#import "BGObjectFactory.h"
#import "BGCurrentPlayer.h"


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

- (BGObject *)createGameRoom
{
    BGObject *gameRoom = [_objectManager createObject];
    return gameRoom;
}

- (BGObject *)createHumanPlayer:(NSArray *)heroCards
{
    BGObject *humanPlayer = [_objectManager createObject];
    
//    BGCurrentPlayer *player = [BGCurrentPlayer playerWithHeroCards:heroCards];
//    [_objectManager addComponent:(BGComponent *)player toObject:humanPlayer];
    
    return humanPlayer;
}

- (BGObject *)createAIPlayer
{
    BGObject *aiPlayer = [_objectManager createObject];
    return aiPlayer;
}

@end
