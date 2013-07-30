//
//  BGHeroSkill.m
//  DotAHero
//
//  Created by Killua Liu on 7/29/13.
//
//

#import "BGHeroSkill.h"

@interface BGHeroSkill ()

@property (nonatomic, strong) NSArray *skillArray;

@end

@implementation BGHeroSkill

- (id)initWithSkillId:(NSInteger)aSkillId
{
    if (self = [super init]) {
        NSString *path = [[NSBundle mainBundle] pathForResource:@"HeroSkillArray" ofType:@"plist"];
        self.skillArray = [NSArray arrayWithContentsOfFile:path];
        NSAssert((aSkillId > kHeroSkillDefault) &&
                 (aSkillId < (NSInteger)_skillArray.count), @"Invalid hero skill id in %@", NSStringFromSelector(_cmd));
        NSDictionary *dictionary = _skillArray[aSkillId];
        
        _skillId = aSkillId;
        _skillEnum = aSkillId;
        _skillCategory = [dictionary[kHeroSkillCategory] integerValue];
        _skillType = [dictionary[kHeroSkillType] integerValue];
        _isMandatorySkill = [dictionary[kIsMandatorySkill] boolValue];
        _canBeDispeled = [dictionary[kCanBeDispelled] boolValue];
        _skillText = dictionary[kHeroSkillText];
    }
    return self;
}

+ (id)heroSkillWithSkillId:(NSInteger)aSkillId
{
    return [[self alloc] initWithSkillId:aSkillId];
}

@end
