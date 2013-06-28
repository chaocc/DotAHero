//
//  BGHeroArea.h
//  DotAHero
//
//  Created by Killua Liu on 5/30/13.
//
//

#import "CCNode.h"
#import "BGHeroCardComponent.h"

@interface BGHeroArea : CCNode

@property (nonatomic, strong, readonly) BGHeroCardComponent *heroCard;

@property (nonatomic) NSUInteger healthPoint;
@property (nonatomic) NSUInteger manaPoint;
@property (nonatomic) NSUInteger distance;
@property (nonatomic) NSUInteger attackRange;
@property (nonatomic) NSUInteger demange;
@property (nonatomic) NSUInteger gotMana;
@property (nonatomic) BOOL canBeTarget;
@property (nonatomic) BOOL isDead;
@property (nonatomic) BGHeroSkill usedSkill;


- (id)initWithHeroCard:(BGHeroCard)card inPlayerAreaBox:(CGRect)playerAreaBox;
+ (id)heroAreaWithHeroCard:(BGHeroCard)card inPlayerAreaBox:(CGRect)playerAreaBox;

- (void)useSkill;

@end
