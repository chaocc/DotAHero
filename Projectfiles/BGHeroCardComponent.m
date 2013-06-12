//
//  BGCharacterCardComponent.m
//  DotAHero
//
//  Created by Killua Liu on 5/30/13.
//
//

#import "BGHeroCardComponent.h"

@implementation BGHeroCardComponent

- (id)initWithHeroId:(BGHeroCard)aHeroId
{
    if (self = [super init]) {
        NSString *path = [[NSBundle mainBundle] pathForResource:@"HeroCardArray" ofType:@"plist"];
        self.heroArray = [NSArray arrayWithContentsOfFile:path];
        NSDictionary *dictionary = _heroArray[aHeroId];
        
        _heroId = aHeroId;
        _heroName = dictionary[kHeroName];
        _heroSkills = dictionary[kHeroSkills];
        
        _heroAttibute = [(NSNumber *)dictionary[kHeroAttribute] integerValue];
        _healthPointLimit = [(NSNumber *)dictionary[kHandSizeLimit] integerValue];
        _manaPointLimit = [(NSNumber *)dictionary[kManaPointLimit] integerValue];
        _handSizeLimit = [(NSNumber *)dictionary[kHandSizeLimit] integerValue];
    }
    
    return self;
}

+ (id)heroCardComponentWithId:(BGHeroCard)aHeroId
{
    return [[self alloc]initWithHeroId:aHeroId];
}

@end
