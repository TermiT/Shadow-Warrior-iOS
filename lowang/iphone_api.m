//
//  iphone_api.c
//  lowang
//
//  Created by termit on 10/25/12.
//
//

#import <pthread.h>
#include "build.h"
#include "compat.h"
#include "osd.h"

#include "keys.h"
#include "names2.h"
#include "panel.h"
#include "game.h"
#include "tags.h"
#include "sector.h"
#include "sprite.h"
#include "weapon.h"
#include "player.h"
#include "jsector.h"
#include "control.h"
#include "menus.h"
#include "sw_strs.h"
#include "control.h"
#include "pal.h"

#include "function.h"
#include "gamedefs.h"
#include "net.h"
#include "fx_man.h"
#include "music.h"
#include "text.h"
#include "_control.h"

#include "colormap.h"
#include "sounds.h"

#define IPHONE_API_IMPL

#include "LWGameInstance.h"
#include "iphone_api.h"
#include "iphone_input.h"
#import "settings.h"
#import "cd.h"
#import "driver_avplayer.h"

#define IBUTTONSET(x,value) \
(\
((x)>31) ?\
(iphone_ButtonState2 |= (value<<((x)-32)))  :\
(iphone_ButtonState1 |= (value<<(x)))\
)

#define IBUTTONCLEAR(x) \
    (\
    ((x)>31) ?\
    (iphone_ButtonState2 &= (~(1<<((x)-32)))) :\
    (iphone_ButtonState1 &= (~(1<<(x))))\
    )

#define IBUTTON(x) \
( \
((x)>31) ? \
((CONTROL_ButtonState2>>( (x) - 32) ) & 1) :\
((CONTROL_ButtonState1>> (x) ) & 1)          \
)

#define AUTORELEASE(x,value) \
(\
((x)>31) ?\
(iphone_AutoRelease2 |= (value<<((x)-32)))  :\
(iphone_AutoRelease1 |= (value<<(x)))\
)

static uint32  iphone_ButtonState1 = 0;
static uint32  iphone_ButtonState2 = 0;
static uint32  iphone_AutoRelease1 = 0;
static uint32  iphone_AutoRelease2 = 0;

int appSuspended = 0;
int levelLoaded = 0;
int engineStarted = 0;
int gameReloaded = 0;
CFRunLoopRef gameRunLoop = NULL;
game_settings_t iphone_settings = { 0 };

extern BOOL InMenuLevel, LoadGameOutsideMoveLoop, LoadGameFromDemo, QuitFlag;
extern BYTE RedBookSong[40];
extern BOOL ExitLevel, NewGame;
extern short Level, Skill;
extern BOOL MusicInitialized, FxInitialized;

static char savedInvAmount[7] = { 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF };
static BOOL savedInvActive[7] = { 0 };
static short savedInvPercent[7] = { -1, -1, -1, -1, -1, -1, -1 };

static player_info_t player_info = { 0 };
int game_reloading = 0;

int game_type = GAME_SHADOW_WARRIOR;

void iphone_StartGame(short _Level, short _Skill) {
    PLAYERp pp = Player + screenpeek;
    int handle = 0;
    long zero = 0;
    
    // always assumed that a demo is playing
    
    ready2send = 0;
    Skill = _Skill;
    Level = _Level;
    
    ExitMenus();
    DemoPlaying = FALSE;
    ExitLevel = TRUE;
    NewGame = TRUE;
    DemoMode = FALSE;
    CameraTestMode = FALSE;
    
    //InitNewGame();
    
    if(Skill == 0)
        handle = PlaySound(DIGI_TAUNTAI3,&zero,&zero,&zero,v3df_none);
    else
        if(Skill == 1)
            handle = PlaySound(DIGI_NOFEAR,&zero,&zero,&zero,v3df_none);
        else
            if(Skill == 2)
                handle = PlaySound(DIGI_WHOWANTSWANG,&zero,&zero,&zero,v3df_none);
            else
                if(Skill == 3)
                    handle = PlaySound(DIGI_NOPAIN,&zero,&zero,&zero,v3df_none);
    
    if (handle > FX_Ok)
        while(FX_SoundActive(handle))
			handleevents();
    
}

void iphone_initRunLoop() {
    gameRunLoop = CFRunLoopGetCurrent();
}

void iphone_doRunLoop() {
    while (appSuspended) {
        printf("Suspended run loop\n");
        CFRunLoopRunInMode(kCFRunLoopDefaultMode, 0.01, FALSE);
        //usleep(1000);
    }
    while (CFRunLoopRunInMode(kCFRunLoopDefaultMode, 0, FALSE) == kCFRunLoopRunHandledSource);
}

static
void iphone_storePlayerInfo();

void iphone_notifyLevelInitialized(int levelNumber) {
    levelLoaded = 1;
    iphone_storePlayerInfo();
    dispatch_async(dispatch_get_main_queue(), ^{
        [[NSNotificationCenter defaultCenter] postNotificationName:kLWLevelStarted object:@(levelNumber)];
    });
}

void iphone_notifyEngineInitialized() {
    engineStarted = 1;
    if (game_reloading) {
        game_reloading = 0;
    } else {
        static BOOL notified = NO;
        if (!notified) {
            notified = YES;
            dispatch_async(dispatch_get_main_queue(), ^{
                [[NSNotificationCenter defaultCenter] postNotificationName:kLWEngineStarted object:nil];
            });
        }
    }
}

void iphone_notifyPlayerDied(short deathType) {
    iphone_storePlayerInfo();
    dispatch_async(dispatch_get_main_queue(), ^{
        [[NSNotificationCenter defaultCenter] postNotificationName:kLWPlayerDied object:nil];
    });
}

void iphone_notifyLevelLoading(const char *level_name) {
    NSString *ln = [NSString stringWithUTF8String:level_name];
    dispatch_async(dispatch_get_main_queue(), ^{
        [[NSNotificationCenter defaultCenter] postNotificationName:kLWShowInfoMessage object:ln];
    });
}

void iphone_notifyAnimStarted(int anim) {
    dispatch_async(dispatch_get_main_queue(), ^{
        [[NSNotificationCenter defaultCenter] postNotificationName:kLWNotifyAnimStarted object:@(anim)];
    });
}

void iphone_notifyAnimStopped(int anim) {
    dispatch_async(dispatch_get_main_queue(), ^{
        [[NSNotificationCenter defaultCenter] postNotificationName:kLWNotifyAnimStopped object:@(anim)];
    });
}

void iphone_notifyGameOver() {
    levelLoaded = 0;
    dispatch_async(dispatch_get_main_queue(), ^{
        [[NSNotificationCenter defaultCenter] postNotificationName:kLWGameOver object:nil];
    });
}

void iphone_notifySharewareGameOver() {
    levelLoaded = 0;
    dispatch_async(dispatch_get_main_queue(), ^{
        [[NSNotificationCenter defaultCenter] postNotificationName:kLWSharewareGameOver object:nil];
    });
}


void iphone_showInfoMessage(const char *string) {
    NSString *message = [NSString stringWithUTF8String:string];
    iphone_storePlayerInfo();
    dispatch_async(dispatch_get_main_queue(), ^{
        [[NSNotificationCenter defaultCenter] postNotificationName:kLWShowInfoMessage object:message];
    });
}

void iphone_showQuoteMessage(const char *string) {
    NSString *message = [NSString stringWithUTF8String:string];
    iphone_storePlayerInfo();
    dispatch_async(dispatch_get_main_queue(), ^{
        [[NSNotificationCenter defaultCenter] postNotificationName:kLWShowQuoteMessage object:message];
    });
}

static
void iphone_storePlayerInfo() {
    PLAYERp pp = Player+myconnectindex;
    USERp u = User[pp->PlayerSprite];
    player_info_t *pi = &player_info;
    
    pi->health = u->Health;
    pi->armor = pp->Armor;
    memcpy(pi->ammo, pp->WpnAmmo, sizeof(pi->ammo));
    if (pp->Flags & PF_DIVING || pp->Flags & PF_DIVING_IN_LAVA) {
        pi->air = pp->DiveTics;
    } else {
        pi->air = 1440;
    }
    pi->weapon = u->WeaponNum;
    if (pi->weapon == WPN_SWORD) {
        pi->weapon = WPN_FIST;
    }
    if (pi->weapon == WPN_NAPALM || pi->weapon == WPN_RING) {
        pi->weapon = WPN_HOTHEAD;
    }
    if (pi->weapon == WPN_ROCKET) {
        pi->weapon = WPN_MICRO;
    }
    for (int i = 0; i < 10; i++) {
        pi->hasWeapon[i] = TEST(pp->WpnFlags&0xFFFF, BIT(i))?YES:NO;
    }
    
    // TODO: make it thread-safe
    memcpy(pi->invAmount, pp->InventoryAmount, sizeof(pi->invAmount));
    memcpy(pi->invActive, pp->InventoryActive, sizeof(pi->invActive));
    memcpy(pi->invPercent, pp->InventoryPercent, sizeof(pi->invPercent));
    memcpy(pi->hasKey, pp->HasKey, sizeof(pi->hasKey));
}

void iphone_notifyPlayerInfoChanged(int flags) {    
    if (flags == PI_INVENTORY) {
        PLAYERp pp = Player+myconnectindex;
        if (memcmp(&pp->InventoryActive[0], &savedInvActive[0], sizeof(savedInvActive)) == 0 &&
            memcmp(&pp->InventoryPercent[0], &savedInvPercent[0], sizeof(savedInvPercent)) == 0 &&
            memcmp(&pp->InventoryAmount[0], &savedInvAmount[0], sizeof(savedInvAmount)) == 0) {
                return;
            } else {
                memcpy(&savedInvActive[0], &pp->InventoryActive[0], sizeof(savedInvActive));
                memcpy(&savedInvPercent[0], &pp->InventoryPercent[0], sizeof(savedInvPercent));
                memcpy(&savedInvAmount[0], &pp->InventoryAmount[0], sizeof(savedInvAmount));
            }
    }
    
    NSNumber *nflags = [NSNumber numberWithInt:flags];
    iphone_storePlayerInfo();
    dispatch_async(dispatch_get_main_queue(), ^{
        [[NSNotificationCenter defaultCenter] postNotificationName:kLWPlayerInfoChanged object:nflags];
    });
}

void iphone_notifySavegameLoaded() {
    iphone_storePlayerInfo();
    dispatch_async(dispatch_get_main_queue(), ^{
        [[NSNotificationCenter defaultCenter] postNotificationName:kLWSavegameLoaded object:nil];
    });
}

void iphone_notifyIntermissionStart(intermission_info_t *info) {
    NSData *data = [NSData dataWithBytes:(void*)info length:sizeof(*info)];
    dispatch_async(dispatch_get_main_queue(), ^{
        [[NSNotificationCenter defaultCenter] postNotificationName:kLWNotifyIntermissionStart object:data];
    });
}

void iphone_notifyIntermissionStop() {
    dispatch_async(dispatch_get_main_queue(), ^{
        [[NSNotificationCenter defaultCenter] postNotificationName:kLWNotifyIntermissionStop object:nil];
    });
}

void iphone_notifyBossMeterChanged(int meter) {
    static int oldMeter = 0;
    if (oldMeter != meter) {
        oldMeter = meter;
        dispatch_async(dispatch_get_main_queue(), ^{
            printf("*** Boss Meter: %d ***\n", meter);
            [[NSNotificationCenter defaultCenter] postNotificationName:kLWBossMeterChanged object:@((float)meter/30.0f)];
        });
    }
}

int  iphone_isPlayerAlive() {
    PLAYERp pp = Player+myconnectindex;
    return !TEST(pp->Flags, PF_DEAD);
}

void iphone_getPlayerInfo(player_info_t *pi) {
    *pi = player_info;
}

void iphone_restartLevel() {
    PLAYERp pp = Player+myconnectindex;
    VOID DoRestart(PLAYERp pp);
    DoRestart(pp);
}

void iphone_saveGame(short num) {
    PauseAction();
    SaveGame(num);
    ResumeAction();
    iphone_showInfoMessage("Game Saved");
}
void iphone_loadGame(short load_num) {
    
    if (InMenuLevel || DemoMode || DemoPlaying)
    {
//        LoadSaveMsg("Loading...");
        
        if (LoadGame(load_num) == -1)
            return;
        
        ExitMenus();
        ExitLevel = TRUE;
        LoadGameOutsideMoveLoop = TRUE;
        if (DemoMode || DemoPlaying)
            LoadGameFromDemo = TRUE;
        return;
    }
    
//    LoadSaveMsg("Loading...");
    
    PauseAction();
    
    if (LoadGame(load_num) == -1)
    {

        ResumeAction();
        return;
    }

    iphone_notifySavegameLoaded();
    ready2send = 1;
    ExitMenus();
    
    if (DemoMode)
    {
        ExitLevel = TRUE;
        DemoPlaying = FALSE;
    }
    iphone_storePlayerInfo();
}

void iphone_setButton(int button) {
    IBUTTONSET(button, 1);
}

void iphone_resetButton(int button) {
    IBUTTONCLEAR(button);
}

void iphone_setButtonState() {
    CONTROL_ButtonState1 |= iphone_ButtonState1;
    CONTROL_ButtonState2 |= iphone_ButtonState2;

    iphone_ButtonState1 &= ~iphone_AutoRelease1;
    iphone_ButtonState2 &= ~iphone_AutoRelease2;

    iphone_AutoRelease1 = iphone_AutoRelease2 = 0;
}

void iphone_AutoreleaseButton(int button) {
    AUTORELEASE(button, 1);
}

BOOL iphone_buttonPressed(unsigned int num) {
    return IBUTTON(num)?YES:NO;
}

void iphone_setJoyButton(int index) {
    joyb |= (1 << index);
}

VOID ResCheatOn(PLAYERp pp, char *cheat_string);
VOID RestartCheat(PLAYERp pp, char *cheat_string);
VOID RoomCheat(PLAYERp pp, char *cheat_string);
VOID SecretCheat(PLAYERp pp, char *cheat_string);
VOID MapCheat(PLAYERp pp, char *cheat_string);
VOID LocCheat(PLAYERp pp, char *cheat_string);
VOID WeaponCheat(PLAYERp pp, char *cheat_string);
VOID GodCheat(PLAYERp pp, char *cheat_string);
VOID ClipCheat(PLAYERp pp, char *cheat_string);
VOID WarpCheat(PLAYERp pp, char *cheat_string);
VOID ItemCheat(PLAYERp pp, char *cheat_string);
VOID NextCheat(PLAYERp pp, char *cheat_string);
VOID PrevCheat(PLAYERp pp, char *cheat_string);
VOID CON_Bunny(void);
void BunnyCheat( void );

    void iphone_godMode() {
    CFRunLoopPerformBlock(gameRunLoop, (CFTypeRef) kCFRunLoopCommonModes, ^{
        GodCheat(Player+myconnectindex, "");
    });
}

void iphone_giveAll() {
    CFRunLoopPerformBlock(gameRunLoop, (CFTypeRef) kCFRunLoopCommonModes, ^{
        WeaponCheat(Player+myconnectindex, "");
        ItemCheat(Player+myconnectindex, "");
    });
}

void iphone_endLevel() {
    CFRunLoopPerformBlock(gameRunLoop, (CFTypeRef) kCFRunLoopCommonModes, ^{
        NextCheat(Player+myconnectindex, "");
    });
}

void iphone_quitIntermission() {
    extern int BonusDone;
    BonusDone = 1;
}

void iphone_noclip() {
    CFRunLoopPerformBlock(gameRunLoop, (CFTypeRef) kCFRunLoopCommonModes, ^{
        ClipCheat(Player+myconnectindex, "");
    });
}

void iphone_bunnyRocket() {
    CFRunLoopPerformBlock(gameRunLoop, (CFTypeRef) kCFRunLoopCommonModes, ^{
        BunnyCheat();
    });
}

void iphone_enableMusic(BOOL enable) {
    BOOL bak;
    extern char LevelSong[];
        
    if (engineStarted) {
        if (enable) {
            bak = DemoMode;
            PlaySong(LevelSong, RedBookSong[Level], TRUE, TRUE);
            DemoMode = bak;
        }
        else
        {
            bak = DemoMode;
            StopSong();
            DemoMode = bak;
        }
    } else {
        if (enable) {
            if (!AVPlayer_CD_IsPlaying()) {
                AVPlayer_CD_Play(2, 1);
            }
        } else {
            AVPlayer_CD_Stop();
        }
    }
}

void iphone_overrideSetup() {
    static BOOL first_time = YES;
    extern long gltexfiltermode;

    long newfiltermode = iphone_settings.retro ? 2 : 5;

    BOOL updateMusicState = gs.MusicOn != iphone_settings.music || first_time;
    BOOL updateTextureFilter = newfiltermode != gltexfiltermode;
    
    gs.MusicOn = iphone_settings.music ? 1:0;
    gs.Crosshair = iphone_settings.crosshair;
    
    gs.AutoAim = !iphone_settings.verticalaim;

    gs.Voxels = iphone_settings.voxels ? 1:0;
    gltexfiltermode = iphone_settings.retro ? 2 : 5;
    gs.AutoWeaponSwitch = iphone_settings.autowepswitch;
    
    if (levelLoaded) {
        if (gs.AutoAim)
            SET(Player[myconnectindex].Flags, PF_AUTO_AIM);
        else
            RESET(Player[myconnectindex].Flags, PF_AUTO_AIM);
    }
    
    if (iphone_settings.verticalaim) {
        if (iphone_settings.invertyaxis) {
            verticalAimScale = -1;
        } else {
            verticalAimScale = 1;
        }
        centerView = 0;
    } else {
        centerView = 1;
        verticalAimScale = 0;
    }
    
    if (updateMusicState) {
        iphone_enableMusic(iphone_settings.music);
    }
    if (updateTextureFilter) {
        void gltexapplyprops (void);
        gltexapplyprops();
    }
    
    first_time = NO;
}

void iphone_setGameSettings(game_settings_t *settings) {
    if (engineStarted) {
        memcpy(&iphone_settings, settings, sizeof(iphone_settings));
//        NSData *data = [NSData dataWithBytes:&settings length:sizeof(game_settings_t)];
        CFRunLoopPerformBlock(gameRunLoop, (CFTypeRef) kCFRunLoopCommonModes, ^{
//            memcpy(&iphone_settings, data.bytes, sizeof(iphone_settings));
            iphone_overrideSetup();
        });
    } else {
        memcpy(&iphone_settings, settings, sizeof(iphone_settings));
        iphone_overrideSetup();
    }
}

static pthread_mutex_t screen_mutex;

void iphone_initLock() {
    pthread_mutex_init(&screen_mutex, NULL);
}

void iphone_lock() {
    pthread_mutex_lock(&screen_mutex);
}

void iphone_unlock() {
    pthread_mutex_unlock(&screen_mutex);
}

void iphone_setPaused(int paused) {
    extern BOOL GamePaused;
    if (GamePaused != paused) {
        CFRunLoopPerformBlock(gameRunLoop, (CFTypeRef) kCFRunLoopCommonModes, ^{
            GamePaused = paused?1:0;
            if (GamePaused) {
                PauseAction();
            } else {
                ResumeAction();
            }
        });
    }
}

BOOL iphone_changeGameType(int gt) {
    extern char quitevent;
    
    if (gt != game_type) {
        game_type = gt;
        quitevent = 1;
        
        game_reloading = 1;
        
        return TRUE;
    }
    return FALSE;
}
