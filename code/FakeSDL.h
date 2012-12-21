//
//  FakeSDL.h
//  isw
//
//  Created by Sergei Shubin on 12/8/12.
//  Copyright (c) 2012 s.v.shubin@gmail.com. All rights reserved.
//

#ifndef isw_FakeSDL_h
#define isw_FakeSDL_h

#include <inttypes.h>

typedef int32_t Uint32;

enum {
    SDL_INIT_JOYSTICK,
    SDL_ENABLE,
    SDL_IGNORE,
    SDL_QUERY,
};

typedef struct {
    int type;
} SDL_Joystick;

SDL_Joystick *SDL_JoystickOpen(int index);
int SDL_InitSubSystem(int index);
int SDL_NumJoysticks(void);
const char* SDL_JoystickName(int device_index);
int SDL_JoystickEventState(int state);
int SDL_JoystickNumAxes(SDL_Joystick* joystick);
int SDL_JoystickNumButtons(SDL_Joystick* joystick);
int SDL_JoystickNumHats(SDL_Joystick* joystick);
SDL_Joystick* SDL_JoystickOpen(int device_index);
void SDL_JoystickClose(SDL_Joystick* joystick);
Uint32 SDL_GetTicks(void);
void SDL_GL_SwapBuffers(void);

#endif
