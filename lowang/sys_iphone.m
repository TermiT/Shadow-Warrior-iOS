#import <UIKit/UIKit.h>
#include <string.h>
#include <sys/types.h>
#include <sys/sysctl.h>
#include <sys/utsname.h>
#include "iphone_api.h"

#define MAX_PATH 1024

const char* Sys_GetResourceDir(void) {
    static char data[MAX_PATH] = { 0 };
    
    NSString * path = [[NSBundle mainBundle].bundlePath stringByAppendingPathComponent:@"gamedata"];
    if (!data[0]) {
        strcpy(data, path.UTF8String);
    }
    return data;
}

const char* Sys_GetGameDir(void) {
    switch (game_type) {
        case GAME_WANTON_DESTRUCTION:
            return NULL;
        case GAME_TWIN_DRAGON:
            return NULL;
        default:
            break;
    }
    return NULL;
}

const char* Sys_GetConfigDir(void) {
    static char data[MAX_PATH] = { 0 };
    if (!data[0]) {

    }
    return data;
}

const char* Sys_ConfigFile(void) {
    static char data[MAX_PATH] = { 0 };
    if (!data[0]) {
        strcpy(data, Sys_GetResourceDir());
        strcat(data, "/sw.cfg");
    }
    return data;
}

const char* Sys_GetDocumentsDir(void) {
    static char data[MAX_PATH] = { 0 };
    if (!data[0]) {
        NSString *basePath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
        strcpy(data, basePath.UTF8String);
    }
    return data;
}

int is_iPad = 0;     // any ipad
int is_iPhone = 0;   // iphone5 is not iphone, it's iphone5
int is_iPhone5 = 0;  // ipod touch 5 is also iphone5
int is_hiEnd = 0;    // iphone4s+, ipad2+, ipod touch5+

void Sys_DetectDevice(void) {
    size_t size;
    struct utsname un;

    uname(&un);
    
    char *machine = &un.machine[0];
    
    if (!strncmp("iPhone3", machine, 7)) {
        is_iPhone = 1;
        return;
    }

    if (!strncmp("iPhone4", machine, 7)) {
        is_iPhone = 1;
        is_hiEnd = 1;
        return;
    }

    if (!strncmp("iPhone5", machine, 7) || !strncmp("iPod5", machine, 5)) {
        is_iPhone5 = 1;
        is_hiEnd = 1;
        return;
    }
    
    if (!strncmp("iPad1", machine, 5)) {
        is_iPad = 1;
        return;
    }
    
    if (!strncmp("iPad2", machine, 5) || !strncmp("iPad3", machine, 5)) {
        is_iPad = 1;
        is_hiEnd = 1;
        return;
    }
    
    if (!strncmp("iPod", machine, 4)) {
        is_iPhone = 1;
        return;
    }
    
#if TARGET_IPHONE_SIMULATOR
    int screensize = (int) [[UIScreen mainScreen] bounds].size.height;
    is_iPhone5 = screensize == 568;
    is_iPad = screensize == 1024;
    if (!is_iPhone5 && !is_iPad) {
        is_iPhone = 1;
    }
    is_hiEnd = 1;
    return;
#endif
    
    is_iPhone = 1; // unknown device, fallback to iphone mode
    return;
}
