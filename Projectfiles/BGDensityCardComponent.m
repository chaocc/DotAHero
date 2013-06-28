//
//  BGDensityCardComponent.m
//  DotAHero
//
//  Created by Killua Liu on 5/30/13.
//
//

#import "BGDensityCardComponent.h"

@interface BGDensityCardComponent()

@property (nonatomic, strong) NSArray *densityArray;

@end

@implementation BGDensityCardComponent

- (id)initWithDensityId:(BGDensityCard)aDensityId
{
    if (self = [super init]) {
        NSString *path = [[NSBundle mainBundle] pathForResource:@"DensityCardArray" ofType:@"plist"];
        self.densityArray = [NSArray arrayWithContentsOfFile:path];
        
        _densityId = aDensityId;
        _taskName = _densityArray[aDensityId];
    }
    return self;
}

+ (id)densityCardComponentWithId:(BGDensityCard)aDensityId
{
    return [[self alloc]initWithDensityId:aDensityId];
}

@end
