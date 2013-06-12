//
//  BGPlayingCardComponent.m
//  DotAHero
//
//  Created by Killua Liu on 5/30/13.
//
//

#import "BGPlayingCardComponent.h"

@implementation BGPlayingCardComponent

@synthesize cardColor = _cardColor;

- (id)initWithPlayingCardId:(BGPlayingCard)aPlayingCardId
{
    if (self = [super init]) {
        NSString *path = [[NSBundle mainBundle] pathForResource:@"PlayingCardArray" ofType:@"plist"];
        self.playingCardArray = [NSArray arrayWithContentsOfFile:path];
        NSDictionary *dictionary = _playingCardArray[aPlayingCardId];
        
        _playingCardId = aPlayingCardId;
        _cardName = dictionary[kCardName];
        
        _cardType = [(NSNumber *)dictionary[kCardType] integerValue];
        _whenToUse = dictionary[kWhenToUse];
        _cardEffect = dictionary[kCardEffect];
        _maxTargetCount = [(NSNumber *)dictionary[kMaxTargetCount] integerValue];
        
        _canBeStrengthed = [(NSNumber *)dictionary[kCanBeStrengthed] boolValue];
        _requiredMana = [(NSNumber *)dictionary[kRequiredMana] integerValue];
        
        _equipmentType = [(NSNumber *)dictionary[kEquipmentType] integerValue];
        _onlyEquipOne = [(NSNumber *)dictionary[kOnlyEquipOne] boolValue];
        _attackRange = [(NSNumber *)dictionary[kAttackRange] integerValue];
    }
    return self;
}

+ (id)playingCardComponentWithId:(BGPlayingCard)aPlayingCardId
{
    return [[self alloc]initWithPlayingCardId:aPlayingCardId];
}

- (BGCardColor)cardColor
{
    if (_cardSuits == kHearts || _cardSuits == kDiamonds) {
        _cardColor = kRedColor;
    } else {
        _cardColor = kBlackColor;
    }
    return _cardColor;
}

@end
