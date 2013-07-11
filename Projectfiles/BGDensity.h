//
//  BGDensity.h
//  DotAHero
//
//  Created by Killua Liu on 6/11/13.
//
//

#import "CCNode.h"

#import "BGDensityCard.h"

@interface BGDensity : CCNode

@property(nonatomic, readonly) BGDensityCard *densityCard;

- (id)initWithDensityCardId:(NSInteger)cardId;
+ (id)densityWithDensityCardId:(NSInteger)cardId;

@end
