//
//  BGOtherPlayer.h
//  DotAHero
//
//  Created by Killua Liu on 6/27/13.
//
//

#import "CCNode.h"
#import "BGHeroCardComponent.h"

@interface BGOtherPlayer : CCNode

@property (nonatomic, copy, readonly) NSString *playerName;
@property (nonatomic, strong, readonly) BGHeroCardComponent *heroCard;

- (id)initWithName:(NSString *)name andHeroCard:(BGHeroCard)card;
+ (id)otherPlayerWithName:(NSString *)name andHeroCard:(BGHeroCard)card;

@end
