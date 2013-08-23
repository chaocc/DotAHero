//
//  BGFaction.m
//  DotAHero
//
//  Created by Killua Liu on 6/14/13.
//
//

#import "BGFaction.h"
#import "BGGameLayer.h"
#import "BGRoleCard.h"
#import "BGFileConstants.h"
#import "BGDefines.h"

@interface BGFaction ()



@end

@implementation BGFaction

- (id)initWithRoleIds:(NSArray *)roleIds
{
    if (self = [super init]) {
        [roleIds enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            BGRoleCard *roleCard = [BGRoleCard cardWithCardId:[obj integerValue]];
            switch (roleCard.cardEnum) {
                case kRoleCardSentinel:
                    ++_totalSentinelCount;
                    break;
                case kRoleCardScourge:
                    ++_totalScourgeCount;
                    break;
                case kRoleCardNeutral:
                    ++_totalNeutralCount;
                    break;
                default:
                    break;
            }
        }];
        
        _aliveSentinelCount = _totalSentinelCount;
        _aliveScourgeCount = _totalScourgeCount;
        _aliveNeutralCount = _totalNeutralCount;
        
        [self renderFaction];
    }
    
    return self;
}

+ (id)factionWithRoleIds:(NSArray *)roleIds
{
    return [[self alloc] initWithRoleIds:roleIds];
}

/*
 * Render all factions at the left up corner
 */
- (void)renderFaction
{
    CCSpriteBatchNode *spriteBatch = [BGGameLayer sharedGameLayer].gameArtworkBatch;
    CGFloat increment;
    
    for (NSUInteger i = 0; i < 3; i++) {
        CCSprite *sprite = [CCSprite spriteWithSpriteFrameName:kImageFactionFrame];
        sprite.position = ccp(sprite.contentSize.width/2, SCREEN_HEIGHT - sprite.contentSize.height*(increment+0.65));
        [spriteBatch addChild:sprite];
        
        CCSprite *faction = nil;
        switch (i) {
            case kRoleCardSentinel:
                faction = [CCSprite spriteWithSpriteFrameName:kImageSentinel];
                break;
                
            case kRoleCardScourge:
                faction = [CCSprite spriteWithSpriteFrameName:kImageScourge];
                break;
                
            case kRoleCardNeutral:
                faction = [CCSprite spriteWithSpriteFrameName:kImageNeutral];
                break;
                
            default:
                break;
        }
        faction.position = ccpSub(sprite.position, ccp(sprite.contentSize.width*0.32, 0.0f));
        [spriteBatch addChild:faction];
        
        increment += 1.2f;
    }
}

@end
