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
#import "BGPluginConstants.h"

@interface BGPlayer : CCNode <BGMenuFactoryDelegate>

@property (nonatomic, copy, readonly) NSString *playerName;
@property (nonatomic, readonly) BOOL isCurrentPlayer;
@property (nonatomic, readonly) CGSize playerAreaSize;
@property (nonatomic) BGPlayerState playerState;

@property (nonatomic, strong) NSArray *toBeSelectedHeroIds;
@property (nonatomic, readonly) NSInteger selectedHeroId;
//@property (nonatomic, strong) NSArray *playingCardIds;  // 起始手牌

@property (nonatomic, strong, readonly) BGHeroArea *heroArea;
@property (nonatomic, strong, readonly) BGPlayingArea *playingArea;
@property (nonatomic, strong, readonly) BGEquipmentArea *equipmentArea;
@property (nonatomic, strong, readonly) BGPlayingMenu *playingMenu;

//@property (nonatomic) BOOL isPlaying;
//@property (nonatomic) BOOL isReplied;
@property (nonatomic) BOOL canUseAttack;    // 是否可以使用"攻击"

- (id)initWithUserName:(NSString *)name isCurrentPlayer:(BOOL)flag;

+ (id)playerWithUserName:(NSString *)name isCurrentPlayer:(BOOL)flag;

- (void)addHeroAreaWithHeroId:(NSInteger)heroId;
- (void)addPlayingAreaWithPlayingCardIds:(NSArray *)cardIds;
- (void)addPlayingMenuOfCardUsing;
- (void)addPlayingMenuOfCardPlaying;
- (void)showAllCuttingCardsWithCardIds:(NSArray *)cardIds;

- (void)drawPlayingCardIds:(NSArray *)cardIds;
- (void)updatePlayingCardCountBy:(NSInteger)count;

@end
