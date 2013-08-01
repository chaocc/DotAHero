//
//  BGCheckComponent.h
//  DotAHero
//
//  Created by Killua Liu on 7/10/13.
//
//

#import <Foundation/Foundation.h>
#import "BGPlayer.h"

@interface BGCheckComponent : NSObject

@property (nonatomic, strong, readonly) BGPlayer *player;

- (id)initWithPlayer:(BGPlayer *)player;
+ (id)checkComponentWithPlayer:(BGPlayer *)player;

- (void)checkAttack:(BGPlayingCard *)card;
- (void)checkEvasion:(BGPlayingCard *)card;
- (void)checkHealingSalve:(BGPlayingCard *)card;
- (void)checkFanaticism:(BGPlayingCard *)card;
- (void)checkMislead:(BGPlayingCard *)card;
- (void)checkChakra:(BGPlayingCard *)card;
- (void)checkDisarm:(BGPlayingCard *)card;
- (void)checkElunesArrow:(BGPlayingCard *)card;
- (void)checkEnergyTransport:(BGPlayingCard *)card;
- (void)checkGreed:(BGPlayingCard *)card;
- (void)checkDispel:(BGPlayingCard *)card;
- (void)checkGodsStrength:(BGPlayingCard *)card;
- (void)checkViperRaid:(BGPlayingCard *)card;
- (void)checkLagunaBlade:(BGPlayingCard *)card;
- (void)checkWeapon:(BGPlayingCard *)card;
- (void)checkArmor:(BGPlayingCard *)card;

- (void)checkPlayingMenuAvailabilityWithSelectedCard:(BGPlayingCard *)card;

@end
