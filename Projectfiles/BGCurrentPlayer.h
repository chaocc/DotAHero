//
//  BGCurrentPlayer.h
//  DotAHero
//
//  Created by Killua Liu on 5/30/13.
//
//

#import "CCNode.h"
#import "BGMenuFactory.h"
#import "BGMoveComponent.h"
#import "BGHeroArea.h"
#import "BGPlayingArea.h"
#import "BGEquipmentArea.h"

@interface BGCurrentPlayer : CCNode <BGMenuFactoryDelegate, BGMoveComponentDelegate>

@property (nonatomic, strong) NSMutableArray *otherPlayers;
@property (nonatomic, strong) NSMutableArray *targetPlayers;

@property (nonatomic, copy, readonly) NSString *playerName;
@property (nonatomic, strong) BGHeroArea *heroArea;
@property (nonatomic, strong) BGPlayingArea *playingArea;
@property (nonatomic, strong) BGEquipmentArea *equipmentArea;

//@property (nonatomic) BOOL isPlaying;
//@property (nonatomic) BOOL isReplied;
@property (nonatomic) NSUInteger attackedTimes;     // 已使用的攻击次数

- (id)initWithName:(NSString *)name andHeroCards:(NSArray *)cards;
+ (id)playerWithName:(NSString *)name andHeroCards:(NSArray *)cards;

@end
