//
//  BGCharacterComponent.h
//  DotAHero
//
//  Created by Killua Liu on 5/30/13.
//
//

#import "BGComponent.h"
#import "BGHeroCardComponent.h"
#import "BGMenuLayer.h"

@interface BGHero : BGComponent <BGMenuLayerDelegate>

@property (nonatomic, strong) BGHeroCardComponent *heroCard;
@property (nonatomic) NSUInteger distance;
@property (nonatomic) NSUInteger attackRange;
@property (nonatomic) NSUInteger demange;
@property (nonatomic) NSUInteger gotMana;
@property (nonatomic) BOOL canBeTarget;
@property (nonatomic) BOOL isDead;
@property (nonatomic) BGHeroSkill usedSkill;


- (id)initWithHeroCards:(NSArray *)heroCards;
+ (id)heroWithHeroCards:(NSArray *)heroCards;

- (void)useSkill;

@end
