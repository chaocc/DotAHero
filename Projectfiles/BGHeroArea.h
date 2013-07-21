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

@property (nonatomic) NSUInteger bloodPoint;
@property (nonatomic) NSUInteger angerPoint;
@property (nonatomic) NSUInteger distance;
@property (nonatomic) NSUInteger attackRange;
@property (nonatomic) NSUInteger demange;
@property (nonatomic) NSUInteger gotAnger;
@property (nonatomic) BOOL canBeTarget;
@property (nonatomic) BOOL isDead;
@property (nonatomic) BGHeroSkill usedSkill;

- (id)initWithHeroCardId:(NSInteger)cardId ofPlayer:(BGPlayer *)player;
+ (id)heroAreaWithHeroCardId:(NSInteger)cardId ofPlayer:(BGPlayer *)player;

- (void)updateBloodPointWithCount:(NSInteger)count;
- (void)updateAngerPointWithCount:(NSInteger)count;

@end
