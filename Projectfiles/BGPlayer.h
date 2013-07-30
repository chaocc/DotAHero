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
#import "BGPlayingDeck.h"
#import "BGPluginConstants.h"

@interface BGPlayer : CCNode <BGMenuFactoryDelegate>

@property (nonatomic, copy, readonly) NSString *playerName;
@property (nonatomic, readonly) BOOL isCurrentPlayer;
@property (nonatomic, readonly) CGPoint playerAreaPosition;
@property (nonatomic, readonly) CGSize playerAreaSize;
@property (nonatomic) BGPlayerState playerState;

@property (nonatomic, strong, readonly) BGHeroArea *heroArea;
@property (nonatomic, strong, readonly) BGHandArea *handArea;   // Only current player have
@property (nonatomic, strong, readonly) BGEquipmentArea *equipmentArea;
@property (nonatomic, strong, readonly) BGPlayingMenu *playingMenu;
@property (nonatomic, strong, readonly) BGPlayingDeck *playingDeck;

@property (nonatomic, strong) NSArray *toBeSelectedHeroIds;
@property (nonatomic, readonly) NSInteger selectedHeroId;
@property (nonatomic, strong) NSArray *selectedCardIds;
@property (nonatomic, strong) NSArray *misGuessedCardIds;
@property (nonatomic, strong) NSMutableArray *extractedCardIdxes;
@property (nonatomic, strong) NSMutableArray *extractedCardIds;
@property (nonatomic, strong) NSArray *transferedCardIds;
@property (nonatomic) BOOL isSelectedStrenthen;
@property (nonatomic) BGCardColor selectedColor;
@property (nonatomic) BGCardSuits selectedSuits;
@property (nonatomic) BGGreedType selectedGreedType;

@property (nonatomic) NSUInteger handCardCount;      // 手牌数
@property (nonatomic) NSUInteger canDrawCardCount;      // 可以摸的牌数
@property (nonatomic) NSUInteger canExtractCardCount;   // 可以抽取的牌数
@property (nonatomic) BOOL canUseAttack;    // 是否可以使用"攻击"

- (id)initWithUserName:(NSString *)name isCurrentPlayer:(BOOL)flag;
+ (id)playerWithUserName:(NSString *)name isCurrentPlayer:(BOOL)flag;

- (void)addHeroAreaWithHeroId:(NSInteger)heroId;
- (void)addHandAreaWithCardIds:(NSArray *)cardIds;
- (void)drawPlayingCardIds:(NSArray *)cardIds;
- (void)updateBloodAndAngerWithBloodPoint:(NSInteger)bloodPoint andAngerPoint:(NSInteger)angerPoint;

- (void)clearBuffer;

- (void)addPlayingMenuOfCardOkay;
- (void)addPlayingMenuOfCardUsing;
- (void)addPlayingMenuOfCardPlaying;
- (void)addPlayingMenuOfStrengthen;
- (void)addPlayingMenuOfCardColor;

- (void)showAllCuttingCardsWithCardIds:(NSArray *)cardIds;
- (void)faceDownAllHandCardsOnDeck;
- (void)gotExtractedCardsWithCardIds:(NSArray *)cardIds;
- (void)lostCardsWithCardIds:(NSArray *)cardIds;

@end
