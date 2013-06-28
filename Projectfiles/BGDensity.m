//
//  BGDensity.m
//  DotAHero
//
//  Created by Killua Liu on 6/11/13.
//
//

#import "BGDensity.h"

@implementation BGDensity

- (id)initWithDensityCard:(BGDensityCard)card
{
    if (self = [super init]) {
        _densityCard = [BGDensityCardComponent densityCardComponentWithId:card];
    }
    return self;
}

+ (id)densityWithDensityCard:(BGDensityCard)card
{
    return [[self alloc] initWithDensityCard:card];
}

@end
