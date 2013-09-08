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

@property (nonatomic) NSUInteger distance;
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

@property (nonatomic) NSUInteger handCardCount;         // 手牌数
@property (nonatomic) NSUInteger canExtractCardCount;   // 可以抽取的牌数

- (id)initWithUserName:(NSString *)name seatIndex:(NSUInteger)seatIndex;
+ (id)playerWithUserName:(NSString *)name seatIndex:(NSUInteger)seatIndex;

- (void)renderHeroWithHeroId:(NSInteger)heroId;
- (void)updateHeroWithBloodPoint:(NSInteger)bloodPoint angerPoint:(NSUInteger)angerPoint;

- (void)addHandAreaWithCardIds:(NSArray *)cardIds;
- (void)updateHandCardWithCardIds:(NSArray *)cardIds;
- (void)enableHandCardWithCardIds:(NSArray *)cardIds selectableCardCount:(NSUInteger)count;

- (void)updateEquipmentWithCardIds:(NSArray *)cardIds;

- (void)clearBuffer;

- (void)addPlayingMenu;
- (void)addPlayingMenuOfStrengthen;

- (void)addProgressBarWithPosition:(CGPoint)position block:(void (^)())block;
- (void)addProgressBar;
- (void)removeProgressBar;

@end
