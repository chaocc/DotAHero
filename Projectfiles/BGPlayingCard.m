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

@end

@implementation BGPlayingCard

@synthesize cardColor = _cardColor;

- (id)initWithCardId:(NSInteger)aCardId
{
    if (self = [super initWithCardId:aCardId]) {
//      Get playing card enumeration/figure/suits by card id
        NSString *path = [[NSBundle mainBundle] pathForResource:kPlistPlayingCardIds ofType:kFileTypePlist];
        NSArray *array = [NSArray arrayWithContentsOfFile:path];
        NSAssert((aCardId > kPlayingCardInvalid) &&
                 (aCardId < (NSInteger)array.count), @"Invalid playing card id in %@", NSStringFromSelector(_cmd));
        NSDictionary *dictionary = array[aCardId];
        
        _cardEnum = [dictionary[kCardEnum] integerValue];
        _cardFigure = [dictionary[kCardFigure] integerValue];
        _cardSuits = [dictionary[kCardSuits] integerValue];
        
//      Read playing card detail property by card enumeration
        path = [[NSBundle mainBundle] pathForResource:kPlistPlayingCardList ofType:kFileTypePlist];
        array = [NSArray arrayWithContentsOfFile:path];
        dictionary = array[_cardEnum];
        
        _cardName = dictionary[kCardName];
        _cardText = dictionary[kCardText];
        _cardType = [dictionary[kCardType] integerValue];
        _needSpecifyTarget = [dictionary[kNeedSpecifyTarget] boolValue];
        _targetCount = [dictionary[kTargetCount] integerValue];
        
        _canBeStrengthened = [dictionary[kCanBeStrengthened] boolValue];
        _requiredAnger = [dictionary[kRequiredAnger] integerValue];
        
        _equipmentType = [dictionary[kEquipmentType] integerValue];
        _attackRange = [dictionary[kAttackRange] integerValue];
        _canBeUsedActive = [dictionary[kCanBeUsedActive] boolValue];
        _onlyEquipOne = [dictionary[kOnlyEquipOne] boolValue];
        
        _tipText = dictionary[kTipText];
        _targetTipText = dictionary[kTargetTipText];
        _dispelTipText = dictionary[kDispelTipText];
        _equipTipText = dictionary[kEquipTipText];
        
        _isVerticalSet = YES;
    }
    return self;
}

+ (id)cardWithCardId:(NSInteger)aCardId
{
    return [[self alloc]initWithCardId:aCardId];
}

+ (NSArray *)playingCardsWithCardIds:(NSArray *)cardIds
{
    NSMutableArray *cards = [NSMutableArray arrayWithCapacity:cardIds.count];
    [cardIds enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        [cards addObject:[BGPlayingCard cardWithCardId:[obj integerValue]]];
    }];
    return cards;
}

+ (NSArray *)playingCardIdsWithCards:(NSArray *)cards
{
    NSMutableArray *cardIds = [NSMutableArray arrayWithCapacity:cards.count];
    [cards enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        [cardIds addObject:@([obj cardId])];
    }];
    return cardIds;
}

+ (NSArray *)playingCardIdsWithMenu:(CCMenu *)menu
{
    NSMutableArray *cardIds = [NSMutableArray array];
    [[menu.children getNSArray] enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        [cardIds addObject:@([obj tag])];
    }];
    
    return cardIds;
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

#pragma mark - Image
- (NSString *)figureImageName
{
    return (_cardColor == kCardColorRed) ?
        [NSString stringWithFormat:@"Red%i.png", _cardFigure] :
        [NSString stringWithFormat:@"Black%i.png", _cardFigure];
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

#pragma mark - Tip text
- (NSString *)tipTextWith:(NSString *)text parameters:(NSArray *)params
{
    NSString *tipText = [text copy];
    for (NSString *param in params) {
        NSRange range = [tipText rangeOfString:@"&"];
        if (range.length > 0) {
            tipText = [tipText stringByReplacingCharactersInRange:range withString:param];
        }
    }
    
    return tipText;
}

@end
