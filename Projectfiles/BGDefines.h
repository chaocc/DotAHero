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

#define POSITION_TO_BE_SELECTED_HERO    ccp(SCREEN_WIDTH / 2, SCREEN_HEIGHT * 0.6)
#define POSITION_HERO_SEL_PROGRESS_BAR  ccp(SCREEN_WIDTH / 2, SCREEN_HEIGHT * 0.4)
#define POSITION_PLYAING_PROGRESS_BAR   ccp(SCREEN_WIDTH / 2, SCREEN_HEIGHT * 0.27)
#define POSITION_PLAYING_MENU           ccp(SCREEN_WIDTH / 2, SCREEN_HEIGHT * 0.35)
#define POSITION_CARD_ANIMATION         ccp(SCREEN_WIDTH / 2, SCREEN_HEIGHT * 0.35)
#define POSITION_EXTRACTED_HAND_CARD    ccp(SCREEN_WIDTH / 2, SCREEN_HEIGHT * 0.65)
#define POSITION_EXTRACTED_EQUIPMENT    ccp(SCREEN_WIDTH / 2, SCREEN_HEIGHT * 0.45)
#define POSITION_DECK_AREA_CENTER       ccp(SCREEN_WIDTH / 2, SCREEN_HEIGHT * 0.60)
#define POSITION_DECK_AREA_TOP          ccp(SCREEN_WIDTH / 2, SCREEN_HEIGHT * 0.65)
#define POSITION_DECK_AREA_BOTTOM       ccp(SCREEN_WIDTH / 2, SCREEN_HEIGHT * 0.45)
#define POSITION_DECK_AREA_LEFT         ccp(SCREEN_WIDTH * 0.28, SCREEN_HEIGHT * 0.65)
#define POSITION_DECK_AREA_RIGHT        ccp(SCREEN_WIDTH * 0.80, SCREEN_HEIGHT * 0.65)
#define POSITION_HAND_AREA_LEFT         ccp(SCREEN_WIDTH * 0.27, SCREEN_HEIGHT * 0.115)
#define POSITION_HAND_AREA_RIGHT        ccp(SCREEN_WIDTH * 0.806, SCREEN_HEIGHT * 0.115)

#define COLOR_DISABLED_CARD             ccc3(120, 120, 120)

#define COUNT_TOTAL_CARD                80
#define COUNT_INITIAL_HAND_CARD         5
#define COUNT_MAX_HAND_CARD_NO_OVERLAP  6
#define COUNT_MAX_DECK_CARD_NO_OVERLAP  5

#define DURATION_GAMELAYER_TRANSITION   0.2f
#define DURATION_HERO_SEL_SHOW_DELAY    DURATION_GAMELAYER_TRANSITION + 0.1f
#define DURATION_HERO_SEL_FADE_IN       0.1f
#define DURATION_SELECTED_HERO_MOVE     0.5f
#define DURATION_HAND_CARD_MOVE         0.2f
#define DURATION_SELECTED_CARD_MOVE     0.1f
#define DURATION_USED_CARD_MOVE         0.8f
#define DURATION_USED_CARD_FADE_OUT     0.3f
#define DURATION_CARD_FLIP              0.2f
#define DURATION_CARD_FLIP_INTERVAL     0.05f
#define DURATION_CARD_ANIMATION_SCALE   0.1f
#define DURATION_CARD_SCALE             0.3f
#define DURATION_CARD_SCALE_DELAY       0.2f

#define SCALE_SELECTED_HERO             0.5f
#define SCALE_SELF_PLAYER_ANIMATION     0.8f
#define SCALE_OTHER_PLAYER_ANIMATION    0.5f
#define SCALE_CARD_ORGINAL              1.0f
#define SCALE_CARD_UP                   1.4f

#define PADDING_CUTTED_CARD             1.0f
#define PADDING_SKILL_BUTTONS           0.0f
#define PADDING_TWO_BUTTONS             40.0f
#define PADDING_THREE_BUTTONS           20.0f
#define PADDING_SUITS_BUTTONS           0.0f

#endif
