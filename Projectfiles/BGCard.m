//
//  BGCard.m
//  DotAHero
//
//  Created by Killua Liu on 6/30/13.
//
//

#import "BGCard.h"

@implementation BGCard

- (id)initWithCardId:(NSInteger)aCardId
{
    if (self = [super init]) {
        _cardId = aCardId;
    }
    return self;
}

+ (id)cardWithCardId:(NSInteger)aCardId
{
    return [[self alloc] initWithCardId:aCardId];
}

- (NSString *)cardImageName
{
    return [_cardName stringByAppendingPathExtension:kFileTypePng];
}

- (BOOL)isEqual:(id)object
{
    return (_cardId == [object cardId]);
}

@end
