//
//  BGEquipmentArea.m
//  DotAHero
//
//  Created by Killua Liu on 5/30/13.
//
//

#import "BGEquipmentArea.h"

@implementation BGEquipmentArea

- (id)initWithEquipmentCard:(BGPlayingCard)card
{
    if (self = [super init]) {
        _equipmentCard = [BGPlayingCardComponent playingCardComponentWithId:card];
    }
    return self;
}

+ (id)equipmentWithEquipmentCard:(BGPlayingCard)card
{
    return [[self alloc] initWithEquipmentCard:card];
}

@end
