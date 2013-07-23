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
    kPlayerTagHandCardCount
};


@interface BGPlayer ()


@end

@implementation BGPlayer

@synthesize handCardCount = _handCardCount;

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
        
        [self renderPlayingDeck];
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

- (void)clearBuffer
{
    [self clearSelectedObjectBuffer];
    [self clearPlayingDeckObject];
    [[BGGameLayer sharedGameLayer].targetPlayerNames removeAllObjects];
}

#pragma mark - Playing deck and player area
/*
 * Add playing deck for showing used/cutting cards or others
 */
- (void)renderPlayingDeck
{
    _playingDeck = [BGPlayingDeck playingDeckWithPlayer:self];
    [self addChild:_playingDeck];
}

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
        _playerAreaPosition = sprite.position;
    }
    
    [self addChild:sprite];
}

#pragma mark - To be selected heros
/*
 * Render the to be selected heros that are selected by current player
 */
- (void)renderToBeSelectedHeros:(NSArray *)heroIds
{
    NSArray *heroCards = [self.class heroCardsWithHeroIds:heroIds];
    
    BGMenuFactory *menuFactory = [BGMenuFactory menuFactory];
    CCMenu *heroMenu = [menuFactory createMenuWithCards:heroCards];
    heroMenu.position = ccp(SCREEN_WIDTH/2, SCREEN_HEIGHT*0.6);
    [heroMenu alignItemsHorizontally];
    [self addChild:heroMenu];
    
    menuFactory.delegate = self;
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
    
//  5 hand cards for each player at the beginning, use 1 card for cutting.
    self.handCardCount = INITIAL_HAND_CARD_COUND;
}

#pragma mark - Hero card selection
/*
 * Menu delegate method is called while selecting a hero card
 */
- (void)menuItemTouched:(CCMenuItem *)menuItem
{
    _selectedHeroId = menuItem.tag;
    [self runActionWithSelectedHeroMenu:menuItem];
    
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
                                               [[BGClient sharedClient] sendSelectHeroCardRequest];
                                           }];
}

#pragma mark - Hand cards
/*
 * Draw hand cards after player confirm drawing
 */
- (void)drawPlayingCardIds:(NSArray *)cardIds
{
    [_handArea addHandCardsWithCardIds:cardIds];
}

/*
 * Display hand card count at right corner of hero avatar(Only for other player)
 */
- (void)renderHandCardCount
{
    [[self getChildByTag:kPlayerTagHandCardCount] removeFromParentAndCleanup:YES];
    
    CCLabelTTF *countLabel = [CCLabelTTF labelWithString:@(_handCardCount).stringValue
                                                fontName:@"Arial"
                                                fontSize:22.0f];
    countLabel.position = ccp(-_playerAreaSize.width*0.07, -_playerAreaSize.height*0.23);
    [self addChild:countLabel z:1 tag:kPlayerTagHandCardCount];
}

- (void)setHandCardCount:(NSUInteger)handCardCount
{
    _handCardCount = handCardCount;
    if (!_isCurrentPlayer) {
        [self renderHandCardCount];
    }
}

- (NSUInteger)handCardCount
{
    return (_isCurrentPlayer) ? _handArea.handCards.count : _handCardCount;
}

- (void)updateBloodAndAngerWithBloodPoint:(NSInteger)bloodPoint
                            andAngerPoint:(NSInteger)angerPoint
{
    [_heroArea updateBloodPointWithCount:bloodPoint];
    [_heroArea updateAngerPointWithCount:angerPoint];
}

- (void)clearSelectedObjectBuffer
{
    _selectedCardIds = nil;
    [_extractedCardIdxes removeAllObjects];
    _isSelectedStrenthen = NO;
    _selectedColor = kCardColorInvalid;
    _selectedSuits = kCardSuitsInvalid;
}

#pragma mark - Playing menu
/*
 * Add hand area node(Delay 0.5 second for performance)
 */
- (void)addHandAreaWithCardIds:(NSArray *)cardIds
{
    _handArea = [BGHandArea handAreaWithPlayingCardIds:cardIds ofPlayer:self];
    [self addChild:_handArea];
    
    [self addPlayingMenuOfCardCutting];
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
/*
 * Determine the initial player by cutting card
 */
- (void)showAllCuttingCardsWithCardIds:(NSArray *)cardIds
{
    [_playingDeck showAllCuttingCardsWithCardIds:cardIds];
}

/*
 * 1. Face down all hand cards on the deck
 * 2. Add equipment cards of target player on the deck(使用贪婪的玩家)
 */
- (void)faceDownAllHandCardsOnDeck
{
    BGGameLayer *gamePlayer = [BGGameLayer sharedGameLayer];
    BGPlayer *targetPlayer = [gamePlayer playerWithName:gamePlayer.targetPlayerNames.lastObject];
    
    if (_playerState == kPlayerStateExtractingCard) {
        [_playingDeck facedDownAllHandCardsOfPlayer:targetPlayer];
        [_playingDeck addEquipmentCardsOfTargetPlayer];
    } else {
        [_playingDeck facedDownAllHandCardsOfPlayer:gamePlayer.sourcePlayer];
    }
}

- (void)gotExtractedHandCardsWithCardIds:(NSArray *)cardIds
{
    [_handArea gotExtractedHandCardsWithCardIds:cardIds];
}

- (void)lostHandCardsWithCardIds:(NSArray *)cardIds
{
    [_handArea lostHandCardsWithCardIds:cardIds];
}

- (void)clearPlayingDeckObject
{
    [_playingDeck.cardMenu removeAllChildrenWithCleanup:YES];
}

@end
