//
//  iphone_input.h
//  lowang
//
//  Created by termit on 10/20/12.
//
//

#ifndef lowang_iphone_input_h
#define lowang_iphone_input_h

typedef struct
{
    short vel;
    short svel;
    signed char angvel;
    signed char aimvel;
    long bits;
} SW_PACKET;

typedef struct {
    float freelook_x, freelook_y;
    float movestick_x, movestick_y;
    float aimstick_x, aimstick_y;
} iphone_input_t;

extern iphone_input_t iphone_input;
extern int verticalAimScale;
extern int centerView;

void iphone_getinput(SW_PACKET *loc);

void iphone_setAimSensitivity(float sens_x, float sens_y);

#endif
