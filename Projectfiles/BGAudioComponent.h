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
- (void)playButtonClick;
- (void)playPlayerSelect;
- (void)playSkillSelect;
- (void)playDamage;
- (void)playCardEquip;
- (void)playBloodRestore;

@end
