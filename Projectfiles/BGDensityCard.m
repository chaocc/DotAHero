//
//  BGDensityCard.m
//  DotAHero
//
//  Created by Killua Liu on 5/30/13.
//
//

#import "BGDensityCard.h"

@interface BGDensityCard()

@property (nonatomic, strong) NSArray *densityArray;

@end

@implementation BGDensityCard

- (id)initWithCardId:(NSUInteger)aCardId
{
    if (self = [super initWithCardId:aCardId]) {
        NSString *path = [[NSBundle mainBundle] pathForResource:@"DensityCardArray" ofType:@"plist"];
        self.densityArray = [NSArray arrayWithContentsOfFile:path];
        NSAssert((aCardId < _densityArray.count), @"Invalid density card id");
        NSDictionary *dictionary = _densityArray[aCardId];
        
        _cardEnum = aCardId;
        _cardName = dictionary[kCardName];
        _cardText = dictionary[kCardText];
        _description = dictionary[kDescription];
    }
    return self;
}

+ (id)cardWithCardId:(NSUInteger)aCardId
{
    return [[self alloc] initWithCardId:aCardId];
}

- (NSString *)cardImageName
{
    return [_cardName stringByAppendingString:@".jpg"];
}

@end
