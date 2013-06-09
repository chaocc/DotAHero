//
//  BGDensityCardComponent.m
//  DotAHero
//
//  Created by Killua Liu on 5/30/13.
//
//

#import "BGDensityCardComponent.h"

@implementation BGDensityCardComponent

- (id)initWithDensity:(BGDensityCard)aDensity
{
    if (self = [super init]) {
        NSString *path = [[NSBundle mainBundle] pathForResource:@"DensityCardArray" ofType:@"plist"];
        self.densityArray = [NSArray arrayWithContentsOfFile:path];
        
        _density = aDensity;
        _taskName = _densityArray[aDensity];
    }
    return self;
}

+ (id)densityCardComponentWithCard:(BGDensityCard)aDensity
{
    return [[self alloc]initWithDensity:aDensity];
}

@end
