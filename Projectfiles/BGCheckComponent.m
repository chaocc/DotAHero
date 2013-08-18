//
//  BGCheckComponent.m
//  DotAHero
//
//  Created by Killua Liu on 7/10/13.
//
//

#import "BGCheckComponent.h"
#import "BGPlayingCard.h"
#import "BGGameLayer.h"

@implementation BGCheckComponent

- (id)initWithPlayer:(BGPlayer *)player
{
    if (self = [super init]) {
        _player = player;
    }
    return self;
}

+ (id)checkComponentWithPlayer:(BGPlayer *)player
{
    return [[self alloc] initWithPlayer:player];
}

#pragma mark - Hand cards availability
///*
// * Check selectors for hand cards availability
// */
//- (void)checkAttack:(BGPlayingCard *)card
//{
//    card.canBeUsed = (_player.playerState == kPlayerStatePlaying);
//}
//
//- (void)checkEvasion:(BGPlayingCard *)card
//{
//    card.canBeUsed = (_player.playerState == kPlayerStateIsBeingAttacked);
//}
//
//- (void)checkHealingSalve:(BGPlayingCard *)card
//{    
//    card.canBeUsed = (_player.heroArea.bloodPoint < _player.heroArea.heroCard.bloodPointLimit);
//}
//
//- (void)checkFanaticism:(BGPlayingCard *)card
//{
//    card.canBeUsed = _player.playerState == kPlayerStatePlaying;
//}
//
//- (void)checkMislead:(BGPlayingCard *)card
//{
//    BGPlayer *playerA, *playerB;
//    NSMutableArray *players = [[BGGameLayer sharedGameLayer].allPlayers mutableCopy];
//    
////  Check if some player's anger great than zero
//    for (BGPlayer *player in players) {
//        if (player.heroArea.angerPoint > 0) {
//            playerA = player;
//            break;
//        }
//    }
//    [players removeObject:playerA];
//    
////  Check if some player's anger less than anger point limit
//    for (BGPlayer *player in players) {
//        if (player.heroArea.angerPoint < player.heroArea.heroCard.angerPointLimit) {
//            playerB = player;
//        }
//    }
//    [players removeObject:playerB];
//    
//    card.canBeUsed = (_player.playerState == kPlayerStatePlaying &&
//                      playerA &&
//                      playerB &&
//                      ![playerA isEqual:playerB]);
//}
//
//- (void)checkChakra:(BGPlayingCard *)card
//{
//    card.canBeUsed = (_player.playerState == kPlayerStatePlaying);
//}
//
//- (void)checkDisarm:(BGPlayingCard *)card
//{
//    card.canBeUsed = (_player.playerState == kPlayerStatePlaying);
//}
//
//- (void)checkElunesArrow:(BGPlayingCard *)card
//{
//    card.canBeUsed = (_player.playerState == kPlayerStatePlaying);
//}
//
//- (void)checkEnergyTransport:(BGPlayingCard *)card
//{
//    card.canBeUsed = (_player.playerState == kPlayerStatePlaying);
//}
//
//- (void)checkGreed:(BGPlayingCard *)card
//{
//    card.canBeUsed = (_player.playerState == kPlayerStatePlaying);
//}
//
//- (void)checkDispel:(BGPlayingCard *)card
//{
//    
//}
//
//- (void)checkGodsStrength:(BGPlayingCard *)card
//{
//    card.canBeUsed = (_player.heroArea.angerPoint >= card.requiredAnger);
//}
//
//- (void)checkViperRaid:(BGPlayingCard *)card
//{
//    card.canBeUsed = (_player.heroArea.angerPoint >= card.requiredAnger);
//}
//
//- (void)checkLagunaBlade:(BGPlayingCard *)card
//{
//    card.canBeUsed = (_player.heroArea.angerPoint >= card.requiredAnger);
//}
//
//- (void)checkWeapon:(BGPlayingCard *)card
//{
//    card.canBeUsed = (_player.playerState == kPlayerStatePlaying);
//}
//
//- (void)checkArmor:(BGPlayingCard *)card
//{
//    card.canBeUsed = (_player.playerState == kPlayerStatePlaying);
//}


#pragma mark - Playing menu availbility
///*
// * Check playing menu item availability while selecting playing card
// */
//- (void)checkPlayingMenuAvailabilityWithSelectedCard:(BGPlayingCard *)card
//{
//    CCMenuItem *okayMenu = [_player.playingMenu.menu.children objectAtIndex:kPlayingMenuItemTagOkay];
//    NSAssert(okayMenu, @"okayMenu Nil in %@", NSStringFromSelector(_cmd));
//    
////  No card selected
//    if (!card.isSelected) {
//        okayMenu.isEnabled = NO;
//        if (_player.playingMenu.menuType == kPlayingMenuItemTagStrengthen) {
//            [_player.playingMenu removeFromParentAndCleanup:YES];
//            [_player addPlayingMenuOfCardUsing];
//        }
//        return;
//    }
//    
////  Card is selected
//    if (_player.playerState == kPlayerStateCutting || _player.playerState == kPlayerStateDiscarding) {
//        okayMenu.isEnabled = YES;
//        return;
//    }
//    
//    if (card.canBeStrengthened && _player.heroArea.angerPoint > 0) {
//        [_player.playingMenu removeFromParentAndCleanup:YES];
//        [_player addPlayingMenuOfStrengthen];
//    }
//    
//    if (card.needSpecifyTarget) {
//        okayMenu.isEnabled = ([BGGameLayer sharedGameLayer].targetPlayerNames.count == card.targetCount);
//    } else {
//        okayMenu.isEnabled = YES;
//    }
//}

@end
