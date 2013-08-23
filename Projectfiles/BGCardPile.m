//
//  BGCardPile.m
//  DotAHero
//
//  Created by Killua Liu on 7/19/13.
//
//

#import "BGCardPile.h"
#import "BGDefines.h"
#import "BGFileConstants.h"

typedef NS_ENUM(NSInteger, BGCardPileTag) {
    kCardPileTagFrame,      // 边框
    kCardPileTagCount       // 剩余牌数
};

@implementation BGCardPile

- (id)init
{
    if (self = [super init]) {
        CCSprite *sprite = [CCSprite spriteWithSpriteFrameName:kImageCardPile];
        CGSize spriteSize = sprite.contentSize;
        sprite.position = ccp(SCREEN_WIDTH - spriteSize.width*0.6, SCREEN_HEIGHT - spriteSize.height*1.8);
        [[BGGameLayer sharedGameLayer].gameArtworkBatch addChild:sprite z:0 tag:kCardPileTagFrame];
        
        [BGGameLayer sharedGameLayer].delegate = self;
    }
    
    return self;
}

+ (id)cardPile
{
    return [[self alloc] init];
}

/*
 * Update remaining card count on the UI
 */
- (void)remainingCardCountUpdate:(NSUInteger)count
{
    CCNode *cardPile = [[BGGameLayer sharedGameLayer].gameArtworkBatch getChildByTag:kCardPileTagFrame];
    
    [self removeAllChildrenWithCleanup:YES];
    CCLabelTTF *label = [CCLabelTTF labelWithString:@(count).stringValue
                                           fontName:@"Arial"
                                           fontSize:30.0f];
    label.position = ccpAdd(cardPile.position, ccp(cardPile.contentSize.width*0.2, 0.0f));
    [self addChild:label];
}


@end
