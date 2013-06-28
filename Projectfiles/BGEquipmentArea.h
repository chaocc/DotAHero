//
//  BGEquipmentArea.h
//  DotAHero
//
//  Created by Killua Liu on 5/30/13.
//
//

#import "CCNode.h"
#import "BGPlayingCardComponent.h"

@interface BGEquipmentArea : CCNode

@property(nonatomic, strong) BGPlayingCardComponent *equipmentCard;

- (id)initWithEquipmentCard:(BGPlayingCard)card;
+ (id)equipmentWithEquipmentCard:(BGPlayingCard)card;

@end
