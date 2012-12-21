//
// Created by serge on 10/11/12.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import <Foundation/Foundation.h>

extern int is_iPad;     // any ipad
extern int is_iPhone;   // iphone5 is not iphone, it's iphone5
extern int is_iPhone5;  // ipod touch 5 is also iphone5
extern int is_hiEnd;    // iphone4s+, ipad2+, ipod touch5+

void detectDevice(void);

@interface LWConfig : NSObject

+ (LWConfig *)sharedConfig;

- (void)sync;

@property (nonatomic, assign) BOOL leftHandedControls;
@property (nonatomic, assign) BOOL invertYAxis;
@property (nonatomic, retain) NSString *controlScheme;
@property (nonatomic, assign) float aimSensitivity;
@property (nonatomic, assign) int lastLevel;
@property (nonatomic, assign) float hudTransparency;
@property (nonatomic, assign) BOOL enableMusic;
@property (nonatomic, assign) BOOL enableCrosshair;
@property (nonatomic, assign) BOOL enableVerticalAim;
@property (nonatomic, assign) BOOL enableVoxels;
@property (nonatomic, assign) BOOL enableRetroGraphics;
@property (nonatomic, assign) BOOL enableWeaponAutoSwitch;

- (NSDictionary *)schemeConfig:(NSString *)schemeName;
- (void)setSchemeConfig:(NSString *)schemeName config:(NSDictionary *)config;

- (void)registerDefaults;

- (void)dumpSettings;
@end