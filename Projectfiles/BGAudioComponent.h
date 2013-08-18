//
//  BGAudioComponent.h
//  DotAHero
//
//  Created by Killua Liu on 7/28/13.
//
//

#import <Foundation/Foundation.h>
#import "SimpleAudioEngine.h"

@interface BGAudioComponent : NSObject

+ (id)sharedAudioComponent;

- (void)playBackgroundAndLoop;
- (void)playDamage;
- (void)playEquipCard;
- (void)playRestoreBlood;

@end
