//
//  BGCard.m
//  DotAHero
//
//  Created by Killua Liu on 6/30/13.
//
//

#import "BGCard.h"

@implementation BGCard

- (id)initWithCardId:(NSUInteger)aCardId
{
    if (self = [super init]) {
        _cardId = aCardId;
    }
    return self;
}

+ (id)cardWithCardId:(NSUInteger)aCardId
{
    return [[self alloc] initWithCardId:aCardId];
}

- (NSString *)cardImageName
{
    return [_cardName stringByAppendingString:@".png"];
}

@end
