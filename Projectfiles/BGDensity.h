//
//  BGDensity.h
//  DotAHero
//
//  Created by Killua Liu on 6/11/13.
//
//

#import "CCNode.h"

#import "BGDensityCardComponent.h"

@interface BGDensity : CCNode

@property(nonatomic, readonly) BGDensityCardComponent *densityCard;

- (id)initWithDensityCard:(BGDensityCard)card;
+ (id)densityWithDensityCard:(BGDensityCard)card;

@end
