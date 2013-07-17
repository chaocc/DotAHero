//
//  BGCard.h
//  DotAHero
//
//  Created by Killua Liu on 6/30/13.
//
//

#import <Foundation/Foundation.h>

#define kCardEnum               @"cardEnum"
#define kCardName               @"cardName"
#define kCardText               @"cardText"

@interface BGCard : NSObject {
    NSInteger _cardId;
    NSInteger _cardEnum;
    NSString *_cardName;
    NSString *_cardImageName;
}

@property (nonatomic, readonly) NSInteger cardId;
@property (nonatomic, readonly) NSInteger cardEnum;
@property (nonatomic, copy, readonly) NSString *cardName;
@property (nonatomic, copy, readonly) NSString *cardImageName;

- (id)initWithCardId:(NSInteger)aCardId;
+ (id)cardWithCardId:(NSInteger)aCardId;

@end
