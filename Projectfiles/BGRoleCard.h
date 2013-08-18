//
//  BGRoleCard.h
//  DotAHero
//
//  Created by Killua Liu on 5/30/13.
//
//

#import "BGCard.h"

typedef NS_ENUM(NSInteger, BGRoleCardEnum) {
    kRoleCardInvalid = -1,
    kRoleCardSentinel,      // 近卫
    kRoleCardScourge,       // 天灾
    kRoleCardNeutral,       // 中立
};


@interface BGRoleCard : BGCard

@end
