//
//  BGCharacterCardComponent.m
//  DotAHero
//
//  Created by Killua Liu on 5/30/13.
//
//

#import "BGCharacterCardComponent.h"

@implementation BGCharacterCardComponent

- (id)initWithCharacter:(BGCharacterCard)aCharacter
{
    if (self = [super init]) {
        NSString *path = [[NSBundle mainBundle] pathForResource:@"CharacterCardArray" ofType:@"plist"];
        self.characterArray = [NSArray arrayWithContentsOfFile:path];
        NSDictionary *dictionary = _characterArray[aCharacter];
        
        _character = aCharacter;
        _heroName = dictionary[kHeroName];
        _heroSkills = dictionary[kHeroSkills];
        
        _heroAttibute = [(NSNumber *)dictionary[kHeroAttribute] integerValue];
        _healthPointLimit = [(NSNumber *)dictionary[kHandSizeLimit] integerValue];
        _manaPointLimit = [(NSNumber *)dictionary[kManaPointLimit] integerValue];
        _handSizeLimit = [(NSNumber *)dictionary[kHandSizeLimit] integerValue];
    }
    
    return self;
}

+ (id)characterCardComponentWithCard:(BGCharacterCard)aCharacterCard
{
    return [[self alloc]initWithCharacter:aCharacterCard];
}

@end
