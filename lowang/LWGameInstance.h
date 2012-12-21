//
//  LWGameInstance.h
//  lowang
//
//  Created by termit on 10/25/12.
//
//

#import <Foundation/Foundation.h>
#include "iphone_api.h"
#include "function.h"

#define kLWLevelStarted @"kLWLevelStarted"
#define kLWEngineStarted @"kLWEngineStarted"
#define kLWPlayerDied @"kLWPlayerDied"
#define kLWShowInfoMessage @"kLWShowInfoMessage"
#define kLWShowQuoteMessage @"kLWShowQuoteMessage"
#define kLWLevelLoading @"kLWLevelLoading"
#define kLWPlayerInfoChanged @"kLWPlayerInfoChanged"
#define kLWSavegameLoaded @"kLWSavegameLoaded"
#define kLWNotifyIntermissionStart @"kLWNotifyIntermissionStart"
#define kLWNotifyIntermissionStop @"kLWNotifyIntermissionStop"
#define kLWNotifyAnimStarted @"kLWNotifyAnimStarted"
#define kLWNotifyAnimStopped @"kLWNotifyAnimStopped"
#define kLWBossMeterChanged @"kLWBossMeterChanged"
#define kLWGameOver @"kLWGameOver"
#define kLWSharewareGameOver @"kLWSharewareGameOver"

#ifndef IPHONE_API_IMPL

enum {
    WPN_FIST = 0,
    WPN_STAR,
    WPN_SHOTGUN,
    WPN_UZI,
    WPN_MICRO,
    WPN_GRENADE,
    WPN_MINE,
    WPN_RAIL,
    WPN_HOTHEAD,
    WPN_HEART,
    
    WPN_NAPALM,
    WPN_RING,
    WPN_ROCKET,
    WPN_SWORD,
};

enum InventoryNames
{
    INVENTORY_MEDKIT,
    INVENTORY_REPAIR_KIT,
    INVENTORY_CLOAK,        // de-cloak when firing
    INVENTORY_NIGHT_VISION,
    INVENTORY_CHEMBOMB,
    INVENTORY_FLASHBOMB,
    INVENTORY_CALTROPS,
    MAX_INVENTORY
};

#endif

@interface LWGameInstance : NSObject

+ (LWGameInstance*)sharedInstance;

- (BOOL)paused;
- (void)setPaused:(BOOL)paused;

- (BOOL)suspended;
- (void)setSuspended:(BOOL)suspended;

- (void)startEngine;
- (void)startGame:(int)levelno skill:(int)skill;
- (void)quit;

- (BOOL)isLevelLoaded;
- (BOOL)isPlayerAlive;

- (void)restartLevel;

- (void)saveGame:(short)num;
- (void)loadGame:(short)num;

- (BOOL)isAutoSaveSlotAvailable;
- (BOOL)isSaveSlotAvailable;

- (player_info_t *)playerInfo;

- (void)setButton:(int)button;
- (void)resetButton:(int)button;
- (void)setButton:(int)button value:(BOOL)value;

- (void)autoreleaseButton:(int)button;

- (void)setMoveStick:(CGPoint)value;

- (void)setAimStick:(CGPoint)value;

- (void)setFreelookMove:(CGPoint)offset;

- (void)giveAll;

- (void)godMode;

- (void)noclip;

- (void) bunnyRocket;

- (void)endLevel;

- (void)setAimSensitivity:(float)sens;

- (void)quitIntermission;

- (void)updateGameSettings;

- (void)toggleMap;

- (void)setGameType:(int)game_type1;


@property (nonatomic, assign) long textureFilterMode;

@end
