//
//  iphone_api.h
//  lowang
//
//  Created by termit on 10/25/12.
//
//

#ifndef lowang_iphone_api_h
#define lowang_iphone_api_h

#ifdef __OBJC__
extern CFRunLoopRef gameRunLoop;
#endif

struct game_settings_s {
    BOOL crosshair;
    BOOL music;
    BOOL verticalaim;
    BOOL invertyaxis;
    BOOL voxels;
    BOOL retro;
    BOOL autowepswitch;
};

typedef struct game_settings_s game_settings_t;

struct player_info_s {
    int health;
    int armor;
    int weapon;
    short ammo[14];
    int air;
    char hasKey[8];
    char invAmount[7];
    BOOL invActive[7];
    short invPercent[7];
    BOOL hasWeapon[10];
};

typedef struct player_info_s player_info_t;

struct intermission_info_s {
    char map_name[80];
    char user_time[16];
    char best_time[16];
    char par_time[16];
    int level_secrets, found_secrets;
    int kills, total_killable;
};

typedef struct intermission_info_s intermission_info_t;

enum {
    PI_HEALTH = 1,
    PI_ARMOR = 2,
    PI_AMMO = 4,
    PI_AIR = 8,
    PI_WEAPON = 16,
    PI_KEYS = 32,
    PI_INVENTORY = 64,
};

enum {
    GAME_SHADOW_WARRIOR = 0,
    GAME_TWIN_DRAGON = 1,
    GAME_WANTON_DESTRUCTION = 2,
    GAME_QUIT = 999
};

extern int game_type;

extern game_settings_t iphone_settings;
extern int appSuspended;
extern int levelLoaded;
extern int engineStarted;
extern int game_reloading;

int isFullGame;

void iphone_StartGame(short _Level, short _Skill);
void iphone_notifyLevelInitialized(int levelNumber);
void iphone_notifyEngineInitialized();
void iphone_notifyPlayerDied(short deathType);
void iphone_notifyLevelLoading(const char *level_name);
void iphone_notifyPlayerInfoChanged(int flags);
void iphone_notifySavegameLoaded();
void iphone_notifyIntermissionStart(intermission_info_t *info);
void iphone_notifyIntermissionStop();
void iphone_notifyAnimStarted(int anim);
void iphone_notifyAnimStopped(int anim);
void iphone_notifyBossMeterChanged(int meter);
void iphone_notifyGameOver();
void iphone_notifySharewareGameOver();

void iphone_showInfoMessage(const char *string);
int  iphone_isPlayerAlive();
void iphone_restartLevel();
void iphone_saveGame(short num);
void iphone_loadGame(short num);
void iphone_getPlayerInfo(player_info_t *pi);
void iphone_showQuoteMessage(const char *string);
void iphone_setButton(int button);
void iphone_resetButton(int button);
void iphone_AutoreleaseButton(int button);

void iphone_setButtonState();
BOOL iphone_buttonPressed(unsigned int num);
void iphone_setJoyButton(int index);

void iphone_godMode();
void iphone_giveAll();
void iphone_noclip();
void iphone_bunnyRocket();
void iphone_endLevel();
void iphone_quitIntermission();

void iphone_setGameSettings(game_settings_t *settings);
void iphone_enableMusic(BOOL enable);

void iphone_overrideSetup();

void iphone_initLock();

void iphone_lock();
void iphone_unlock();

void iphone_setPaused(int paused);
BOOL iphone_changeGameType(int gt);

#endif
