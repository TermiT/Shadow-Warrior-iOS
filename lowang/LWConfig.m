//
// Created by serge on 10/11/12.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import "LWConfig.h"
#include "sys_iphone.h"
#import "NSDictionary+Merge.h"

static LWConfig *sharedConfig = nil;

static
NSString* schemeKey(NSString *schemeName) {
    return [NSString stringWithFormat:@"controls.scheme.%@", schemeName];
}

@implementation LWConfig {
}

+ (LWConfig *)sharedConfig {
    if (sharedConfig == nil) {
        sharedConfig = [[LWConfig alloc] init];
        [sharedConfig registerDefaults];
    }
    return sharedConfig;
}

- (id) init {
    if ((self = [super init]) != nil) {
        
    }
    return self;
}

- (NSString*)deviceIndependedDefaultConfigPath {
    return [[NSBundle mainBundle] pathForResource:@"defaultConfig" ofType:@"plist"];
}

- (NSString*)deviceDependedDefaultConfigPath {
    if (IS_IPAD()) {
        return [[NSBundle mainBundle] pathForResource:@"defaultConfig-iPad" ofType:@"plist"];
    }
    if (is_iPhone5) {
        return [[NSBundle mainBundle] pathForResource:@"defaultConfig-iPhone5" ofType:@"plist"];
    };
    return [[NSBundle mainBundle] pathForResource:@"defaultConfig-iPhone" ofType:@"plist"];
}

- (void) resetControls {
    [self setSchemeConfig:@"Classic" config:nil];
    [self setSchemeConfig:@"ScreenTap" config:nil];
    [self setSchemeConfig:@"VirtualSticks" config:nil];
}

- (void)registerDefaults {
    NSDictionary *di_def = [NSDictionary dictionaryWithContentsOfFile:[self deviceIndependedDefaultConfigPath]];
    NSDictionary *dd_def =[NSDictionary dictionaryWithContentsOfFile:[self deviceDependedDefaultConfigPath]];
    [[NSUserDefaults standardUserDefaults] registerDefaults:[NSDictionary dictionaryByMerging:di_def with:dd_def]];
}

- (BOOL)leftHandedControls {
    return [[NSUserDefaults standardUserDefaults] boolForKey:@"controls.lefthanded"];
}

- (void)setLeftHandedControls:(BOOL)leftHandedControls {
    [[NSUserDefaults standardUserDefaults] setBool:leftHandedControls forKey:@"controls.lefthanded"];
    [self sync];
}

- (BOOL)invertYAxis {
    return [[NSUserDefaults standardUserDefaults] boolForKey:@"controls.invertyaxis"];
}

- (void)setInvertYAxis:(BOOL)invertYAxis {
    [[NSUserDefaults standardUserDefaults] setBool:invertYAxis forKey:@"controls.invertyaxis"];
    [self sync];
}

- (NSString *)controlScheme {
    return [[NSUserDefaults standardUserDefaults] objectForKey:@"controls.scheme"];
}

- (float)aimSensitivity {
    return [[NSUserDefaults standardUserDefaults] floatForKey:@"controls.aimsensitivity"];
}

- (void)setAimSensitivity:(float)aimSensitivity {
    [[NSUserDefaults standardUserDefaults] setFloat:aimSensitivity forKey:@"controls.aimsensitivity"];
    [self sync];
}

- (int)saveGameType {
    return [[NSUserDefaults standardUserDefaults] integerForKey:@"game.save.gametype"];
}

- (void)setSaveGameType:(int)saveGameType {
    [[NSUserDefaults standardUserDefaults] setInteger:saveGameType forKey:@"game.save.gametype"];
    [self sync];
}

- (int)lastLevel {
    return [[NSUserDefaults standardUserDefaults] integerForKey:@"game.lastlevel"];
}

- (float)hudTransparency {
    return [[NSUserDefaults standardUserDefaults] floatForKey:@"game.hudtransparency"];
}

- (void)setHudTransparency:(float)hudTransparency {
    [[NSUserDefaults standardUserDefaults] setFloat:hudTransparency forKey:@"game.hudtransparency"];
    [self sync];
}

- (BOOL)enableMusic {
    return [[NSUserDefaults standardUserDefaults] boolForKey:@"music.enable"];
}

- (void)setEnableMusic:(BOOL)enableMusic {
    [[NSUserDefaults standardUserDefaults] setBool:enableMusic forKey:@"music.enable"];
    [self sync];
}

- (BOOL)enableCrosshair {
    return [[NSUserDefaults standardUserDefaults] boolForKey:@"game.crosshair"];
}

- (BOOL)enableVoxels {
    return [[NSUserDefaults standardUserDefaults] boolForKey:@"video.voxels"];
}

- (void)setEnableVoxels:(BOOL)enableVoxels {
    [[NSUserDefaults standardUserDefaults] setBool:enableVoxels forKey:@"video.voxels"];
    [self sync];
}

- (BOOL)enableRetroGraphics {
    return [[NSUserDefaults standardUserDefaults] boolForKey:@"video.retrographics"];
}

- (void)setEnableRetroGraphics:(BOOL)enableRetroGraphics {
    [[NSUserDefaults standardUserDefaults] setBool:enableRetroGraphics forKey:@"video.retrographics"];
    [self sync];
}

- (BOOL)enableWeaponAutoSwitch {
    return [[NSUserDefaults standardUserDefaults] boolForKey:@"game.weaponautoswitch"];
}

- (void)setEnableWeaponAutoSwitch:(BOOL)enableWeaponAutoSwitch {
    [[NSUserDefaults standardUserDefaults] setBool:enableWeaponAutoSwitch forKey:@"game.weaponautoswitch"];
    [self sync];
}


- (void)setEnableCrosshair:(BOOL)enableCrosshair {
    [[NSUserDefaults standardUserDefaults] setBool:enableCrosshair forKey:@"game.crosshair"];
    [self sync];
}

- (BOOL)enableVerticalAim {
    return [[NSUserDefaults standardUserDefaults] boolForKey:@"controls.verticalaim"];
}

- (void)setEnableVerticalAim:(BOOL)enableVerticalAim {
    [[NSUserDefaults standardUserDefaults] setBool:enableVerticalAim forKey:@"controls.verticalaim"];
    [self sync];
}

- (NSDictionary *)schemeConfig:(NSString *)schemeName {
    NSDictionary *cfg = [[NSUserDefaults standardUserDefaults] objectForKey:schemeKey(schemeName)];
    return cfg;
}

- (void)setSchemeConfig:(NSString *)schemeName config:(NSDictionary *)config {
    [[NSUserDefaults standardUserDefaults] setObject:config forKey:schemeKey(schemeName)];
    [self sync];
}


- (void)setControlScheme:(NSString *)controlScheme {
    [[NSUserDefaults standardUserDefaults] setObject:controlScheme forKey:@"controls.scheme"];
    [self sync];
}

- (void)dealloc {
    [super dealloc];
}

- (void)sync {
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)dumpSettings {
    NSString *path = [NSString stringWithFormat:@"%s/settings.plist", Sys_GetDocumentsDir()];
    [[[NSUserDefaults standardUserDefaults] dictionaryRepresentation] writeToFile:path atomically:NO];
    NSLog(@"Config file saved to %@", path);
}

@end
