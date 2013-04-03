#ifndef SYS_IPHONE_H
#define SYS_IPHONE_H

extern int is_iPad;     // any ipad
extern int is_iPhone;   // iphone5 is not iphone, it's iphone5
extern int is_iPhone5;  // ipod touch 5 is also iphone5
extern int is_hiEnd;    // iphone4s+, ipad2+, ipod touch5+

void Sys_DetectDevice(void);

const char*
Sys_GetResourceDir(void);

const char*
Sys_GetConfigDir(void);

const char*
Sys_ConfigFile(void);

const char*
Sys_GetDocumentsDir(void);

const char*
Sys_GetGameDir(void);

#endif /* SYS_IPHONE_H */
