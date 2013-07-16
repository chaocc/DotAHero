//
//  BGEffectComponent.h
//  DotAHero
//
//  Created by Killua Liu on 7/10/13.
//
//

#import "CCNode.h"
#import "BGPlayingCard.h"

@interface BGEffectComponent : CCNode

@property (nonatomic, readonly) BGPlayingCardEnum playingCardEnum;

- (id)initWithPlayingCardEnum:(BGPlayingCardEnum)cardEnum;
+ (id)effectCompWithPlayingCardEnum:(BGPlayingCardEnum)cardEnum;

@end
