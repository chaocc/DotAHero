//
//  BGDensity.m
//  DotAHero
//
//  Created by Killua Liu on 6/11/13.
//
//

#import "BGDensity.h"

@implementation BGDensity

- (id)initWithDensityCardId:(NSInteger)cardId
{
    if (self = [super init]) {
        _densityCard = [BGDensityCard cardWithCardId:cardId];
    }
    return self;
}

+ (id)densityWithDensityCardId:(NSInteger)cardId
{
    return [[self alloc] initWithDensityCardId:cardId];
}

@end
