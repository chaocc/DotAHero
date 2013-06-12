//
//  BGPhaseComponent.h
//  DotAHero
//
//  Created by Killua Liu on 5/30/13.
//
//

#import "BGComponent.h"

typedef NS_ENUM(NSInteger, BGTurnPhase) {
    kCastingMagicPhase,
    kDetermingPhase,
    kDrawingPhase,
    kPlayingPase,
    kDiscardingPhase,
    kTurnEndingPhase
};


@interface BGPhase : BGComponent

@property (nonatomic) BGTurnPhase currentPhase;

@end
