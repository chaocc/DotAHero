//
//  BGDensityCard.m
//  DotAHero
//
//  Created by Killua Liu on 5/30/13.
//
//

#import "BGDensityCard.h"

@interface BGDensityCard()

@end

@implementation BGDensityCard

- (id)initWithCardId:(NSInteger)aCardId
{
    if (self = [super initWithCardId:aCardId]) {
        NSString *path = [[NSBundle mainBundle] pathForResource:kPlistDensityCardList ofType:kFileTypePlist];
        NSArray *array = [NSArray arrayWithContentsOfFile:path];
        NSAssert((aCardId > kDensityCardInvalid) &&
                 (aCardId < (NSInteger)array.count), @"Invalid density card id in %@", NSStringFromSelector(_cmd));
        NSDictionary *dictionary = array[aCardId];
        
        _cardEnum = aCardId;
        _cardName = dictionary[kCardName];
        _cardText = dictionary[kCardText];
        _description = dictionary[kDescription];
    }
    return self;
}

+ (id)cardWithCardId:(NSInteger)aCardId
{
    return [[self alloc] initWithCardId:aCardId];
}

- (NSString *)cardImageName
{
    return [_cardName stringByAppendingPathExtension:kFileTypeJpg];
}

@end
