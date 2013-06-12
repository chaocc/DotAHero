//
//  BGPlayerComponent.h
//  DotAHero
//
//  Created by Killua Liu on 5/30/13.
//
//

#import "BGComponent.h"

@interface BGPlayer : BGComponent

@property (nonatomic) BOOL isPlaying;
@property (nonatomic) BOOL isReplied;
@property (nonatomic) NSUInteger attacktimes;

@end
