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

@property (nonatomic) NSUInteger playingCardCount;      // 所有手牌数

@end

@implementation BGPlayer

- (id)initWithUserName:(NSString *)name isCurrentPlayer:(BOOL)flag
{
    if (self = [super init]) {
        _playerName = name;
        _isCurrentPlayer = flag;
        _canUseAttack = YES;
        
        [self renderPlayerArea];
    }
    return self;
}

+ (id)playerWithUserName:(NSString *)name isCurrentPlayer:(BOOL)flag
{
    return [[self alloc] initWithUserName:name isCurrentPlayer:flag];
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
        NSMutableArray *heroCards = [NSMutableArray array];
        [heroIds enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            BGCard *heroCard = [BGHeroCard cardWithCardId:[obj integerValue]];
            [heroCards addObject:heroCard];
        }];
        
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
- (void)setToBeSelectedHeroIds:(NSArray *)toBeSelectedHeroIds
{
    _toBeSelectedHeroIds = toBeSelectedHeroIds;
    [self renderToBeSelectedHeros:_toBeSelectedHeroIds];
    _toBeSelectedHeroIds = nil; // Free memory
}

#pragma mark - Hero/playing area and playing menu
/*
 * Add hero(avatar) area node
 */
- (void)addHeroAreaWithHeroId:(NSUInteger)heroId
{
    _heroArea = [BGHeroArea heroAreaWithHeroCardId:heroId ofPlayer:self];
    [self addChild: _heroArea z:1];
    
    [self updatePlayingCardCountBy:5];  // 5 playing cards for each player at the beginning
}

/*
 * Add playing area node(Delay 0.5 second for performance)
 */
- (void)addPlayingAreaWithPlayingCardIds:(NSArray *)cardIds
{
    CCDelayTime *delay = [CCDelayTime actionWithDuration:0.5f];
    CCCallBlock *block = [CCCallBlock actionWithBlock:^{
        _playingArea = [BGPlayingArea playingAreaWithPlayingCardIds:cardIds ofPlayer:self];
        [self addChild:_playingArea z:2];
        
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

#pragma mark - Cutting card
- (void)showAllCuttingCardsWithCardIds:(NSArray *)cardIds
{
    NSMutableArray *cards = [NSMutableArray arrayWithCapacity:[BGGameLayer sharedGameLayer].players.count];
    [cardIds enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        BGCard *card = [BGPlayingCard cardWithCardId:[obj integerValue]];
        [cards addObject:card];
    }];
    
    BGMenuFactory *menuFactory = [BGMenuFactory menuFactory];
    CCMenu *menu = [menuFactory createMenuWithCards:cards];
    [menu alignItemsHorizontally];
    menu.position = ccp(SCREEN_WIDTH/2, SCREEN_HEIGHT*0.55);
    [self addChild:menu];
}

#pragma mark - Hero card selection
/*
 * Menu delegate method is called while selecting a hero card
 */
- (void)menuItemTouched:(CCMenuItem *)menuItem
{
    NSAssert([menuItem isKindOfClass:[CCMenuItem class]], @"Not a CCMenuItem");
    _selectedHeroId = menuItem.tag;
    [self runActionWithSelectedHeroMenu:menuItem];
    
    [[BGClient sharedClient] sendSelectHeroCardRequestWithHeroId:menuItem.tag];
    
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
                                               NSAssert([menuItem.parent isKindOfClass:[CCMenu class]], @"Not a CCMenu");
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
    if (_isCurrentPlayer) {
        [_playingArea addPlayingCardsWithCardIds:cardIds];
    } else {
        [self updatePlayingCardCountBy:cardIds.count];
    }
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
    [self addChild:countLabel z:0 tag:kPlayerTagPlayingCardCount];
}

/*
 * Update playing card count for other players
 */
- (void)updatePlayingCardCountBy:(NSUInteger)count
{
    _playingCardCount += count;
    [self renderPlayingCardCount];
}

@end
