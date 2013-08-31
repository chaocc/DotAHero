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

#define TO_BE_SELECTED_HERO_POSITION    ccp(SCREEN_WIDTH / 2, SCREEN_HEIGHT * 0.6)
#define HERO_SELECTION_PROGRESS_BAR_POS ccp(SCREEN_WIDTH / 2, SCREEN_HEIGHT * 0.4)
#define CURRENT_PROGRESS_BAR_POSITION   ccp(SCREEN_WIDTH / 2, SCREEN_HEIGHT * 0.27)
#define PLAYING_MENU_POSITION           ccp(SCREEN_WIDTH / 2, SCREEN_HEIGHT * 0.35)
#define USED_CARD_POSITION              ccp(SCREEN_WIDTH / 2, SCREEN_HEIGHT * 0.60)
#define EXTRACTED_HAND_CARD_POSITION    ccp(SCREEN_WIDTH / 2, SCREEN_HEIGHT * 0.65)
#define EXTRACTED_EQUIPMENT_POSITION    ccp(SCREEN_WIDTH / 2, SCREEN_HEIGHT * 0.45)
#define CARD_EFFECT_POSITION            ccp(SCREEN_WIDTH / 2, SCREEN_HEIGHT * 0.35)


#define TOTAL_CARD_COUNT            80
#define INITIAL_HAND_CARD_COUND     5
#define DEFAULT_CARD_PADDING        1.0f

#define GAME_TRANSITION_DURATION    0.2f
#define CARD_MOVE_DURATION          0.5f

#endif
