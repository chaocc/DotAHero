//
//  BGPlayer.m
//  DotAHero
//
//  Created by Killua Liu on 7/2/13.
//
//

#import "BGPlayer.h"
#import "BGGameLayer.h"
#import "BGFileConstants.h"
#import "BGDefines.h"
#import "BGMoveComponent.h"

typedef NS_ENUM(NSInteger, BGPlayerTag) {
    kPlayerTagPlayingCardCount
};


@interface BGPlayer ()

@property (nonatomic, strong) NSArray *playingCardIds;  // 初始手牌
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

//- (id)initWithName:(NSString *)name andHeroIds:(NSArray *)heroIds
//{
//    _isCurrentPlayer = YES;
//    if (self = [self initWithUserName:name]) {
//        [self renderToBeSelectedHeros:heroIds];
//    }
//    return self;
//}

+ (id)playerWithUserName:(NSString *)name isCurrentPlayer:(BOOL)flag
{
    return [[self alloc] initWithUserName:name isCurrentPlayer:flag];
}

//+ (id)playerWithName:(NSString *)name andHeroIds:(NSArray *)heroIds
//{
//    return [[self alloc] initWithName:name andHeroIds:heroIds];
//}

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

- (void)renderToBeSelectedHeros:(NSArray *)heroIds
{    
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
}

- (void)setToBeSelectedHeroIds:(NSArray *)toBeSelectedHeroIds
{
    _toBeSelectedHeroIds = toBeSelectedHeroIds;
    [self renderToBeSelectedHeros:_toBeSelectedHeroIds];
}

- (void)addHeroAreaWithHeroId:(NSUInteger)heroId
{
    _heroArea = [BGHeroArea heroAreaWithHeroCardId:heroId ofPlayer:self];
    [self addChild: _heroArea];
    
    [self updatePlayingCardCountBy:4];  // 4 playing cards for each player at the beginning
}

- (void)addPlayingAreaWithPlayingCardIds:(NSArray *)cardIds
{
    _playingArea = [BGPlayingArea playingAreaWithPlayingCardIds:cardIds ofPlayer:self];
    [self addChild:_playingArea];
}

#pragma mark - Menu Factory Delegate
- (void)menuItemTouched:(CCMenuItem *)menuItem
{
    NSAssert([menuItem isKindOfClass:[CCMenuItem class]], @"Not a CCMenuItem");
    [self runActionWithSelectedHeroMenu:menuItem];
    
    EsObject *obj = [[EsObject alloc] init];
    [obj setInt:kActionSelectHeroCard forKey:kAction];
    [obj setInt:menuItem.tag forKey:kParamHeroId];
    [[BGRoomLayer sharedRoomLayer] sendPluginRequestWithObject:obj pluginName:@"GamePlugin" andEventListener:self];
    
//  [(BGGameLayer *)self.parent transferRoleCardToNextPlayer];
}

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
                                               [self addHeroAreaWithHeroId:menuItem.tag];    // Add hero area node
                                               
//                                               NSArray *playingCardIds = [NSArray arrayWithObjects:@(0), @(1), @(2), @(3), nil];
//                                               [self addPlayingAreaWithPlayingCardIds:playingCardIds];
                                               
//                                               _playingMenu = [BGPlayingMenu playingMenuWithMenuType:kPlayingMenuTypeCardUsing ofPlayer:self];
//                                               [self addChild:_playingMenu];
                                               
                                               [menuItem.parent removeAllChildrenWithCleanup:YES];
                                           }];
}

- (void)onPluginMessageEvent:(EsPluginMessageEvent *)e
{
    EsObject *obj = e.parameters;
    
    switch ([e.parameters intWithKey:kAction]) {
        case kActionDealPlayingCards:
            [self addPlayingAreaWithPlayingCardIds:[obj stringArrayWithKey:kParamGotPlayingCardIds]];    // Add playing area node
            break;
            
        default:
            break;
    }
}

- (void)drawPlayingCardIds:(NSArray *)cardIds
{
    if (_isCurrentPlayer) {
        [_playingArea addPlayingCardsWithCardIds:cardIds];
    } else {
        [self updatePlayingCardCountBy:cardIds.count];
    }
}

// Display playing card count at right corner of hero avatar(Only for other player)
- (void)renderPlayingCardCount
{
    [[self getChildByTag:kPlayerTagPlayingCardCount] removeAllChildrenWithCleanup:YES];
    
    CCLabelTTF *countLabel = [CCLabelTTF labelWithString:@(_playingCardCount).stringValue
                                                fontName:@"Arial"
                                                fontSize:22.0f];
    countLabel.position = ccp(-_playerAreaSize.width*0.07, -_playerAreaSize.height*0.23);
    [self addChild:countLabel];
}

- (void)updatePlayingCardCountBy:(NSUInteger)count
{
    _playingCardCount += count;
    [self renderPlayingCardCount];
}

@end
