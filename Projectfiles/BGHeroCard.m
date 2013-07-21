//
//  BGHeroCard.m
//  DotAHero
//
//  Created by Killua Liu on 5/30/13.
//
//

#import "BGHeroCard.h"

@interface BGHeroCard ()

@property (nonatomic, strong) NSArray *heroArray;

@end

@implementation BGHeroCard

- (id)initWithCardId:(NSInteger)aCardId
{
    if (self = [super initWithCardId:aCardId]) {
        NSString *path = [[NSBundle mainBundle] pathForResource:@"HeroCardArray" ofType:@"plist"];
        self.heroArray = [NSArray arrayWithContentsOfFile:path];
        NSAssert((aCardId > kHeroCardDefault) &&
                 (aCardId < (NSInteger)_heroArray.count), @"Invalid hero card id in %@", NSStringFromSelector(_cmd));
        NSDictionary *dictionary = _heroArray[aCardId];
        
        _cardEnum = aCardId;
        _cardName = dictionary[kHeroName];
        _heroSkills = dictionary[kHeroSkills];
        
        _heroAttibute = [dictionary[kHeroAttribute] integerValue];
        _bloodPointLimit = [dictionary[kBloodPointLimit] integerValue];
        _angerPointLimit = [dictionary[kAngerPointLimit] integerValue];
        _handSizeLimit = [dictionary[kHandSizeLimit] integerValue];
    }
    
    return self;
}

+ (id)cardWithCardId:(NSInteger)aCardId
{
    return [[self alloc]initWithCardId:aCardId];
}

- (NSString *)avatarName
{
    return [_cardName stringByAppendingString:@"Avatar.png"];
}

- (NSString *)bigAvatarName
{
    return [_cardName stringByAppendingString:@"Avatar_Big.png"];
}

@end
