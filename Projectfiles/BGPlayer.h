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
#import "BGHandArea.h"
#import "BGEquipmentArea.h"
#import "BGPlayingMenu.h"
#import "BGPluginConstants.h"

@interface BGPlayer : CCNode <BGMenuFactoryDelegate>

@property (nonatomic, copy, readonly) NSString *playerName;
@property (nonatomic, readonly) BOOL isCurrentPlayer;
@property (nonatomic, readonly) CGPoint playerAreaPosition;
@property (nonatomic, readonly) CGSize playerAreaSize;
@property (nonatomic) BGAction action;

@property (nonatomic, strong, readonly) BGHeroArea *heroArea;
@property (nonatomic, strong, readonly) BGHandArea *handArea;   // Only current player have
@property (nonatomic, strong, readonly) BGEquipmentArea *equipmentArea;
@property (nonatomic, strong, readonly) BGPlayingMenu *playingMenu;

@property (nonatomic) NSInteger selectedHeroId;
@property (nonatomic, readonly) NSUInteger handSizeLimit;

@property (nonatomic, strong) NSArray *selectedCardIds;
@property (nonatomic, strong) NSMutableArray *selectedCardIdxes;
@property (nonatomic) NSInteger selectedSkillId;
@property (nonatomic) BGCardColor selectedColor;
@property (nonatomic) BGCardSuits selectedSuits;

@property (nonatomic) NSUInteger handCardCount;         // 手牌数
@property (nonatomic) NSUInteger canDrawCardCount;      // 可以摸的牌数
@property (nonatomic) NSUInteger canExtractCardCount;   // 可以抽取的牌数

- (id)initWithUserName:(NSString *)name isCurrentPlayer:(BOOL)flag;
+ (id)playerWithUserName:(NSString *)name isCurrentPlayer:(BOOL)flag;

- (void)initHeroWithHeroId:(NSInteger)heroId;
- (void)updateHeroWithBloodPoint:(NSInteger)bloodPoint angerPoint:(NSUInteger)angerPoint;

- (void)initHandCardWithCardIds:(NSArray *)cardIds;
- (void)updateHandCardWithCardIds:(NSArray *)cardIds selectableCardCount:(NSUInteger)count;

- (void)clearBuffer;

- (void)addPlayingMenu;

@end
