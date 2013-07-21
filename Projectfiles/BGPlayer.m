//
//  BGPlayer.m
//  DotAHero
//
//  Created by Killua Liu on 7/2/13.
//
//

#import "BGPlayer.h"
#import "BGClient.h"
#import "BGGameLayer.h"
#import "BGFileConstants.h"
#import "BGDefines.h"
#import "BGMoveComponent.h"

typedef NS_ENUM(NSInteger, BGPlayerTag) {
    kPlayerTagPlayingCardCount
};


@interface BGPlayer ()


@end

@implementation BGPlayer

@synthesize playingCardCount = _playingCardCount;

- (id)initWithUserName:(NSString *)name isCurrentPlayer:(BOOL)isCurrentPlayer
{
    if (self = [super init]) {
        _playerName = name;
        _isCurrentPlayer = isCurrentPlayer;
        _selectedHeroId = kHeroCardDefault;
        _selectedCardIds = [NSMutableArray array];
        _extractedCardIdxes = [NSMutableArray array];
        _canDrawCardCount = 2;
        _canUseAttack = YES;
        
        [self renderPlayerArea];
    }
    return self;
}

+ (id)playerWithUserName:(NSString *)name isCurrentPlayer:(BOOL)isCurrentPlayer
{
    return [[self alloc] initWithUserName:name isCurrentPlayer:isCurrentPlayer];
}

+ (NSArray *)heroCardsWithHeroIds:(NSArray *)heroIds
{
    NSMutableArray *heroCards = [NSMutableArray array];
    [heroIds enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        BGCard *heroCard = [BGHeroCard cardWithCardId:[obj integerValue]];
        [heroCards addObject:heroCard];
    }];
    
    return heroCards;
}

#pragma mark - Player area
/*
 * 1. Current player's position is (0,0) and its sprite positon is the "Center" of the player area
 * 2. Other player's position is setted in class BGGameLayer and its sprite position is (0,0)
 */
- (void)renderPlayerArea
{
    NSString *spriteFrameName = (_isCurrentPlayer) ? kImageCurrentPlayerArea : kImageOtherPlayerArea;
    CCSprite *sprite = [CCSprite spriteWithSpriteFrameName:spriteFrameName];
    _playerAreaSize = sprite.contentSize;
    
    if (_isCurrentPlayer) {
        sprite.position = ccp(_playerAreaSize.width/2, _playerAreaSize.height/2);
    }
    
    [self addChild:sprite];
}

#pragma mark - To be selected heros
/*
 * Render the to be selected heros that are selected by current player
 */
- (void)renderToBeSelectedHeros:(NSArray *)heroIds
{
    CCDelayTime *delay = [CCDelayTime actionWithDuration:0.21f];
    CCCallBlock *block = [CCCallBlock actionWithBlock:^{
        NSArray *heroCards = [self.class heroCardsWithHeroIds:heroIds];
        
        BGMenuFactory *menuFactory = [BGMenuFactory menuFactory];
        CCMenu *heroMenu = [menuFactory createMenuWithCards:heroCards];
        heroMenu.position = ccp(SCREEN_WIDTH/2, SCREEN_HEIGHT*0.6);
        [heroMenu alignItemsHorizontally];
        [self addChild:heroMenu];
        
        menuFactory.delegate = self;
    }];
    
    [self runAction:[CCSequence actions:delay, block, nil]];
}

/*
 * toBeSelectedHeroIDs setter method and call render method
 */
- (void)setToBeSelectedHeroIds:(NSArray *)heroIds
{
    _toBeSelectedHeroIds = heroIds;
    [self renderToBeSelectedHeros:heroIds];
    _toBeSelectedHeroIds = nil; // Free memory
}

/*
 * Add hero(avatar) area node
 */
- (void)addHeroAreaWithHeroId:(NSInteger)heroId
{
    _heroArea = [BGHeroArea heroAreaWithHeroCardId:heroId ofPlayer:self];
    [self addChild: _heroArea];
    
//  5 playing cards for each player at the beginning, use 1 card for cutting.
    self.playingCardCount = INITIAL_PLAYING_CARD_COUND;
}

#pragma mark - Hero card selection
/*
 * Menu delegate method is called while selecting a hero card
 */
- (void)menuItemTouched:(CCMenuItem *)menuItem
{
    _selectedHeroId = menuItem.tag;
    [self runActionWithSelectedHeroMenu:menuItem];
    
    [[BGClient sharedClient] sendSelectHeroCardRequest];
    
//  [(BGGameLayer *)self.parent transferRoleCardToNextPlayer];
}

/*
 * Run animation while selecting a hero card
 */
- (void)runActionWithSelectedHeroMenu:(CCMenuItem *)menuItem
{
    for (CCMenuItem *item in menuItem.parent.children) {
        if (![item isEqual:menuItem]) {
            item.visible = NO;
        }
    }
    
    BGMoveComponent *moveComp = [BGMoveComponent moveWithTarget:ccp(-SCREEN_WIDTH*0.4, -SCREEN_HEIGHT*0.4)
                                                         ofNode:menuItem];
    [moveComp runActionEaseMoveScaleWithDuration:0.5f
                                           scale:0.5f
                                           block:^{
                                               [self addHeroAreaWithHeroId:menuItem.tag];
                                               [menuItem.parent removeFromParentAndCleanup:YES];
                                           }];
}

#pragma mark - Playing cards
/*
 * Draw playing cards after player confirm drawing
 */
- (void)drawPlayingCardIds:(NSArray *)cardIds
{
    [_handArea addPlayingCardsWithCardIds:cardIds];
}

/*
 * Display playing card count at right corner of hero avatar(Only for other player)
 */
- (void)renderPlayingCardCount
{
    [[self getChildByTag:kPlayerTagPlayingCardCount] removeFromParentAndCleanup:YES];
    
    CCLabelTTF *countLabel = [CCLabelTTF labelWithString:@(_playingCardCount).stringValue
                                                fontName:@"Arial"
                                                fontSize:22.0f];
    countLabel.position = ccp(-_playerAreaSize.width*0.07, -_playerAreaSize.height*0.23);
    [self addChild:countLabel z:1 tag:kPlayerTagPlayingCardCount];
}

- (void)setPlayingCardCount:(NSUInteger)playingCardCount
{
    _playingCardCount = playingCardCount;
    if (!_isCurrentPlayer) {
        [self renderPlayingCardCount];
    }
}

- (NSUInteger)playingCardCount
{
    return (_isCurrentPlayer) ? _handArea.playingCards.count : _playingCardCount;
}

- (void)updateBloodAndAngerWithBloodPoint:(NSInteger)bloodPoint
                            andAngerPoint:(NSInteger)angerPoint
{
    [_heroArea updateBloodPointWithCount:bloodPoint];
    [_heroArea updateAngerPointWithCount:angerPoint];
}

- (void)clearSelectedObjectsBuffer
{
    _selectedCardIds = nil;
    [_extractedCardIdxes removeAllObjects];
    _isSelectedStrenthen = NO;
    _selectedColor = kCardColorInvalid;
    _selectedSuits = kCardSuitsInvalid;
}

#pragma mark - Playing menu
/*
 * Determine the initial player by cutting card
 */
- (void)showAllCuttingCardsWithCardIds:(NSArray *)cardIds
{
    _playingDeck = [BGPlayingDeck playingDeckWithPlayer:self];
    [_playingDeck addAllCuttingCardsWithCardIds:cardIds];
    [self addChild:_playingDeck];
}

/*
 * Add hand area node(Delay 0.5 second for performance)
 */
- (void)addHandAreaWithPlayingCardIds:(NSArray *)cardIds
{
    CCDelayTime *delay = [CCDelayTime actionWithDuration:0.5f];
    CCCallBlock *block = [CCCallBlock actionWithBlock:^{
        _handArea = [BGHandArea handAreaWithPlayingCardIds:cardIds ofPlayer:self];
        [self addChild:_handArea z:2];
        
        [self addPlayingMenuOfCardCutting];
    }];
    
    [self runAction:[CCSequence actions:delay, block, nil]];
}

/*
 * Add playing menu items for card cutting(通过拼点切牌)
 */
- (void)addPlayingMenuOfCardCutting
{
    _playingMenu = [BGPlayingMenu playingMenuWithMenuType:kPlayingMenuTypeCardCutting ofPlayer:self];
    [self addChild:_playingMenu];
}

/*
 * Add playing menu items for card using(使用)
 */
- (void)addPlayingMenuOfCardUsing
{
    _playingMenu = [BGPlayingMenu playingMenuWithMenuType:kPlayingMenuTypeCardUsing ofPlayer:self];
    [self addChild:_playingMenu];
}

/*
 * Add playing menu items for card playing(打出)
 */
- (void)addPlayingMenuOfCardPlaying
{
    _playingMenu = [BGPlayingMenu playingMenuWithMenuType:kPlayingMenuTypeCardPlaying ofPlayer:self];
    [self addChild:_playingMenu];
}

/*
 * Add playing menu items for strengthen(魔法牌强化按钮)
 */
- (void)addPlayingMenuOfStrengthen
{
    _playingMenu = [BGPlayingMenu playingMenuWithMenuType:kPlayingMenuTypeStrengthen ofPlayer:self];
    [self addChild:_playingMenu];
}

/*
 * Add playing menu items for card color(选择卡牌颜色)
 */
- (void)addPlayingMenuOfCardColor
{
    _playingMenu = [BGPlayingMenu playingMenuWithMenuType:kPlayingMenuTypeCardColor ofPlayer:self];
    [self addChild:_playingMenu];
}

#pragma mark - Playing deck
- (void)addAllFacedDownPlayingCardsOfTargetPlayer
{
    [_playingDeck addAllFacedDownPlayingCardsOfTargetPlayer];
}

- (void)gotAllFacedDownPlayingCardsWithCardIds:(NSArray *)cardIds
{
    [_handArea gotAllFacedDownPlayingCardsWithCardIds:cardIds];
}

- (void)lostPlayingCardsWithCardIds:(NSArray *)cardIds
{
    [_handArea lostPlayingCardsWithCardIds:cardIds];
    [[BGGameLayer sharedGameLayer] clearTargetObjectBuffer];
}

@end
