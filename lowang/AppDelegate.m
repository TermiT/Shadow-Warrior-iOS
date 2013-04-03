#import "AppDelegate.h"
#import "LWGameInstance.h"
#import "MKStoreManager.h"
#include "sys_iphone.h"
#ifdef TESTING
#import "TestFlight.h"
#endif


LWGameInstance *gameInstance;
LWConfig *gameConfig;
AppDelegate *appDelegate;
CGSize screenSize;

@interface AppDelegate ()
@end

@implementation AppDelegate {
}

@synthesize window, gameViewController, gameController;

- (void)initGlobals {
    Sys_DetectDevice();
    gameInstance = [LWGameInstance sharedInstance];
    gameConfig = [LWConfig sharedConfig];
    appDelegate = self;
    CGRect screenBounds = [UIScreen mainScreen].bounds;
    screenSize = CGSizeMake(screenBounds.size.height, screenBounds.size.width);
}

- (void)applicationDidFinishLaunching:(UIApplication *)application {
    #ifdef TESTING
    [TestFlight setDeviceIdentifier:[[UIDevice currentDevice] uniqueIdentifier]];
    #endif
    iphone_initLock();
    [self initGlobals];
    
    [UIApplication sharedApplication].idleTimerDisabled = YES;
    CGRect ios_screen_bounds = [UIScreen mainScreen].bounds;
    
    window = [[UIWindow alloc] initWithFrame:ios_screen_bounds];

    gameController = [[LWGameController alloc] init];
    window.rootViewController = [[[UINavigationController alloc] initWithRootViewController:gameController] autorelease];
    window.rootViewController.navigationController.navigationBar.hidden = YES;
    [gameController release];

    [window makeKeyAndVisible];
    [MKStoreManager sharedManager];
    
    extern int isFullGame;
    isFullGame = (int)[MKStoreManager isFeaturePurchased:kInAppFullGame];
}


- (void) applicationWillResignActive:(UIApplication *)application {
    [gameController setPaused];
    iphone_lock();
}

- (void) applicationDidBecomeActive:(UIApplication *)application {
    iphone_unlock();
}

- (void)applicationWillTerminate:(UIApplication *)application {
    [gameInstance quit];
}

- (void) dealloc {
    [gameController release];
    [gameViewController release];
    [window release];
    [super dealloc];
}

@end
