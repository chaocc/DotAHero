//
//  BGFaction.m
//  DotAHero
//
//  Created by Killua Liu on 6/14/13.
//
//

#import "BGFaction.h"
#import "BGRoleCardComponent.h"

@interface BGFaction ()

@property (nonatomic, strong) CCSpriteBatchNode *spriteBatch;

@end

@implementation BGFaction

- (id)initWithSentinelCount:(NSUInteger)sentinelCount scourgeCount:(NSUInteger)scourgeCount andNeutralCount:(NSUInteger)neutralCount
{
    if (self = [super init]) {
        _totalSentinelCount = sentinelCount;
        _totalScourgeCount = scourgeCount;
        _totalNeutralCount = neutralCount;
        
        self.spriteBatch = [CCSpriteBatchNode batchNodeWithFile:@"GameImage.pvr.ccz"];
        CGSize winSize = [[CCDirector sharedDirector] winSize];
        CGFloat increment;
        
        for (NSUInteger i = 0; i < 3; i++) {
            CCSprite *sprite = [CCSprite spriteWithSpriteFrameName:@"FactionFrame.png"];
            sprite.position = ccp(sprite.contentSize.width/2, winSize.height - sprite.contentSize.height*(increment+0.7));
            [_spriteBatch addChild:sprite];
            
            switch (i) {
                case kSentinel: {
                    CCSprite *sentinel = [CCSprite spriteWithSpriteFrameName:@"Sentinel.png"];
                    sentinel.position = ccp(sprite.position.x*0.35, sprite.position.y);
                    [_spriteBatch addChild:sentinel];
                }
                    break;
                
                case kScourge: {
                    CCSprite *scourge = [CCSprite spriteWithSpriteFrameName:@"Scourge.png"];
                    scourge.position = ccp(sprite.position.x*0.35, sprite.position.y);
                    [_spriteBatch addChild:scourge];
                }
                    break;
                    
                case kNeutral: {
                    CCSprite *neutral = [CCSprite spriteWithSpriteFrameName:@"Neutral.png"];
                    neutral.position = ccp(sprite.position.x*0.35, sprite.position.y);
                    [_spriteBatch addChild:neutral];
                }
                    break;
                    
                default:
                    break;
            }
            
            increment += 1.2f;
        }
        
        [self addChild:_spriteBatch];
    }
    
    return self;
}

+ (id)factionWithSentinelCount:(NSUInteger)sentinelCount scourgeCount:(NSUInteger)scourgeCount andNeutralCount:(NSUInteger)neutralCount
{
    return [[self alloc] initWithSentinelCount:scourgeCount scourgeCount:scourgeCount andNeutralCount:neutralCount];
}

@end
