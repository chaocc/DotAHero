//
//  BGPlayer.h
//  DotAHero
//
//  Created by Killua Liu on 7/2/13.
//
//

#import "CCNode.h"
#import "BGHeroArea.h"
#import "BGHandArea.h"
#import "BGEquipmentArea.h"
#import "BGPlayingMenu.h"
#import "BGPluginConstants.h"

@interface BGPlayer : CCNode

@property (nonatomic, copy, readonly) NSString *playerName;
@property (nonatomic, readonly) BOOL isSelfPlayer;
//@property (nonatomic, readonly) NSUInteger handSizeLimit;

@property (nonatomic) NSUInteger positiveDistance;  // +1: 其他玩家计算与自己的距离
@property (nonatomic) NSInteger negativeDistance;   // -1: 自己计算与其他玩家的距离
@property (nonatomic) NSUInteger attackRange;
//@property (nonatomic) BOOL canBeTarget;
//@property (nonatomic) BOOL isDead;

@property (nonatomic, strong, readonly) BGHeroArea *heroArea;
@property (nonatomic, strong, readonly) BGHandArea *handArea;   // Only current player have
@property (nonatomic, strong, readonly) BGEquipmentArea *equipmentArea;
@property (nonatomic, strong, readonly) BGPlayingMenu *playingMenu;

@property (nonatomic) NSInteger selectedHeroId;
@property (nonatomic) NSInteger comparedCardId;
@property (nonatomic, strong) NSArray *selectedCardIds;
@property (nonatomic, strong) NSMutableArray *selectedCardIdxes;
@property (nonatomic) NSInteger selectedSkillId;
@property (nonatomic) BGCardColor selectedColor;
@property (nonatomic) BGCardSuits selectedSuits;
@property (nonatomic) BOOL selectedCardIsFacedUp;       // 选中给其他玩家的卡牌是否是明置的

@property (nonatomic) NSUInteger handCardCount;         // 手牌数
@property (nonatomic) NSUInteger selectableTargetCount; // 可以指定的目标玩家数
@property (nonatomic) NSUInteger drawableCardCount;     // 可以抽取的牌数

- (id)initWithUserName:(NSString *)name seatIndex:(NSUInteger)seatIndex;
+ (id)playerWithUserName:(NSString *)name seatIndex:(NSUInteger)seatIndex;

- (void)renderHeroWithHeroId:(NSInteger)heroId;
- (void)updateHeroWithBloodPoint:(NSInteger)bloodPoint angerPoint:(NSInteger)angerPoint;

- (void)addHandAreaWithCardIds:(NSArray *)cardIds;
- (void)updateHandCardWithCardIds:(NSArray *)cardIds;
- (void)updateHandCardWithCardCount:(NSInteger)count;
- (void)updateHandCardWithCardIds:(NSArray *)cardIds cardCount:(NSUInteger)count;
- (void)updateHandCardWithEquipments:(NSArray *)cardIds cardIdxes:(NSArray *)cardIdxes;
- (void)enableHandCardWithCardIds:(NSArray *)cardIds selectableCardCount:(NSUInteger)count;
- (void)updateEquipmentWithCardIds:(NSArray *)cardIds;

- (void)enablePlayerArea;
- (void)disablePlayerArea;
- (void)setDisabledColor;
- (void)restoreColor;
- (void)clearBuffer;

- (void)addPlayingMenu;
- (void)addPlayingMenuOfStrengthen;
- (void)removePlayingMenu;

//- (void)addProgressBarWithPosition:(CGPoint)position;
- (void)addProgressBar;
- (void)removeProgressBar;

@end
