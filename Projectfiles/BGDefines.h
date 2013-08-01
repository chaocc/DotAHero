//
//  BGDefines.h
//  DotAHero
//
//  Created by Killua Liu on 6/29/13.
//
//

#ifndef DotAHero_BGDefines_h
#define DotAHero_BGDefines_h

#define SUPPRESS_PERFORM_SELECTOR_LEAK_WARNING(code)                \
_Pragma("clang diagnostic push")                                    \
_Pragma("clang diagnostic ignored \"-Warc-performSelector-leaks\"") \
code;                                                               \
_Pragma("clang diagnostic pop")                                     \

#define SCREEN_WIDTH                    [CCDirector sharedDirector].screenSize.width
#define SCREEN_HEIGHT                   [CCDirector sharedDirector].screenSize.height
#define PLAYING_MENU_POSITION           ccp(SCREEN_WIDTH / 2, SCREEN_HEIGHT * 0.35)
#define CARD_EFFECT_POSITION            ccp(SCREEN_WIDTH / 2, SCREEN_HEIGHT * 0.35)
#define DRAW_CARD_POSITION              ccp(SCREEN_WIDTH / 2, SCREEN_HEIGHT * 0.55)
#define USED_CARD_POSITION              ccp(SCREEN_WIDTH / 2, SCREEN_HEIGHT * 0.55)
#define EXTRACTED_HAND_CARD_POSITION    ccp(SCREEN_WIDTH / 2, SCREEN_HEIGHT * 0.65)
#define EXTRACTED_EQUIPMENT_POSITION    ccp(SCREEN_WIDTH / 2, SCREEN_HEIGHT * 0.45)

#define TOTAL_CARD_COUNT            80
#define INITIAL_HAND_CARD_COUND     7
#define DEFAULT_CARD_PADDING        5.0f
#define CARD_MOVE_DURATION          0.7f
#define RUN_DELAY_DURATION          0.7f

#endif
