//
//  BGRoleCardComponent.m
//  DotAHero
//
//  Created by Killua Liu on 5/30/13.
//
//

#import "BGRoleCardComponent.h"

@implementation BGRoleCardComponent

- (id)initWithRole:(BGRoleCard)aRole
{
    if (self = [super init]) {
        NSString *path = [[NSBundle mainBundle] pathForResource:@"RoleCardArray" ofType:@"plist"];
        self.roleArray = [NSArray arrayWithContentsOfFile:path];
        
        _role = aRole;
        _faction = _roleArray[aRole];
    }
    
    return self;
}

+ (id)roleCardComponentWithCard:(BGRoleCard)aRole
{
    return [[self alloc]initWithRole:aRole];
}

@end
