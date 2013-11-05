//
//  BGHeroSkill.m
//  DotAHero
//
//  Created by Killua Liu on 7/29/13.
//
//

#import "BGHeroSkill.h"
#import "BGFileConstants.h"

@interface BGHeroSkill ()

@end

@implementation BGHeroSkill

- (id)initWithSkillId:(NSInteger)aSkillId
{
    if (self = [super init]) {
        NSString *path = [[NSBundle mainBundle] pathForResource:kPlistHeroSkillList ofType:kFileTypePlist];
        NSArray *array = [NSArray arrayWithContentsOfFile:path];
        NSAssert((aSkillId > kHeroSkillInvalid) &&
                 (aSkillId < (NSInteger)array.count), @"Invalid hero skill id in %@", NSStringFromSelector(_cmd));
        NSDictionary *dictionary = array[aSkillId];
        
        _skillId = aSkillId;
        _skillEnum = aSkillId;
        _skillCategory = [dictionary[kHeroSkillCategory] integerValue];
        _skillType = [dictionary[kHeroSkillType] integerValue];
        _isMandatory = [dictionary[kIsMandatorySkill] boolValue];
        _canBeDispeled = [dictionary[kCanBeDispelled] boolValue];
        _skillText = dictionary[kHeroSkillText];
    }
    return self;
}

+ (id)heroSkillWithSkillId:(NSInteger)aSkillId
{
    return [[self alloc] initWithSkillId:aSkillId];
}

- (BOOL)isActive
{
    return (kHeroSkillCategoryActive == _skillCategory);
}

@end
