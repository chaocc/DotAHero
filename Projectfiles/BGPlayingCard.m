//
//  BGPlayingCard.m
//  DotAHero
//
//  Created by Killua Liu on 5/30/13.
//
//

#import "BGPlayingCard.h"
#import "BGFileConstants.h"

@interface BGPlayingCard ()

@property (nonatomic, strong) NSArray *playingCardArray;

@end

@implementation BGPlayingCard

@synthesize cardColor = _cardColor;

- (id)initWithCardId:(NSInteger)aCardId
{
    if (self = [super initWithCardId:aCardId]) {
        NSString *path = [[NSBundle mainBundle] pathForResource:@"PlayingCardArray" ofType:@"plist"];
        self.playingCardArray = [NSArray arrayWithContentsOfFile:path];
        NSAssert((aCardId > kPlayingCardDefault) &&
                 (aCardId < (NSInteger)_playingCardArray.count), @"Invalid playing card id in %@", NSStringFromSelector(_cmd));
        NSDictionary *dictionary = _playingCardArray[aCardId];
        
        _cardEnum = [dictionary[kCardEnum] integerValue];
        _cardName = dictionary[kCardName];
        _cardFigure = [dictionary[kCardFigure] integerValue];
        _cardSuits = [dictionary[kCardSuits] integerValue];
        
        _cardType = [dictionary[kCardType] integerValue];
        _whenToUse = dictionary[kWhenToUse];
        _cardEffect = dictionary[kCardEffect];
        _maxTargetCount = [dictionary[kMaxTargetCount] integerValue];
        
        _canBeStrengthed = [dictionary[kCanBeStrengthed] boolValue];
        _requiredMana = [dictionary[kRequiredMana] integerValue];
        
        _equipmentType = [dictionary[kEquipmentType] integerValue];
        _attackRange = [dictionary[kAttackRange] integerValue];
        _onlyEquipOne = [dictionary[kOnlyEquipOne] boolValue];
    }
    return self;
}

+ (id)cardWithCardId:(NSInteger)aCardId
{
    return [[self alloc]initWithCardId:aCardId];
}

- (BGCardColor)cardColor
{
    if (_cardSuits == kCardSuitsHearts || _cardSuits == kCardSuitsDiamonds) {
        _cardColor = kCardColorRed;
    } else {
        _cardColor = kCardColorBlack;
    }
    return _cardColor;
}

- (NSString *)figureImageName
{
    return (_cardColor == kCardColorRed) ? [NSString stringWithFormat:@"Red%i.png", _cardFigure] : [NSString stringWithFormat:@"Black%i.png", _cardFigure];
}

- (NSString *)suitsImageName
{
    switch (_cardSuits) {
        case kCardSuitsHearts:
            return kImageHearts;
            break;
        case kCardSuitsDiamonds:
            return kImageDiamonds;
            break;
        case kCardSuitsSpades:
            return kImageSpades;
            break;
        case kCardSuitsClubs:
            return kImageClubs;
            break;
        default:
            return nil;
            break;
    }
}

- (NSString *)equipImageName
{
    if (_cardType == kCardTypeEquipment) {
        return [_cardName stringByAppendingString:@"Avatar.png"];
    }
    return nil;
}

- (NSString *)bigEquipImageName
{
    if (_cardType == kCardTypeEquipment) {
        return [_cardName stringByAppendingString:@"Avatar_Big.png"];
    }
    return nil;
}

@end
