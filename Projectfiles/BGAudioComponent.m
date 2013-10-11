//
//  BGAudioComponent.m
//  DotAHero
//
//  Created by Killua Liu on 7/28/13.
//
//

#import "BGAudioComponent.h"
#import "BGFileConstants.h"

@interface BGAudioComponent ()

@property (nonatomic, strong) SimpleAudioEngine *audioEngine;
@property (nonatomic, strong) CDAudioManager *audioManager;

@end

@implementation BGAudioComponent

static BGAudioComponent *instanceOfClient = nil;

+ (id)sharedAudioComponent
{
    if (!instanceOfClient) {
        instanceOfClient = [[self alloc] init];
    }
	return instanceOfClient;
}

- (id)init
{
    if (self = [super init]) {
        _audioEngine = [SimpleAudioEngine sharedEngine];
        _audioManager = [CDAudioManager sharedManager];
		[_audioManager setResignBehavior:kAMRBStopPlay autoHandle:YES];
        
        [_audioEngine preloadBackgroundMusic:kAudioBackground];
        [_audioEngine preloadEffect:kAudioDamage];
        [_audioEngine preloadEffect:kAudioCardEquip];
        [_audioEngine preloadEffect:kAudioBloodRestore];
    }
    return self;
}

#pragma mark - Audio playing
- (void)playBackgroundAndLoop
{
    [_audioEngine playBackgroundMusic:kAudioBackground loop:YES];
    _audioManager.backgroundMusic.volume = 0.5f;
}

- (void)playButtonClick
{
    [_audioEngine playEffect:kButtonClick];
}

- (void)playPlayerSelect
{
    [_audioEngine playEffect:kPlayerSelect];
}

- (void)playSkillSelect
{
    [_audioEngine playEffect:kSkillSelect];
}

- (void)playDamage
{
    [_audioEngine playEffect:kAudioDamage];
}

- (void)playCardEquip
{
    [_audioEngine playEffect:kAudioCardEquip];
}

- (void)playBloodRestore
{
    [_audioEngine playEffect:kAudioBloodRestore];
}

@end
