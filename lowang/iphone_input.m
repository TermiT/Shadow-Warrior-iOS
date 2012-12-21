//
//  iphone_input.c
//  lowang
//
//  Created by termit on 10/20/12.
//
//


#include "build.h"
#include "compat.h"
#include "mytypes.h"

#import <Foundation/Foundation.h>
#include "iphone_input.h"
#include "game.h"

const float max_velocity = 1000.0f;
const int max_vel = 80;

int centerView = 0;
int verticalAimScale = 1;

iphone_input_t iphone_input = { 0 };

static NSDate *start = nil;
static double lasttime;
static float mouse_x = 0, mouse_y = 0;
static CGPoint sensitivity = { 1, 1 };
static CGPoint stick_aim_speed = { 300, 300 };
static CGPoint stick_aim_sensitivity = { 1, 1 };

void iphone_setAimSensitivity(float sens_x, float sens_y) {
    sensitivity = CGPointMake(sens_x, sens_y);
    stick_aim_sensitivity = sensitivity;
}

static int clamp(int v, int max, int min) {
    if (v > max) return max;
    if (v < min) return min;
    return v;
}

static float clampf(float v, float max, float min) {
    if (v > max) return max;
    if (v < min) return min;
    return v;
}


void iphone_getinput(SW_PACKET *loc) {
    PLAYERp pp = Player + myconnectindex;
    
    loc->vel = (short) clamp((int)(-max_vel*iphone_input.movestick_y), max_vel, -max_vel);
    loc->svel = (short) clamp((int)(-max_vel*iphone_input.movestick_x), max_vel, -max_vel);
    
    if (start == nil) {
        start = [[NSDate alloc] init];
        lasttime = 0.0;
    }
    
    double actualtime = -[start timeIntervalSinceNow];
    double timedelta = actualtime - lasttime;
    lasttime = actualtime;

    float total_velocity_x = 0;
    float total_velocity_y = 0;
    
    if (timedelta > 0.01) {
        float mouse_dx = iphone_input.freelook_x - mouse_x;
        float mouse_dy = iphone_input.freelook_y - mouse_y;
        mouse_x = iphone_input.freelook_x;
        mouse_y = iphone_input.freelook_y;

        float mouse_vel_x = (float) ((mouse_dx/timedelta) * sensitivity.x);
        float mouse_vel_y = (float) ((mouse_dy/timedelta) * sensitivity.y);


        total_velocity_x += mouse_vel_x;
        total_velocity_y += mouse_vel_y;

    }

    float stick_vel_x = iphone_input.aimstick_x * stick_aim_speed.x * stick_aim_sensitivity.x;
    float stick_vel_y = iphone_input.aimstick_y * stick_aim_speed.y * stick_aim_sensitivity.y;

    total_velocity_x += stick_vel_x;
    total_velocity_y += stick_vel_y;

    float velocity_x = clampf(total_velocity_x, max_velocity, -max_velocity);
    float velocity_y = clampf(total_velocity_y, max_velocity, -max_velocity);

    loc->angvel = (signed char) clamp((int) ((int)128*velocity_x/max_velocity), 127, -127);
    if (!TEST(pp->Flags2, PF2_CAR_LOCK) && !centerView) {
        loc->aimvel = verticalAimScale * (signed char) clamp((int) ((int)-128*velocity_y/max_velocity), 127, -127);
    } else {
        extern int polymost_update_3dview;
        polymost_update_3dview = 1; // set this flag to indicate that we need to regenerate the image on the offscreen rendered tile
        
        centerView = 0;
        pp->horiz = pp->horizbase = 100;
        pp->horizoff = 0;
        loc->aimvel = 0;
        loc->angvel = (signed char) clamp(loc->angvel-loc->svel, 127, -127);
        loc->svel = 0;
    }
}
