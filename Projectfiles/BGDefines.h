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

#define SCREEN_SIZE                     [CCDirector sharedDirector].screenSize
#define SCREEN_WIDTH                    SCREEN_SIZE.width
#define SCREEN_HEIGHT                   SCREEN_SIZE.height

#define PLAYING_CARD_SIZE               [[CCSprite spriteWithSpriteFrameName:kImagePlayingCardBack] contentSize]
#define PLAYING_CARD_WIDTH              PLAYING_CARD_SIZE.width
#define PLAYING_CARD_HEIGHT             PLAYING_CARD_SIZE.height

#define POSITION_TO_BE_SELECTED_HERO    ccp(SCREEN_WIDTH / 2, SCREEN_HEIGHT * 0.6)
#define POSITION_PLYAING_PROGRESS_BAR   ccp(SCREEN_WIDTH * 0.54, SCREEN_HEIGHT * 0.26)
#define POSITION_PLAYING_MENU           ccp(SCREEN_WIDTH / 2, SCREEN_HEIGHT * 0.34)
#define POSITION_TEXT_PROMPT            ccp(SCREEN_WIDTH / 2, SCREEN_HEIGHT * 0.29)
#define POSITION_CARD_ANIMATION         ccp(SCREEN_WIDTH / 2, SCREEN_HEIGHT * 0.35)
#define POSITION_DECK_AREA_CENTER       ccp(SCREEN_WIDTH / 2, SCREEN_HEIGHT * 0.60)
#define POSITION_DECK_AREA_TOP          ccp(SCREEN_WIDTH / 2, SCREEN_HEIGHT * 0.65)
#define POSITION_DECK_AREA_BOTTOM       ccp(SCREEN_WIDTH / 2, SCREEN_HEIGHT * 0.45)
#define POSITION_DECK_AREA_LEFT         ccp(SCREEN_WIDTH * 0.28, SCREEN_HEIGHT * 0.65)
#define POSITION_DECK_AREA_RIGHT        ccp(SCREEN_WIDTH * 0.80, SCREEN_HEIGHT * 0.65)
#define POSITION_HAND_AREA_LEFT         ccp(SCREEN_WIDTH * 0.263, SCREEN_HEIGHT * 0.115)
#define POSITION_HAND_AREA_RIGHT        ccp(SCREEN_WIDTH * 0.813, SCREEN_HEIGHT * 0.115)
#define POSITION_EQUIPMENT_AREA         ccp(SCREEN_WIDTH * 0.9, SCREEN_HEIGHT * 0.2)

#define COLOR_DISABLED                  ccc3(120, 120, 120)
#define COLOR_DISABLED_CARD             ccc3(120, 120, 120)

#define COUNT_TOTAL_CARD                80
#define COUNT_INITIAL_HAND_CARD         5
#define COUNT_MAX_HAND_CARD             6
#define COUNT_MAX_DECK_CARD             5
#define COUNT_MAX_DREW_CARD             5

#define DURATION_GAMELAYER_TRANSITION   0.2f
#define DURATION_SELECTED_HERO_MOVE     0.5f
#define DURATION_HAND_CARD_MOVE         0.5f
#define DURATION_SELECTED_CARD_MOVE     0.1f
#define DURATION_CARD_MOVE              0.8f
#define DURATION_DECK_CARD_MOVE         0.5f
#define DURATION_USED_CARD_FADE_OUT     0.5f
#define DURATION_CARD_FLIP              0.2f
#define DURATION_CARD_FLIP_INTERVAL     0.05f
#define DURATION_CARD_ANIMATION_SCALE   0.1f
#define DURATION_CARD_SCALE             0.3f
#define DURATION_CARD_SCALE_DELAY       0.3f
#define DURATION_ANIMATION_DELAY        0.08f

#define SCALE_SELECTED_HERO             0.5f
#define SCALE_SELF_PLAYER_ANIMATION     0.8f
#define SCALE_OTHER_PLAYER_ANIMATION    0.5f
#define SCALE_CARD_INITIAL              1.0f
#define SCALE_CARD_UP                   1.4f

#define PADDING_CUTTED_CARD             1.0f
#define PADDING_DREW_CARD               0.0f
#define PADDING_ASSIGNED_CARD           1.0f
#define PADDING_SKILL_BUTTON            0.0f
#define PADDING_TWO_BUTTONS             40.0f
#define PADDING_THREE_BUTTONS           20.0f
#define PADDING_SUITS_BUTTON            0.0f


#define PLAYING_CARD_PADDING(x, max)        (x > max) ? -(PLAYING_CARD_WIDTH*(x-max) / (x-1)) : 0.0f
#define CARD_MOVE_POSITION(pos, x, count)   ccpAdd(pos, ccp((NSInteger)(x+1-count+x)*PLAYING_CARD_WIDTH/4, 0.0f))

#endif
