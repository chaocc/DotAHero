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
@property (nonatomic, readonly) BOOL isCurrPlayer;

@property (nonatomic) NSUInteger positiveDistance;  // +1: 其他玩家计算与自己的距离
@property (nonatomic) NSInteger negativeDistance;   // -1: 自己计算与其他玩家的距离
@property (nonatomic) NSUInteger attackRange;
//@property (nonatomic) BOOL canBeTarget;
//@property (nonatomic) BOOL isDead;

@property (nonatomic, strong, readonly) BGHeroArea *heroArea;
@property (nonatomic, strong, readonly) BGHandArea *handArea;       // Only current player have
@property (nonatomic, strong, readonly) BGEquipmentArea *equipmentArea;
@property (nonatomic, strong, readonly) BGPlayingMenu *playingMenu;

@property (nonatomic, strong, readonly) BGPlayingCard *usedCard;    // Used card of current player
@property (nonatomic, readonly) BOOL canBeDisarmed;
@property (nonatomic, readonly) BOOL canBeGreeded;

@property (nonatomic) NSInteger selectedHeroId;
@property (nonatomic) NSInteger comparedCardId;
@property (nonatomic, strong) NSArray *selectedCardIds;
@property (nonatomic, strong) NSMutableArray *selectedCardIdxes;
@property (nonatomic) NSInteger selectedEquipment;
@property (nonatomic) NSInteger selectedSkillId;
@property (nonatomic) BGCardColor selectedColor;
@property (nonatomic) BGCardSuits selectedSuits;

@property (nonatomic) NSUInteger handCardCount;         // 手牌数
@property (nonatomic) NSUInteger selectableTargetCount; // 可以指定的目标玩家数
@property (nonatomic) NSUInteger selectableCardCount;   // 可以选择/抽取的牌数

@property (nonatomic) BOOL isStrengthened;              // 是否强化使用卡牌
@property (nonatomic) BOOL isOptionalDiscard;           // 是否非强制的弃牌
@property (nonatomic) BOOL isWaitingDispel;             // 是否等待驱散
//@property (nonatomic) BOOL isIgnoreDispel;              // 是否忽略驱散

- (id)initWithUserName:(NSString *)name seatIndex:(NSUInteger)seatIndex;
+ (id)playerWithUserName:(NSString *)name seatIndex:(NSUInteger)seatIndex;

- (void)renderHeroWithHeroId:(NSInteger)heroId;
- (void)updateHeroWithBloodPoint:(NSInteger)bloodPoint angerPoint:(NSInteger)angerPoint;

- (void)addHandAreaWithCardIds:(NSArray *)cardIds;
- (void)updateHandCardWithCardIds:(NSArray *)cardIds;
- (void)drawCardWithCardCount:(NSInteger)count;
- (void)enableHandCardWithCardIds:(NSArray *)cardIds selectableCardCount:(NSUInteger)count;
- (void)enableAllHandCardsWithSelectableCount:(NSUInteger)count;
- (void)updateEquipmentWithCardIds:(NSArray *)cardIds;

- (void)useHandCard;
- (void)useHandCardWithHeroSkill;
- (void)useHandCardWithCardIds:(NSArray *)cardIds isStrengthened:(BOOL)isStrengthened;

- (void)getCardFromDeckWithCardIds:(NSArray *)cardIds;
- (void)drawCardFromTargetPlayerWithCardIds:(NSArray *)cardIds cardCount:(NSUInteger)count;
- (void)giveCardToTargetPlayerWithCardIds:(NSArray *)cardIds cardCount:(NSUInteger)count;
- (void)removeCardToDeckWithCardIds:(NSArray *)cardIds;

- (void)enablePlayerArea;
- (void)disablePlayerAreaWithDarkColor;
- (void)disablePlayerAreaWithNormalColor;

- (void)clearSelectedObjectBuffer;
- (void)resetAndRemoveNodes;

- (void)addPlayingMenu;
- (void)addPlayingMenuOfStrengthen;
- (void)removePlayingMenu;

- (void)addProgressBar;
- (void)removeProgressBar;

- (void)addTextPrompt;
- (void)removeTextPrompt;

@end
