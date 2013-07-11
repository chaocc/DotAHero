//
//  BGHeroArea.h
//  DotAHero
//
//  Created by Killua Liu on 5/30/13.
//
//

#import "CCNode.h"
#import "BGHeroCard.h"
#import "BGMenuFactory.h"

@class BGPlayer;

@interface BGHeroArea : CCNode <BGMenuFactoryDelegate>

@property (nonatomic, strong, readonly) BGHeroCard *heroCard;

@property (nonatomic) NSUInteger healthPoint;
@property (nonatomic) NSUInteger manaPoint;
@property (nonatomic) NSUInteger distance;
@property (nonatomic) NSUInteger attackRange;
@property (nonatomic) NSUInteger demange;
@property (nonatomic) NSUInteger gotMana;
@property (nonatomic) BOOL canBeTarget;
@property (nonatomic) BOOL isDead;
@property (nonatomic) BGHeroSkill usedSkill;


- (id)initWithHeroCardId:(NSUInteger)cardId ofPlayer:(BGPlayer *)player;
+ (id)heroAreaWithHeroCardId:(NSUInteger)cardId ofPlayer:(BGPlayer *)player;

- (void)addBloodPointWithCount:(NSUInteger)count;
- (void)subtractBloodPointWithCount:(NSUInteger)count;
- (void)addAngerPointWithCount:(NSUInteger)count;
- (void)subtractAngerPointWithCount:(NSUInteger)count;

- (void)useSkill;

@end
