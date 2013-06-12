//
//  BGRoleCardComponent.h
//  DotAHero
//
//  Created by Killua Liu on 5/30/13.
//
//

#import "BGComponent.h"

typedef NS_ENUM(NSInteger, BGRoleCard) {
    kSentinel,      // 近卫
    kScourge,       // 天灾
    kNeutral,       // 中立
};


@interface BGRoleCardComponent : BGComponent

@property (nonatomic, strong) NSArray *roleArray;

@property (nonatomic, readonly) BGRoleCard roleId;

@property (nonatomic, copy, readonly) NSString *faction;

- (id)initWithRoleId:(BGRoleCard)aRoleId;
+ (id)roleCardComponentWithId:(BGRoleCard)aRoleId;

@end
