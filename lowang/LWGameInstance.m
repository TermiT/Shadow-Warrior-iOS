//
//  LWGameInstance.m
//  lowang
//
//  Created by termit on 10/25/12.
//
//

#import "LWGameInstance.h"
#include "iphone_api.h"
#include "sys_iphone.h"
#include "iphone_input.h"
#import "build.h"

static LWGameInstance *instance = nil;

extern void GameThread_Run(void);

#pragma mark - LWGameInstance implementation

@implementation LWGameInstance {

}

+ (LWGameInstance*)sharedInstance {
    if (instance == nil) {
        instance = [[LWGameInstance alloc] init];
    }
    return instance;
}

- (id) init {
    if ((self = [super init]) != nil) {
    }
    return self;
}

- (void) startEngine {
    GameThread_Run();
}

- (BOOL)paused {
    extern BOOL GamePaused;
    return GamePaused;
}

- (void)setPaused:(BOOL)paused {
    iphone_setPaused(paused);
}

- (BOOL)suspended {
    return (BOOL) appSuspended;
}

- (void)setSuspended:(BOOL)suspended {
    self.paused = suspended;
    appSuspended = suspended;
    void CoreAudioDrv_PCM_ResumePlayback(void);
    void CoreAudioDrv_PCM_StopPlayback(void);
    void CoreAudioDrv_PCM_SetVolume(float);
    if (appSuspended) {
//        CoreAudioDrv_PCM_StopPlayback();
        CoreAudioDrv_PCM_SetVolume(0.0f);
    } else {
//        CoreAudioDrv_PCM_ResumePlayback();
        CoreAudioDrv_PCM_SetVolume(1.0f);
    }
}

- (void)quit {

}


- (void)startGame:(int)levelno skill:(int)skill {
    CFRunLoopPerformBlock(gameRunLoop, (CFTypeRef) kCFRunLoopCommonModes,
                          ^{
                              iphone_StartGame((short) levelno, (short) skill);
                          });
}

- (BOOL)isLevelLoaded {
    return (BOOL) levelLoaded;
}

- (BOOL)isPlayerAlive {
    return (BOOL) iphone_isPlayerAlive();
}

- (void)restartLevel {
    CFRunLoopPerformBlock(gameRunLoop, (CFTypeRef) kCFRunLoopCommonModes,
                          ^{
                              iphone_restartLevel();
                          });
}

- (void)saveGame:(short)num {
    CFRunLoopPerformBlock(gameRunLoop, (CFTypeRef) kCFRunLoopCommonModes,
                          ^{
                              iphone_saveGame(num);
                          });
}

- (void)loadGame:(short)num {
    CFRunLoopPerformBlock(gameRunLoop, (CFTypeRef) kCFRunLoopCommonModes,
                          ^{
                              iphone_loadGame(num);
                          });
}

- (BOOL)isAutoSaveSlotAvailable {
    NSString *path = [NSString stringWithFormat:@"%s/game%d.sav", Sys_GetDocumentsDir(), 0];
    return [[NSFileManager defaultManager] fileExistsAtPath:path];
}

- (BOOL)isSaveSlotAvailable {
    NSString *path = [NSString stringWithFormat:@"%s/game%d.sav", Sys_GetDocumentsDir(), 0];
    return [[NSFileManager defaultManager] fileExistsAtPath:path];
}

- (player_info_t *)playerInfo {
    static player_info_t p;
    iphone_getPlayerInfo(&p);
    return &p;
}

- (void)setButton:(int)button {
    iphone_setButton(button);
}

- (void)resetButton:(int) button {
    iphone_resetButton(button);
}

- (void)setButton:(int)button value:(BOOL)value {
    if (value) {
        iphone_setButton(button);
    } else {
        iphone_resetButton(button);
    }
}

- (void)autoreleaseButton:(int)button {
    iphone_AutoreleaseButton(button);
}

- (void) setMoveStick:(CGPoint)value {
    iphone_input.movestick_x = value.x;
    iphone_input.movestick_y = value.y;
}

- (void) setAimStick:(CGPoint)value {
    iphone_input.aimstick_x = value.x;
    iphone_input.aimstick_y = value.y;
}

- (void) setFreelookMove:(CGPoint)offset {
    iphone_input.freelook_x += offset.x;
    iphone_input.freelook_y += offset.y;
}

- (void) giveAll {
    iphone_giveAll();
}

- (void) bunnyRocket {
    iphone_bunnyRocket();
}

- (void) godMode {
    iphone_godMode();
}

- (void)noclip {
    iphone_noclip();
}

- (void)endLevel {
    iphone_endLevel();
}

- (void) setAimSensitivity:(float) sens {
    iphone_setAimSensitivity(sens, sens);
}

- (void)quitIntermission {
    iphone_quitIntermission();
}

- (void)updateGameSettings {
    game_settings_t settings;
    settings.music = gameConfig.enableMusic ? 1 : 0;
    settings.crosshair = gameConfig.enableCrosshair ? 1 : 0;
    settings.verticalaim = gameConfig.enableVerticalAim ? 1 : 0;
    settings.invertyaxis = gameConfig.invertYAxis;
    settings.voxels = gameConfig.enableVoxels;
    settings.retro = gameConfig.enableRetroGraphics;
    settings.autowepswitch = gameConfig.enableWeaponAutoSwitch;

    iphone_setGameSettings(&settings);
}

- (void)toggleMap {
    iphone_setButton(gamefunc_Map);
    iphone_AutoreleaseButton(gamefunc_Map);
}

extern long gltexfiltermode;

- (long)textureFilterMode {
    return gltexfiltermode;
}

void gltexapplyprops (void);

- (void)setTextureFilterMode:(long)textureFilterMode {
    CFRunLoopPerformBlock(gameRunLoop, (CFTypeRef) kCFRunLoopCommonModes,
            ^{
                gltexfiltermode = textureFilterMode;
                gltexapplyprops();
            });
}

- (void)setGameType:(int)game_type {
    if (iphone_changeGameType(game_type)) {
//        CFRunLoopRunInMode(kCFRunLoopDefaultMode, 15.0, FALSE);
        // remove next line later
        gameConfig.enableVoxels = NO;
        [self updateGameSettings];
        [self waitForReload];
    }
}

static void
runLoopDelay(NSTimeInterval delay) {
    [[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:delay]];
}

- (void)waitForReload {
    while (game_reloading) {
        CFRunLoopRunInMode(kCFRunLoopDefaultMode, 1.0, FALSE);
    }
}

@end
