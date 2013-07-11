//
//  BGPlayer.h
//  DotAHero
//
//  Created by Killua Liu on 7/2/13.
//
//

#import "CCNode.h"
#import "BGMenuFactory.h"
#import "BGHeroArea.h"
#import "BGPlayingArea.h"
#import "BGEquipmentArea.h"
#import "BGPlayingMenu.h"

@interface BGPlayer : CCNode <BGMenuFactoryDelegate>

@property (nonatomic, readonly) BOOL isCurrentPlayer;
@property (nonatomic, readonly) CGSize playerAreaSize;

@property (nonatomic, copy, readonly) NSString *playerName;
//@property (nonatomic, strong) NSArray *drawingCardIds;          // 摸到的牌

@property (nonatomic, strong) NSArray *toBeSelectedHeroIds;
@property (nonatomic, readonly) NSUInteger selectedHeroId;
@property (nonatomic, strong, readonly) BGHeroArea *heroArea;
@property (nonatomic, strong, readonly) BGPlayingArea *playingArea;
@property (nonatomic, strong, readonly) BGEquipmentArea *equipmentArea;
@property (nonatomic, strong, readonly) BGPlayingMenu *playingMenu;

//@property (nonatomic, strong) NSMutableArray *otherPlayers;
//@property (nonatomic, strong) NSMutableArray *targetPlayers;
//@property (nonatomic) BOOL isPlaying;
//@property (nonatomic) BOOL isReplied;
@property (nonatomic) BOOL canUseAttack;    // 是否可以使用"攻击"

- (id)initWithUserName:(NSString *)name isCurrentPlayer:(BOOL)flag;
//- (id)initWithName:(NSString *)name andHeroIds:(NSArray *)heroIds;

+ (id)playerWithUserName:(NSString *)name isCurrentPlayer:(BOOL)flag;
//+ (id)playerWithName:(NSString *)name andHeroIds:(NSArray *)heroIds;

- (void)addHeroAreaWithHeroId:(NSUInteger)heroId;
- (void)addPlayingAreaWithPlayingCardIds:(NSArray *)cardIds;
- (void)drawPlayingCardIds:(NSArray *)cardIds;
- (void)updatePlayingCardCountBy:(NSUInteger)count;

@end
