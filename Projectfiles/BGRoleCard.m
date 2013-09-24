//
//  BGRoleCard.m
//  DotAHero
//
//  Created by Killua Liu on 5/30/13.
//
//

#import "BGRoleCard.h"

@interface BGRoleCard ()

@end

@implementation BGRoleCard

- (id)initWithCardId:(NSInteger)aCardId
{
    if (self = [super initWithCardId:aCardId]) {
        NSString *path = [[NSBundle mainBundle] pathForResource:kPlistRoleCardList ofType:kFileTypePlist];
        NSArray *array = [NSArray arrayWithContentsOfFile:path];
        NSAssert((aCardId > kRoleCardInvalid) &&
                 (aCardId < (NSInteger)array.count), @"Invalid Role card id in %@", NSStringFromSelector(_cmd));
        NSDictionary *dictionary = array[aCardId];
        
        _cardEnum = [dictionary[kCardEnum] integerValue];
        _cardName = dictionary[kCardName];
        _cardText = dictionary[kCardText];
    }
    return self;
}

+ (id)cardWithCardId:(NSInteger)aCardId
{
    return [[self alloc]initWithCardId:aCardId];
}

@end
