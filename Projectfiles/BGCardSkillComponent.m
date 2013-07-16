//
//  BGCardSkillComponent.m
//  DotAHero
//
//  Created by Killua Liu on 7/10/13.
//
//

#import "BGCardSkillComponent.h"
#import "BGClient.h"

@implementation BGCardSkillComponent

- (id)initWithPlayingCard:(BGPlayingCard *)playingCard
{
    if (self = [super init]) {
        _playingCard = playingCard;
        
        [self sendGamePluginRequest];
    }
    return self;
}

+ (id)cardSkillCompWithPlayingCard:(BGPlayingCard *)playingCard
{
    return [[self alloc] initWithPlayingCard:playingCard];
}

- (void)sendGamePluginRequest
{
    switch (_playingCard.cardEnum) {
        case kPlayingCardNormalAttack:
            
            break;
            
        default:
            break;
    }
}

@end
