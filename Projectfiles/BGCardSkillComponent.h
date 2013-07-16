//
//  BGCardSkillComponent.h
//  DotAHero
//
//  Created by Killua Liu on 7/10/13.
//
//

#import <Foundation/Foundation.h>
#import "BGPlayingCard.h"

@interface BGCardSkillComponent : NSObject

@property (nonatomic, strong, readonly) BGPlayingCard *playingCard;

- (id)initWithPlayingCard:(BGPlayingCard *)playingCard;
+ (id)cardSkillCompWithPlayingCard:(BGPlayingCard *)playingCard;

@end
