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

@property (nonatomic) NSInteger bloodPoint;
@property (nonatomic) NSUInteger angerPoint;

- (id)initWithPlayer:(BGPlayer *)player;
+ (id)heroAreaWithPlayer:(BGPlayer *)player;

- (void)renderHeroWithHeroId:(NSInteger)heroId;
- (void)updateBloodPointWithCount:(NSInteger)count;
- (void)updateAngerPointWithCount:(NSInteger)count;

@end
