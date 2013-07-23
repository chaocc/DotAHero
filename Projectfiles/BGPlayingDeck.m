//
//  BGPlayingDeck.m
//  DotAHero
//
//  Created by Killua Liu on 7/20/13.
//
//

#import "BGPlayingDeck.h"
#import "BGClient.h"
#import "BGGameLayer.h"
#import "BGPlayingCard.h"
#import "BGHandArea.h"
#import "BGDefines.h"
#import "BGFileConstants.h"
#import "BGMoveComponent.h"

@interface BGPlayingDeck ()

@property (nonatomic, weak) BGPlayer *player;
@property (nonatomic, strong) BGMenuFactory *menuFactory;
@property (nonatomic, strong) CCMenu *privateMenu;
@property (nonatomic) CGFloat cardPadding;

@end

@implementation BGPlayingDeck

- (id)initWithPlayer:(BGPlayer *)player
{
    if (self = [super init]) {
        _player = player;
        
        _menuFactory = [BGMenuFactory menuFactory];
        _cardMenu = [CCMenu menuWithItems:nil];
        [self addChild:_cardMenu];
    }
    return self;
}

+ (id)playingDeckWithPlayer:(BGPlayer *)player
{
    return [[self alloc] initWithPlayer:player];
}

/*
 * Show all cutting(切牌) cards on the playing deck
 */
- (void)showAllCuttingCardsWithCardIds:(NSArray *)cardIds
{
    [self showUsedHandCardsWithCardIds:cardIds];
}

/*
 * Show used hand cards on the playing deck. Clean deck after one card effect was resolved(结算)
 */
- (void)showUsedHandCardsWithCardIds:(NSArray *)cardIds
{
    NSArray *cards = [BGHandArea playingCardsWithCardIds:cardIds];
    
    [_menuFactory addMenuItemsWithCards:cards toMenu:_cardMenu];
    [_cardMenu alignItemsHorizontally];
    _cardMenu.position = USED_CARD_POSITION;
    
    [_player.handArea renderFigureAndSuitsOfCards:cards forMenu:_cardMenu];
}

/*
 * Faced down(暗置) all hand cards on the playing deck for being extracted(比如贪婪)
 */
- (void)facedDownAllHandCardsOfPlayer:(BGPlayer *)player
{
    NSUInteger cardCount = player.handCardCount;
    
    CGFloat cardWidth = [[CCSprite spriteWithSpriteFrameName:kImagePlayingCardBack] contentSize].width;    
//  If card count is great than 6, need narrow the padding.
    if (cardCount > 6) {
        _cardPadding = -(cardWidth*(cardCount-6) / (cardCount-1));
    }
    
    NSMutableArray *menuArray = [NSMutableArray array];
    for (NSUInteger i = 0 ; i < cardCount; i++) {
        CCSprite *normalSprite = [CCSprite spriteWithSpriteFrameName:kImagePlayingCardBack];
        CCSprite *selectedSprite = [CCSprite spriteWithSpriteFrameName:kImagePlayingCardBack];
        selectedSprite.color = ccGRAY;
        CCMenuItem *menuItem =
        [CCMenuItemSprite itemWithNormalSprite:normalSprite
                                selectedSprite:selectedSprite
                                         block:^(id sender) {
                                             [self extractCardOfPlayer:player byTouchMenuItem:sender];
                                         }];
        menuItem.tag = i;
        [menuArray addObject:menuItem];
    }
    _privateMenu = [CCMenu menuWithArray:menuArray];
    _privateMenu.position = EXTRACTED_CARD_POSITION;
    [_privateMenu alignItemsHorizontallyWithPadding:_cardPadding];
    [self addChild:_privateMenu];
}

/*
 * Extract(抽取) a hand card of target player by touch card menu item
 * If only have one hand card, end directly after extracted.
 */
- (void)extractCardOfPlayer:(BGPlayer *)targetPlayer byTouchMenuItem:(CCMenuItem *)menuItem
{
    NSUInteger idx = targetPlayer.handCardCount - menuItem.tag - 1;
    [_player.extractedCardIdxes addObject:@(idx)];
    
    BGMoveComponent *moveComp = [BGMoveComponent moveWithTarget:_player.handArea.targetPosition
                                                         ofNode:menuItem];
    [moveComp runActionEaseMoveWithDuration:0.7f
                                      block:^{
                                          [menuItem removeFromParentAndCleanup:YES];
                                          [_privateMenu alignItemsHorizontallyWithPadding:_cardPadding];
                                          [_player.handArea addOneExtractedHandCard];
                                          
                                          // Extracted card count can't great than all hand card count
                                          if ((_player.extractedCardIdxes.count == targetPlayer.handCardCount) ||
                                              (_player.extractedCardIdxes.count == _player.canExtractCardCount)) {
                                              _player.selectedGreedType = kGreedTypeHandCard;
                                              [_privateMenu removeAllChildrenWithCleanup:YES];
                                              
                                              if (!_player.isSelectedStrenthen) {   // 没有强化
                                                  [[BGClient sharedClient] sendExtractCardRequest]; // Send plugin reqeust
                                              }
                                          }
                                      }];
}

/*
 * Add equipment cards of target player on the deck
 */
- (void)addEquipmentCardsOfTargetPlayer
{
    
}

@end
