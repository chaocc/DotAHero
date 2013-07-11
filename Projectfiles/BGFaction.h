//
//  BGFaction.h
//  DotAHero
//
//  Created by Killua Liu on 6/14/13.
//
//

#import "CCNode.h"

@interface BGFaction : CCNode

@property (nonatomic, readonly) NSUInteger totalSentinelCount;
@property (nonatomic, readonly) NSUInteger totalScourgeCount;
@property (nonatomic, readonly) NSUInteger totalNeutralCount;

@property (nonatomic) NSUInteger aliveSentinelCount;
@property (nonatomic) NSUInteger aliveScourgeCount;
@property (nonatomic) NSUInteger aliveNeutralCount;

- (id)initWithRoleIds:(NSArray *)roleIds;
+ (id)factionWithRoleIds:(NSArray *)roleIds;

@end
