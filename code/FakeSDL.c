//
//  FakeSDL.c
//  isw
//
//  Created by Sergei Shubin on 12/8/12.
//  Copyright (c) 2012 s.v.shubin@gmail.com. All rights reserved.
//

#include <stdio.h>
#include <stdlib.h>
#include <sys/time.h>
#include "FakeSDL.h"

SDL_Joystick *SDL_JoystickOpen(int index) {
    SDL_Joystick *j = (SDL_Joystick*)malloc(sizeof(SDL_Joystick));
    j->type = 0;
    return j;
}

int SDL_InitSubSystem(int index) {
    return 0;
}

int SDL_NumJoysticks(void) {
    return 1;
}

const char* SDL_JoystickName(int device_index) {
    return "On-screen controls";
}

int SDL_JoystickEventState(int state) {
    return SDL_ENABLE;
}

int SDL_JoystickNumAxes(SDL_Joystick* joystick) {
    return 4;
}

int SDL_JoystickNumButtons(SDL_Joystick* joystick) {
    return 101;
}

int SDL_JoystickNumHats(SDL_Joystick* joystick) {
    return 0;
}

void SDL_JoystickClose(SDL_Joystick* joystick) {
    free(joystick);
}

Uint32 SDL_GetTicks(void) {
    struct timeval tv;
    gettimeofday(&tv,NULL);
    return (int)(tv.tv_sec*1000 + (tv.tv_usec / 1000));
}

void SDL_GL_SwapBuffers(void) {
    void VID_SwapBuffers(void);
    VID_SwapBuffers();
}
