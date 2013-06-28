//
//  BGPlayingArea.m
//  DotAHero
//
//  Created by Killua Liu on 6/14/13.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

#import "BGPlayingArea.h"
#import "BGPlayingCardComponent.h"

@implementation BGPlayingArea

- (id)initWithPlayingCards:(NSArray *)cards
{
    if (self = [super init]) {
//        _playingCard = [BGPlayingCardComponent playingCardComponentWithId:cards];
        [cards enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            
        }];
    }
    return self;
}

+ (id)playingAreaWithPlayingCards:(NSArray *)cards
{
    return [[self alloc] initWithPlayingCards:cards];
}

@end
