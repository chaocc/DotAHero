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
        _selectedHeroId = kHeroCardInvalid;
        _selectedCardIds = [NSMutableArray array];
        _selectedCardIdxes = [NSMutableArray array];
        _canDrawCardCount = 2;
        _selectedSkillId = kHeroSkillInvalid;
        
        [self renderPlayerArea];
    }
    return self;
}

+ (id)playerWithUserName:(NSString *)name isCurrentPlayer:(BOOL)isCurrentPlayer
{
    return [[self alloc] initWithUserName:name isCurrentPlayer:isCurrentPlayer];
}

- (void)clearBuffer
{
    [self clearSelectedObjectBuffer];
    [[BGGameLayer sharedGameLayer].targetPlayerNames removeAllObjects];
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
        _playerAreaPosition = sprite.position;
    }
    [self addChild:sprite];
    
//  Add hero and equipment area for all players
    [self addHeroArea];
    [self addEquipmentArea];
    
//  Only add hand area for current player
    if (_isCurrentPlayer) {
        [self addHandArea];
    }
}

/*
 * Add hero(avatar) area node
 */
- (void)addHeroArea
{
    _heroArea = [BGHeroArea heroAreaWithPlayer:self];
    [self addChild: _heroArea];
}

/*
 * Add hand area node
 */
- (void)addHandArea
{
    _handArea = [BGHandArea handAreaWithPlayer:self];
    [self addChild:_handArea];
}

/*
 * Add equipment area for showing equipment cards
 */
- (void)addEquipmentArea
{
    _equipmentArea = [BGEquipmentArea equipmentAreaWithPlayer:self];
    [self addChild:_equipmentArea];
}

#pragma mark - Hero area
- (void)initHeroWithHeroId:(NSInteger)heroId
{
    _selectedHeroId = heroId;
    [_heroArea initHeroWithHeroId:heroId];
}

/*
 * Update hero blood and anger point
 */
- (void)updateHeroWithBloodPoint:(NSInteger)bloodPoint angerPoint:(NSUInteger)angerPoint
{
    [_heroArea updateBloodPointWithCount:bloodPoint];
    [_heroArea updateAngerPointWithCount:angerPoint];
}

#pragma mark - Hand cards
- (void)initHandCardWithCardIds:(NSArray *)cardIds
{
    [_handArea updateHandCardWithCardIds:cardIds];
    _handArea.selectableCardCount = 1;
}

/*
 * Update(Draw/Got/Lost) hand card with card id list and update other properties
 */
- (void)updateHandCardWithCardIds:(NSArray *)cardIds selectableCardCount:(NSUInteger)count
{
    [_handArea updateHandCardWithCardIds:cardIds];
    _handArea.selectableCardCount = count;
}




- (void)addHeroAreaWithHeroId:(NSInteger)heroId
{
    _handSizeLimit = _heroArea.heroCard.handSizeLimit;
    
//  5 hand cards for each player at the beginning, use 1 card for cutting.
    self.handCardCount = INITIAL_HAND_CARD_COUND;
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

- (void)clearSelectedObjectBuffer
{
    _selectedCardIds = nil;
    [_selectedCardIdxes removeAllObjects];
    _selectedColor = kCardColorInvalid;
    _selectedSuits = kCardSuitsInvalid;
    _selectedSkillId = kHeroSkillInvalid;
}

#pragma mark - Playing menu
/*
 * Add playing menu items according to different action
 */
- (void)addPlayingMenu
{
    switch (_action) {
        case kActionPlayingCard:            // 主动使用
            _playingMenu = [BGPlayingMenu playingMenuWithMenuType:kPlayingMenuTypePlaying];
            break;
            
        case kActionChooseCardToUse:        // 被动使用
            _playingMenu = [BGPlayingMenu playingMenuWithMenuType:kPlayingMenuTypeChoosing];
            break;
            
        case kActionChooseCardToCompare:    // 确定拼点
        case kActionChooseCardToDiscard:    // 确定弃牌
            _playingMenu = [BGPlayingMenu playingMenuWithMenuType:kPlayingMenuTypeOkay];
            break;
            
        case kActionChoosingColor:          // 选择卡牌颜色
            _playingMenu = [BGPlayingMenu playingMenuWithMenuType:kPlayingMenuTypeCardColor];
            break;
            
        case kActionChoosingSuits:          // 选择卡牌花色
            _playingMenu = [BGPlayingMenu playingMenuWithMenuType:kPlayingMenuTypeCardSuits];
            break;
            
        default:
            break;
    }
    
    [self addChild:_playingMenu];
}

#pragma mark - Playing deck
///*
// * Determine the initial player by cutting card
// */
//- (void)showAllCuttingCardsWithCardIds:(NSArray *)cardIds
//{
//    [_playingDeck showAllCuttingCardsWithCardIds:cardIds];
//}
//
///*
// * 1. Face down all hand cards on the deck
// * 2. Also add equipment cards of target player on the deck(使用贪婪的玩家)
// */
//- (void)faceDownAllHandCardsOnDeck
//{
//    BGGameLayer *gamePlayer = [BGGameLayer sharedGameLayer];
//    BGPlayer *targetPlayer = [gamePlayer playerWithName:gamePlayer.targetPlayerNames.lastObject];
//    
//    if (_playerState == kPlayerStateGreeding) {
//        [_playingDeck facedDownAllHandCardsOfPlayer:targetPlayer];
//        [_playingDeck addEquipmentCardsOfTargetPlayer:targetPlayer];
//    } else {
//        [_playingDeck facedDownAllHandCardsOfPlayer:gamePlayer.sourcePlayer];
//    }
//}
//
//- (void)gotExtractedCardsWithCardIds:(NSArray *)cardIds
//{
//    [_handArea gotExtractedCardsWithCardIds:cardIds];
//}
//
///*
// * If is greeding player, only lost hand cards.
// * If is greeded player, can lost hand cards or equipment.
// */
//- (void)lostCardsWithCardIds:(NSArray *)cardIds
//{
//    if ([self isEqual:[BGGameLayer sharedGameLayer].sourcePlayer]) {
//        [_handArea lostCardsWithCardIds:cardIds];
//    }
//    else {
//        if ([BGGameLayer sharedGameLayer].sourcePlayer.selectedGreedType == kGreedTypeHandCard) {
//            [_handArea lostCardsWithCardIds:cardIds];   // 手牌
//        } else {
//            NSArray *cards = [BGHandArea playingCardsWithCardIds:cardIds];
//            [_equipmentArea lostEquipmentWithCard:cards.lastObject];    // 装备
//        }
//    }
//}

@end
