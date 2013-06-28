//
//  BGCurrentPlayer.m
//  DotAHero
//
//  Created by Killua Liu on 5/30/13.
//
//

#import "BGCurrentPlayer.h"
#import "BGGameLayer.h"

@interface BGCurrentPlayer()

@property (nonatomic, readonly) CGRect playerAreaBox;

@end

@implementation BGCurrentPlayer

- (id)initWithName:(NSString *)name andHeroCards:(NSArray *)cards
{
    if (self = [super init]) {
        _playerName = name;
        
        [self renderPlayerArea];
        [self renderToBeSelectedHeros:cards];
    }
    return self;
}

+ (id)playerWithName:(NSString *)name andHeroCards:(NSArray *)cards
{
    return [[self alloc] initWithName:name andHeroCards:cards];
}

- (void)renderPlayerArea
{
    CCSprite *sprite = [CCSprite spriteWithSpriteFrameName:@"CurrentPlayerArea.png"];
    _playerAreaBox = sprite.boundingBox;
    sprite.position = ccp(sprite.contentSize.width/2, sprite.contentSize.height/2);
    [self addChild:sprite];
}

- (void)renderToBeSelectedHeros:(NSArray *)heroCards
{
    CCSpriteFrameCache *spriteFrameCache = [CCSpriteFrameCache sharedSpriteFrameCache];
    [spriteFrameCache addSpriteFramesWithFile:@"HeroCard.plist"];
    
    NSMutableArray *cardNames = [NSMutableArray array];
    for (NSNumber *heroId in heroCards) {
        BGHeroCardComponent *heroComponent = [BGHeroCardComponent heroCardComponentWithId:heroId.integerValue];
        [cardNames addObject:heroComponent.heroName];
    }
    
    BGMenuFactory *menuFactory = [BGMenuFactory menuFactory];
    CCMenu *heros = [menuFactory createMenuWithSpriteFrameNames:cardNames ofObjects:heroCards];
    CGSize winSize = [[CCDirector sharedDirector] winSize];
    heros.position = ccp(winSize.width/2, winSize.height*0.6);
    [heros alignItemsHorizontally];
    [self addChild:heros];
    
    menuFactory.delegate = self;
}

#pragma mark - Menu Factory Delegate
- (void)menuItemTouched:(CCMenuItem *)menuItem
{
//    CCSpriteFrameCache *spriteFrameCache = [CCSpriteFrameCache sharedSpriteFrameCache];
//    [spriteFrameCache addSpriteFramesWithFile:@"CardEffect.plist"];
//    
//    CCSprite *sprite = [CCSprite spriteWithSpriteFrameName:@"NormalAttack0.png"];
//    CGFloat x = [BGGameLayer sharedGameLayer].otherPlayerPosition.x;
//    CGFloat y = [BGGameLayer sharedGameLayer].otherPlayerPosition.y;
//    sprite.position = ccp(x - [BGGameLayer sharedGameLayer].otherPlayerAreaSize.width/4, y);
//    
//    CCAnimation *animation = [CCAnimation animationWithFrames:@"NormalAttack" frameCount:9 delay:0.08f];
//    CCAnimate *animate = [CCAnimate actionWithAnimation:animation];
//    CCRepeatForever *repeat = [CCRepeatForever actionWithAction:animate];
//    [sprite runAction:repeat];
//    [self addChild:sprite];
    
    [self runActionWithSelectedHeroMenu:menuItem];
    
    
//    [(BGGameLayer *)self.parent transferRoleCardToNextPlayer];
    
//  ...TODO...    
//  1. Receive other players name and hero ids from server
//  2. Receive two roles id from server
//  3. Receive four playing cards id from server
}

- (void)runActionWithSelectedHeroMenu:(CCMenuItem *)menuItem
{
    for (CCMenuItem *item in menuItem.parent.children) {
        if (![item isEqual:menuItem]) {
            item.visible = NO;
        }
    }
    
    CGSize winSize = [[CCDirector sharedDirector] winSize];
    BGMoveComponent *moveComp = [BGMoveComponent moveWithTarget:ccp(-winSize.width*0.4, -winSize.height*0.4)
                                                         ofNode:menuItem];
    [moveComp runActionEaseMoveScale];
    
    moveComp.delegate = self;
}

#pragma mark - Move Component Delegate
- (void)moveActionEnded:(CCNode *)node
{
    self.heroArea = [BGHeroArea heroAreaWithHeroCard:node.tag inPlayerAreaBox:_playerAreaBox];
    [self addChild: _heroArea];
//  ...TODO...
//  Pass a hero ID to server
}

@end
