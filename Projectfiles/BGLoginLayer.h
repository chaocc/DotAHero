//
//  BGLoginLayer.h
//  DotAHero
//
//  Created by Killua Liu on 6/19/13.
//
//

#import "CCLayer.h"

@interface BGLoginLayer : CCLayer

@property (nonatomic, copy, readonly) NSString *userName;

+ (BGLoginLayer *)sharedLoginLayer;

- (void)showRoomListLayer;

@end
