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
@property (nonatomic, strong) CCMenu *menu;
@property (nonatomic) CGFloat cardPadding;

@end

@implementation BGPlayingDeck

- (id)initWithPlayer:(BGPlayer *)player
{
    if (self = [super init]) {
        _player = player;
    }
    return self;
}

+ (id)playingDeckWithPlayer:(BGPlayer *)player
{
    return [[self alloc] initWithPlayer:player];
}

/*
 * Add all cutting(切牌) cards on the playing deck
 */
- (void)addAllCuttingCardsWithCardIds:(NSArray *)cardIds
{
    NSArray *cards = [BGHandArea playingCardsWithCardIds:cardIds];

    BGMenuFactory *menuFactory = [BGMenuFactory menuFactory];
    CCMenu *menu = [menuFactory createMenuWithCards:cards];
    [menu alignItemsHorizontally];
    menu.position = ccp(SCREEN_WIDTH/2, SCREEN_HEIGHT*0.55);
    [self addChild:menu];
    [_player.handArea renderFigureAndSuitsOfCards:cards forMenu:menu];
    
    CCDelayTime *delay = [CCDelayTime actionWithDuration:2.0f];
    CCCallBlock *block = [CCCallBlock actionWithBlock:^{
//        [self removeFromParentAndCleanup:YES];
        [self removeAllChildrenWithCleanup:YES];
    }];
    [self runAction: [CCSequence actions:delay, block, nil]];
}

/*
 * Add all faced down(暗置) playing cards on the playing deck for being extracted
 */
- (void)addAllFacedDownPlayingCardsOfTargetPlayer
{
    BGGameLayer *gamePlayer = [BGGameLayer sharedGameLayer];
    BGPlayer *targetPlayer = [gamePlayer playerWithName:gamePlayer.targetPlayerNames.lastObject];
    NSUInteger cardCount = targetPlayer.playingCardCount;
    
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
                                             [self extractCardOfPlayer:targetPlayer byTouchMenuItem:sender];
                                         }];
        menuItem.tag = i;
        [menuArray addObject:menuItem];
    }
    _menu = [CCMenu menuWithArray:menuArray];
    _menu.position = ccp(SCREEN_WIDTH/2, SCREEN_HEIGHT*0.65);
    [_menu alignItemsHorizontallyWithPadding:_cardPadding];
    [self addChild:_menu];
}

/*
 * Extract(抽取) a playing card of target player by touch card menu item
 * If only have one playing card, end directly after extracted.
 */
- (void)extractCardOfPlayer:(BGPlayer *)targetPlayer byTouchMenuItem:(CCMenuItem *)menuItem
{
    NSUInteger idx = targetPlayer.playingCardCount - menuItem.tag + 1;
    [_player.extractedCardIdxes addObject:@(idx)];
    
    BGMoveComponent *moveComp = [BGMoveComponent moveWithTarget:_player.handArea.targetPosition
                                                         ofNode:menuItem];
    [moveComp runActionEaseMoveScaleWithDuration:0.7f
                                           scale:1.0f
                                           block:^{
                                               [menuItem removeFromParentAndCleanup:YES];
                                               [_menu alignItemsHorizontallyWithPadding:_cardPadding];
                                               [_player.handArea addAFacedDownPlayingCard];
                                               
                                               // Extracted card count can't great than all playing card count
                                               if ((_player.extractedCardIdxes.count == targetPlayer.playingCardCount) ||
                                                   (_player.extractedCardIdxes.count == _player.canExtractCardCount)) {
                                                   _player.selectedGreedType = kGreedTypeHandCard;
                                                   [[BGClient sharedClient] sendExtractCardRequest];
                                                   [self removeAllChildrenWithCleanup:YES];
                                                   [_player clearSelectedObjectsBuffer];
                                               }
                                           }];
}

@end
