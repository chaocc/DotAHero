//
//  BGRoleCardComponent.m
//  DotAHero
//
//  Created by Killua Liu on 5/30/13.
//
//

#import "BGRoleCardComponent.h"

@implementation BGRoleCardComponent

- (id)initWithRoleId:(BGRoleCard)aRoleId
{
    if (self = [super init]) {
        NSString *path = [[NSBundle mainBundle] pathForResource:@"RoleCardArray" ofType:@"plist"];
        self.roleArray = [NSArray arrayWithContentsOfFile:path];
        
        _roleId = aRoleId;
        _faction = _roleArray[aRoleId];
    }
    return self;
}

+ (id)roleCardComponentWithId:(BGRoleCard)aRoleId
{
    return [[self alloc]initWithRoleId:aRoleId];
}

@end
