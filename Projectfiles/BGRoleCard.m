//
//  BGRoleCard.m
//  DotAHero
//
//  Created by Killua Liu on 5/30/13.
//
//

#import "BGRoleCard.h"

@interface BGRoleCard ()

@property (nonatomic, strong) NSArray *roleArray;

@end

@implementation BGRoleCard

- (id)initWithCardId:(NSInteger)aCardId
{
    if (self = [super initWithCardId:aCardId]) {
        NSString *path = [[NSBundle mainBundle] pathForResource:@"RoleCardArray" ofType:@"plist"];
        self.roleArray = [NSArray arrayWithContentsOfFile:path];
        NSAssert((aCardId > kRoleCardDefault) &&
                 (aCardId < (NSInteger)_roleArray.count), @"Invalid Role card id in %@", NSStringFromSelector(_cmd));
        NSDictionary *dictionary = _roleArray[aCardId];
        
        _cardEnum = [dictionary[kCardEnum] integerValue];
        _cardName = dictionary[kCardName];
        _cardText = dictionary[kCardText];
    }
    return self;
}

+ (id)cardWithCardId:(NSInteger)aCardId
{
    return [[self alloc]initWithCardId:aCardId];
}

@end
