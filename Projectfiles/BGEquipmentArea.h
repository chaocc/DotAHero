//
//  BGEquipmentArea.h
//  DotAHero
//
//  Created by Killua Liu on 5/30/13.
//
//

#import "CCNode.h"
#import "BGMenuFactory.h"
#import "BGPlayingCard.h"

@class BGPlayer;

@interface BGEquipmentArea : CCNode <BGMenuFactoryDelegate>

@property (nonatomic, strong) NSMutableArray *equipmentCards;    // [0] is Weapon, [1] is Armor

- (id)initWithPlayer:(BGPlayer *)player;
+ (id)equipmentAreaWithPlayer:(BGPlayer *)player;

- (void)updateEquipmentWithCard:(BGPlayingCard *)card;
- (void)updateEquipmentWithCardId:(NSInteger)cardId;

- (void)setDisabledColor;
- (void)restoreColor;

@end
