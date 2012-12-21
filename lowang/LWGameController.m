//
//  MenuViewController.m
//  lowang
//
//  Created by termit on 10/23/12.
//
//

#import <AVFoundation/AVFoundation.h>
#import "LWSettingsMenu.h"
#import "LWMainMenu.h"
#import "LWGameInstance.h"
#import "EAGLView.h"
#import "driver_avplayer.h"
#import "LWLevelSelectMenu.h"
#import "LWSkillSelectMenu.h"
#import "LWLoadingView.h"
#import "LWHardcodedScheme.h"
#import "LWPauseView.h"
#import "LWControlsMenu.h"
#import "LWHud.h"
#import "LWControlSchemeEditorViewController.h"
#import "LWControlSchemeScreenTap.h"
#import "LWControlSchemeClassic.h"
#import "LWControlSchemeVirtualSticks.h"
#import "LWIntermissionView.h"
#import "LWCoolStuffMenu.h"
#import "LWAboutMenu.h"
#import "LWStoreView.h"
#import "MKStoreManager.h"
#import "SVProgressHUD.h"

@interface LWGameController () {
    NSMutableArray *menuStack;
}
@property (retain, nonatomic) IBOutlet UIImageView *menuBackground;

@property (retain, nonatomic) IBOutlet UIImageView *logo3DRealms;
@property (retain, nonatomic) IBOutlet UIImageView *logoGeneralArcade;
@property (retain, nonatomic) IBOutlet LWMainMenu *mainMenu;
@property (retain, nonatomic) IBOutlet LWSettingsMenu *settingsMenu;
@property (retain, nonatomic) IBOutlet UIView *mainMenuView;
@property (retain, nonatomic) IBOutlet EAGLView *eaglView;
@property (retain, nonatomic) IBOutlet LWLevelSelectMenu *levelSelectMenu;
@property (retain, nonatomic) IBOutlet LWSkillSelectMenu *skillSelectMenu;
@property (retain, nonatomic) IBOutlet LWLoadingView *loadingView;
@property (retain, nonatomic) LWControlScheme *controlSchemeView;
@property (retain, nonatomic) IBOutlet LWPauseView *pauseView;
@property (retain, nonatomic) IBOutlet LWControlsMenu *controlsMenu;
@property (retain, nonatomic) IBOutlet UIView *loWangView;
@property (retain, nonatomic) IBOutlet LWHud *hudView;
@property (retain, nonatomic) IBOutlet LWIntermissionView *intermissionView;
@property (retain, nonatomic) IBOutlet UIImageView *swLogo;
@property (retain, nonatomic) IBOutlet LWCoolStuffMenu *coolStuffMenu;
@property (retain, nonatomic) IBOutlet LWAboutMenu *aboutMenu;
@property (retain, nonatomic) IBOutlet LWMenuView *creditsMenu;
@property (retain, nonatomic) IBOutlet LWStoreView *storeView;

@end

@implementation LWGameController {
    int showMenuIfReadyCounter;
    CGRect contentBounds;
}

- (id)init {
    NSString * nibName = @"LWGameController~iPad";
    if (!IS_IPAD()) nibName = is_iPhone5 ? @"LWGameController-iPhone5" : @"LWGameController";
    self = [super initWithNibName:nibName bundle:nil];
    if (self) {
        menuStack = [[NSMutableArray alloc]init];
        showMenuIfReadyCounter = 0;
    }
    return self;    
}

#if ENABLE_DEV_BUTTONS

UIButton*
createDevButton(NSString *title, CGRect frame, id target, SEL sel);

- (void) addDebugButtons {
    CGRect rc = { 10, 10, 160, 40 };

    [self.view addSubview:createDevButton(@"Shadow Warrior", rc, self, @selector(dev_startSW))];

    rc.origin.y += 50;
    [self.view addSubview:createDevButton(@"Twin Dragon", rc, self, @selector(dev_startTD))];

    rc.origin.y += 50;
    [self.view addSubview:createDevButton(@"Wanton Destruction", rc, self, @selector(dev_startWD))];
}

- (void)dev_startWD {
    [gameInstance setGameType:GAME_WANTON_DESTRUCTION];
}

- (void)dev_startTD {
    [gameInstance setGameType:GAME_TWIN_DRAGON];
}

- (void)dev_startSW {
    [gameInstance setGameType:GAME_SHADOW_WARRIOR];
}

#endif

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self reloadSettings];
    [gameInstance updateGameSettings];
    NSLog(@"viewDidLoad: %@", self.view);
    contentBounds = self.view.bounds;
    _controlSchemeView.frame = contentBounds;
    _controlSchemeView.gameController = self;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showMenuIfReady) name:kLWEngineStarted object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(levelStarted:) name:kLWLevelStarted object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(savegameLoaded) name:kLWSavegameLoaded object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playerDied) name:kLWPlayerDied object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showInfoMessage:) name:kLWShowInfoMessage object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(intermissionStarted:) name:kLWNotifyIntermissionStart object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(intermissionStopped) name:kLWNotifyIntermissionStop object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(animationStarted:) name:kLWNotifyAnimStarted object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(animationStopped:) name:kLWNotifyAnimStopped object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onGameOver) name:kLWGameOver object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onSharewareGameOver) name:kLWSharewareGameOver object:nil];

    [self.navigationController setNavigationBarHidden:YES];
    [self.view addSubview:self.eaglView];
    [self.view addSubview:self.mainMenuView];
    [gameInstance startEngine];

    #if ENABLE_DEV_BUTTONS
    [self addDebugButtons];
    #endif
    // Do any additional setup after loading the view from its nib.
}

static
UIImage* makeViewSnapshot(UIView *v) {
    UIImage *r = nil;
    UIGraphicsBeginImageContextWithOptions(v.bounds.size, NO, [UIScreen mainScreen].scale);
    CGContextScaleCTM( UIGraphicsGetCurrentContext(), 1.0f, 1.0f );
    [v.layer renderInContext:UIGraphicsGetCurrentContext()];
    r = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return r;
}

static UIImage*
cutLeftPartOfImage(UIImage *src, CGFloat top, CGFloat bottom) {
    UIImage *r = nil;
    CGSize imageSize = src.size;
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(top>bottom?top:bottom, imageSize.height), NO, [UIScreen mainScreen].scale);
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGContextScaleCTM( ctx, 1.0f, 1.0f );

    CGContextBeginPath(ctx);
    CGContextMoveToPoint(ctx, 0, 0);
    CGContextAddLineToPoint(ctx, top, 0);
    CGContextAddLineToPoint(ctx, bottom, imageSize.height);
    CGContextAddLineToPoint(ctx, 0, imageSize.height);
    CGContextAddLineToPoint(ctx, 0, 0);
    CGContextClosePath(ctx);
    CGContextClip(ctx);

    [src drawAtPoint:CGPointMake(0, 0)];

    r = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return r;
}

static UIImage*
cutRightPartOfImage(UIImage *src, CGFloat top, CGFloat bottom) {
    UIImage *r = nil;
    CGSize imageSize = src.size;
    CGFloat offs = top<bottom?top:bottom;

    UIGraphicsBeginImageContextWithOptions(CGSizeMake(imageSize.width - offs, imageSize.height), NO, [UIScreen mainScreen].scale);
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGContextScaleCTM( ctx, 1.0f, 1.0f );

    CGContextBeginPath(ctx);
    CGContextMoveToPoint(ctx, top - offs, 0);
    CGContextAddLineToPoint(ctx, imageSize.width - offs, 0);
    CGContextAddLineToPoint(ctx, imageSize.width - offs, imageSize.height);
    CGContextAddLineToPoint(ctx, bottom - offs, imageSize.height);
    CGContextAddLineToPoint(ctx, top - offs, 0);
    CGContextClosePath(ctx);
    CGContextClip(ctx);

    [src drawAtPoint:CGPointMake(-offs, 0)];

    r = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return r;
}

- (void)startSplashAnimation {
    CGRect bounds = contentBounds;

    UIView *redBackground = [[[UIView alloc] initWithFrame:bounds] autorelease];
    redBackground.backgroundColor = [UIColor colorWithRed:153/255.0 green:33/255.0 blue:31/255.0 alpha:1.0];
    [self.view addSubview:redBackground];

    NSString *defaultImageName = is_iPad ? @"Default-Landscape" : (is_iPhone5 ? @"Default-568h" : @"Default");
    UIImageView *splashImageView = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:defaultImageName]] autorelease];

    if (!is_iPad) {
        splashImageView.transform = CGAffineTransformMakeRotation((CGFloat) (-M_PI/2));
        splashImageView.center = CGPointMake(contentBounds.size.width/2, contentBounds.size.height/2);
    }

    [self.view addSubview:splashImageView];

    UIImageView *_3DRealmsLogo = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"3DRealms"]] autorelease];
    _3DRealmsLogo.alpha = 0;
    [self.view addSubview:_3DRealmsLogo];
    _3DRealmsLogo.center = is_iPad ? CGPointMake(267, 450) :
            is_iPhone5 ? CGPointMake(130+44, 204) : CGPointMake(130, 204);

    UIImageView *GALogo = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"GAlogo"]] autorelease];
    GALogo.alpha = 0;
    [self.view addSubview:GALogo];
    GALogo.center = is_iPad ? CGPointMake(771, 450) :
            is_iPhone5 ? CGPointMake(370+44, 204) : CGPointMake(370, 204);

    [UIView animateWithDuration:1.0 animations:^{
        CGRect rc = splashImageView.frame;
        rc.origin.y -= is_iPad ? 250 : 105;
        splashImageView.frame = rc;
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:1.0 animations:^{
            _3DRealmsLogo.alpha = 1.0;
            GALogo.alpha = 1.0;
        } completion:^(BOOL finished) {
            CGFloat cutOffset = is_iPad ? 50 : 20;
            CGFloat halfWidth = self.view.bounds.size.width/2;
            UIImage *snapshot = makeViewSnapshot(self.view);
            UIImage *leftPart = cutLeftPartOfImage(snapshot, halfWidth+cutOffset, halfWidth-cutOffset);
            UIImage *rightPart = cutRightPartOfImage(snapshot, halfWidth+cutOffset, halfWidth-cutOffset);

            CGRect rc;

            UIImageView *leftPartView = [[[UIImageView alloc] initWithImage:leftPart] autorelease];
            rc = leftPartView.frame;
            rc.origin.x = 0;
            leftPartView.frame = rc;

            UIImageView *rightPartView = [[[UIImageView alloc] initWithImage:rightPart] autorelease];
            rc = rightPartView.frame;
            rc.origin.x = halfWidth-cutOffset;
            rightPartView.frame = rc;

            UIView *bottomWhite = [[[UIView alloc] initWithFrame:self.view.bounds] autorelease];
            bottomWhite.backgroundColor = [UIColor whiteColor];

            UIView *topWhite = [[[UIView alloc] initWithFrame:self.view.bounds] autorelease];
            topWhite.backgroundColor = [UIColor whiteColor];

            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t) (1.5 * NSEC_PER_SEC)), dispatch_get_current_queue(), ^{

                NSString *filename = [[NSBundle mainBundle] pathForResource:@"sword" ofType:@"mp3"];
                NSURL *url = [NSURL fileURLWithPath:filename];
                AVAudioPlayer *avplayer = [[AVAudioPlayer alloc] initWithContentsOfURL:url  error:nil];
                [avplayer play];

                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t) (1.5 * NSEC_PER_SEC)), dispatch_get_current_queue(), ^{
                    [avplayer release];
                });

                [redBackground removeFromSuperview];
                [splashImageView removeFromSuperview];
                [_3DRealmsLogo removeFromSuperview];
                [GALogo removeFromSuperview];
                [self.view addSubview:bottomWhite];
                [self.view addSubview:leftPartView];
                [self.view addSubview:rightPartView];
                [self.view addSubview:topWhite];
                [UIView animateWithDuration:0.5
                                      delay:0
                                    options:UIViewAnimationOptionCurveEaseIn
                        animations:^{
                            CGRect rc;

                            rc = leftPartView.frame;
                            rc.origin.x -= rc.size.width;
                            leftPartView.frame = rc;

                            rc = rightPartView.frame;
                            rc.origin.x += rc.size.width;
                            rightPartView.frame = rc;

                            bottomWhite.alpha = 0;
                        } completion:^(BOOL finished) {
                    [leftPartView removeFromSuperview];
                    [rightPartView removeFromSuperview];
                    [bottomWhite removeFromSuperview];
                }];

                [UIView animateWithDuration:0.2
                                      delay:0
                                    options:UIViewAnimationOptionCurveEaseIn
                        animations:^{
                            topWhite.alpha = 0;
                        } completion:^(BOOL finished) {
                    [topWhite removeFromSuperview];
                    [self showMenuIfReady];
                }];
            });

        }];
    }];
}

- (void)reloadSettings {
    [_controlSchemeView release];
    _controlSchemeView = nil;
    if ([gameConfig.controlScheme isEqualToString:@"Classic"]) {
        _controlSchemeView = [[LWControlSchemeClassic alloc] init];
    } else if ([gameConfig.controlScheme isEqualToString:@"ScreenTap"]) {
        _controlSchemeView = [[LWControlSchemeScreenTap alloc] init];
    } else  {
        _controlSchemeView = [[LWControlSchemeVirtualSticks alloc] init];
    }
    _controlSchemeView.gameController = self;
    [_controlSchemeView setFrame:self.view.bounds];
    [gameInstance setAimSensitivity:gameConfig.aimSensitivity];
}

#pragma mark - Engine callbacks

- (void)showMenuIfReady {
    showMenuIfReadyCounter++;
    if (showMenuIfReadyCounter == 2) {
        [self presentMainMenu];
    }
}

- (void)showInfoMessage:(NSNotification*)notification {
//    NSString *message = (NSString*)notification.object;
}

- (void)playerDied {
    [_controlSchemeView removeFromSuperview];
    [self.view addSubview:_pauseView];
    [_pauseView showDeathMenu];
}

- (void) levelStarted:(NSNotification *)notification {
    NSNumber *level = notification.object;
    if (gameConfig.lastLevel < level.intValue) {
        gameConfig.lastLevel = level.intValue;
    }
    [_loadingView removeFromSuperview];
    [self showHudView];
    [self.view addSubview:_controlSchemeView];
    [_controlSchemeView updateView];
}

- (void)showHudView {
    [self.view addSubview:_hudView];
    [_hudView updateView];
}

- (void) savegameLoaded {
    [_loadingView removeFromSuperview];
    [_hudView updateView];
    [_controlSchemeView updateView];
}

- (void) intermissionStarted:(NSNotification *)notification {
    NSData *data = notification.object;
    intermission_info_t *info = (intermission_info_t*)data.bytes;
    [_controlSchemeView removeFromSuperview];
    [_hudView removeFromSuperview];
    [self.view addSubview:_intermissionView];
    [_intermissionView showInfo:info];
    [_intermissionView updateView];
}

- (void) intermissionStopped {
    [_intermissionView removeFromSuperview];
}

-(void) animationStarted:(NSNotification*)notification {
    [_controlSchemeView removeFromSuperview];
    [_hudView removeFromSuperview];
}

-(void) animationStopped:(NSNotification*)notification {
}



-(void)onGameOver {
    _mainMenuView.hidden = NO;
    [_pauseView removeFromSuperview];
    [_hudView removeFromSuperview];
    [menuStack addObject:_mainMenu];
    [self presentCreditsMenu];
}

- (void)onSharewareGameOver {
    _mainMenuView.hidden = NO;
    [_pauseView removeFromSuperview];
    [_hudView removeFromSuperview];
    [self presentMainMenu];
    [self presentStoreView];
}

#pragma mark - Menu

- (void)animateMenu:(UIView *)menuView
            prepare:(void (^) (UIView*))prepare
            animate:(void (^) (UIView*))animate
         completion:(void (^) (BOOL finished))completion
           duration:(NSTimeInterval)duration
            options:(UIViewAnimationOptions)options
{
    CGRect frame = menuView.frame;
    frame.origin.x = self.view.bounds.size.width-frame.size.width;
    menuView.frame = frame;
    
    NSUInteger maxTag = (NSUInteger) [[[menuView subviews] valueForKeyPath:@"@max.tag"] intValue];
    UIView *last = [menuView viewWithTag:maxTag];
    
    for (UIView *v in menuView.subviews) {
        if ([v isKindOfClass:[UIScrollView class]] && v.tag == 0) {
            CGRect f = v.frame, orig = v.frame;
            f.size.width = menuView.frame.size.width - f.origin.x;
            [v setFrame:f];
            UIView *vlast = [v viewWithTag:[[[v subviews] valueForKeyPath:@"@max.tag"] intValue]];
            for (UIView *u in v.subviews) {
                prepare(u);
                [UIView animateWithDuration:duration
                                      delay:((NSTimeInterval)u.tag)/1000.0
                                    options:options
                                 animations:^{
                                     animate(u);
                                 }
                                 completion:u == vlast ? ^(BOOL finished) {
                                     v.frame = orig;
                                 }:^(BOOL ff){}];
            }
        } else {
            prepare(v);
            [UIView animateWithDuration:duration
                                  delay:((NSTimeInterval)v.tag)/1000.0
                                options:options
                             animations:^{
                                 animate(v);
                             }
                             completion:v==last?completion:^(BOOL finished){}];
        }
    }
}

- (void)hideMenu:(UIView*)menu
      completion:(void (^)(BOOL finished))completion
{
    [self animateMenu:menu
              prepare:^(UIView *v) {
                  v.alpha = 1;
              }
              animate:^(UIView *v) {
                  v.alpha = 0;
              }
           completion:completion
             duration:0.2
              options:UIViewAnimationOptionCurveEaseIn
     ];
}

- (void)showMenu:(UIView*)menu
      completion:(void (^)(BOOL finished))completion
{
    for (UIView *v in menu.subviews)
        if ([v isKindOfClass:[UIScrollView class]])
            [(UIScrollView *)v setContentOffset:CGPointZero animated:NO];
    [self.mainMenuView addSubview:menu];
    if ([menu isKindOfClass:[LWMenuView class]]) {
        [(LWMenuView*)menu updateView];
    }
    if (menu == _mainMenu) {
        [self showLogo];
    } else {
        [self hideLogo];
    }
    [self animateMenu:menu
              prepare:^(UIView *v) {
                  CGRect pos = v.frame;
                  pos.origin.x += _mainMenu.frame.size.width;
                  v.frame = pos;
                  v.alpha = 1;
              }
              animate:^(UIView *v) {
                  CGRect pos = v.frame;
                  pos.origin.x -= _mainMenu.frame.size.width;
                  v.frame = pos;
                  if (v.tag == 777) { v.alpha = 0.5; }
              }
           completion:completion
             duration:0.2
              options:UIViewAnimationOptionCurveEaseIn
     ];
}

- (void) showLogo {
    [UIView animateWithDuration:0.5 animations:^{
        _swLogo.alpha = 1.0;
    }];
}

- (void) hideLogo {
    [UIView animateWithDuration:0.5 animations:^{
        _swLogo.alpha = 0.0;
    }];
}

- (void)presentMenu:(UIView*)menu {
    if (menuStack.count != 0) {
        UIView *v = [menuStack lastObject];
        [self hideMenu:v completion:^(BOOL finished) {
            [v removeFromSuperview];
        }];
    }
    [menuStack addObject:menu];
    [self showMenu:menu completion:nil];
}

- (void)popMenu {
    if (menuStack.count != 0) {
        UIView *v = [menuStack lastObject];
        [self hideMenu:v
            completion:^(BOOL finished) {
                [v removeFromSuperview];
        }];
        [menuStack removeLastObject];
    }
    if (menuStack.count != 0) {
        UIView *v = [menuStack lastObject];
        [self showMenu:v completion:nil];
    }
}

- (void) resetMenu {
    for (UIView *v in menuStack) {
        [v removeFromSuperview];
    }
    [menuStack removeAllObjects];
}


- (void) presentMainMenu {
    [_mainMenu updateView];
    [self presentMenu:_mainMenu];

}

- (void) presentControlSchemeEditor {
    LWControlSchemeEditorViewController *editor = [[[LWControlSchemeEditorViewController alloc] initWithControlScheme:_controlSchemeView] autorelease];
    CATransition *transition = [CATransition animation];
    transition.duration = 0.3;
    transition.type = kCATransitionFade;
    transition.subtype = kCATransitionFromTop;
    [self.navigationController.view.layer addAnimation:transition forKey:kCATransition];
    [self.navigationController pushViewController:editor animated:NO];
}

- (void) presentSettings {
    [self presentMenu:_settingsMenu];
}

- (void) presentSkillSelectMenu {
    [self presentMenu:_skillSelectMenu];
}

- (void) presentControlsMenu {
    [self presentMenu:_controlsMenu];
}

- (void) presentAboutMenu {
    [self presentMenu:_aboutMenu];
}

- (void) presentCoolStuffMenu {
    [self presentMenu:_coolStuffMenu];
}

- (void) presentCreditsMenu {
    if (gameConfig.enableMusic) {
        AVPlayer_CD_Play(14, 1);
    }
    [self presentMenu:_creditsMenu];
}

- (void) switchToMainMenu {
    [_pauseView hideMenu:^(BOOL finished) {
        self.mainMenuView.hidden = NO;
        [_pauseView removeFromSuperview];
        [_hudView removeFromSuperview];
        [self presentMainMenu];
    }];
}

#pragma mark - Actions

- (void) hidePauseMenu:(void(^)())completion {
    [_pauseView hideMenu:^(BOOL finished) {
        gameInstance.paused = NO;
        completion();
        [self showHudView];
        [self.view addSubview:_controlSchemeView];
        [_controlSchemeView updateView];
    }];
}

- (void) doSave {
    [_pauseView hideMenu:^(BOOL finished) {
        gameInstance.paused = NO;
        [gameInstance saveGame:0];
        [self showHudView];
        [self.view addSubview:_controlSchemeView];
        [_controlSchemeView updateView];
    }];
}

- (void) doLoad {
    [_pauseView hideMenu:^(BOOL finished) {
        gameInstance.paused = NO;
        [gameInstance loadGame:0];
        [self showHudView];
        [self.view addSubview:_controlSchemeView];
        [_controlSchemeView updateView];
    }];
}

- (void) restartLevel {
    [_pauseView hideMenu:^(BOOL finished) {
        gameInstance.paused = NO;
        [gameInstance restartLevel];
    }];
}

- (void) resumeGame {
    if (gameInstance.isLevelLoaded) {
        if (gameInstance.isPlayerAlive) {
            [self hideMenu:self.mainMenu completion:^(BOOL finished) {
                self.mainMenuView.hidden = YES;
                [self resetMenu];
                [self showHudView];
                [self.view addSubview:_controlSchemeView];
                [_controlSchemeView updateView];
                [gameInstance setPaused:NO];
            }];
        } else {
            [self hideMenu:self.mainMenu completion:^(BOOL finished) {
                self.mainMenuView.hidden = YES;
                [self resetMenu];
                [self.view addSubview:_pauseView];
                [_pauseView showDeathMenu];
            }];
        }
    } else {
        [self.view addSubview:_loadingView];
        [self hideMenu:self.mainMenu completion:^(BOOL finished) {
            self.mainMenuView.hidden = YES;
            [self resetMenu];
            [gameInstance loadGame:0];
        }];

    }
}

- (void) startNewGame {
    [self hideMenu:self.skillSelectMenu completion:^(BOOL finished) {
        self.mainMenuView.hidden = YES;
        [self resetMenu];
        [self.view addSubview:_loadingView];
        [gameInstance startGame:_skillSelectMenu.level skill:_skillSelectMenu.skill];
    }];
}

- (void) setPaused {
    if (!gameInstance.paused && levelLoaded) {
        [gameInstance setPaused:YES];
        if (gameInstance.isPlayerAlive) {
            [_controlSchemeView removeFromSuperview];
            [_hudView removeFromSuperview];
            [self.view addSubview:_pauseView];
            [_pauseView showPauseMenu];
        }
    }
}

- (void) pmResumeGame {
    [_pauseView hideMenu:^(BOOL finished) {
        [_pauseView removeFromSuperview];
        [self showHudView];
        [self.view addSubview:_controlSchemeView];
        [_controlSchemeView updateView];
        [_hudView updateView];
        [gameInstance setPaused:NO];
    }];
}

- (void) presentCheatsMenu {
    [_pauseView hideMenu:^(BOOL finished) {
        [_pauseView showCheatsMenu]; 
    }];
}

- (void)hideCheatMenu {
    [_pauseView hideMenu:^(BOOL finished) {
        [_pauseView showPauseMenu];
    }];
    
}

- (void) presentStoreView {
    [self.view addSubview:_storeView];
    [_storeView updateView];
}

- (void) hideStoreView {
    [_storeView removeFromSuperview];
}

- (void)buyFullGame {
    [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeBlack];
    [[MKStoreManager sharedManager] buyFeature:kInAppFullGame onComplete:^(NSString *purchasedFeature, NSData *purchasedReceipt, NSArray *availableDownloads) {
        extern int isFullGame;
        isFullGame = 1;
        [self showMessage:@"Thank you for purchasing Full Game! Enjoy!" withTitle:@"Lo Wang Store"];
        if (_skillSelectMenu != nil) {
            [_skillSelectMenu updateView];
        }
        [self hideStoreView];
        [SVProgressHUD dismiss];
    } onCancelled:^{
//        [self showMessage:@"Purchase canceled" withTitle:@"Lo Wang Store"];
        [SVProgressHUD dismiss];
    }];
}

- (void)restorePurchases {
    [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeBlack];
    [[MKStoreManager sharedManager] restorePreviousTransactionsOnComplete:^{
        extern int isFullGame;
        //        isFullGame = (int)[MKStoreManager isFeaturePurchased:kInAppFullGame];
        isFullGame = 1;
        [self showMessage:@"All purchases successfully restored!" withTitle:@"Lo Wang Store"];
        if (_skillSelectMenu != nil) {
            [_skillSelectMenu updateView];
        }
        [self hideStoreView];
        [SVProgressHUD dismiss];
    } onError:^(NSError *error) {
        [self showMessage:error.localizedDescription withTitle:@"Lo Wang Store"];
        [SVProgressHUD dismiss];
    }];
}

-(void)showMessage:(NSString *)message withTitle:(NSString *)title {
    UIAlertView * alert = [[UIAlertView alloc] initWithTitle:title message:message delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alert show];
    [alert release];
}

- (void)openURL:(NSString *)url {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:url]];
}

- (BOOL) isFullGame {
    extern int isFullGame;
    return (BOOL)isFullGame;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    static BOOL firstTime = YES;
    if (firstTime) {
        firstTime = NO;
        [self startSplashAnimation];
    }
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
    return (toInterfaceOrientation == UIInterfaceOrientationLandscapeLeft ||  toInterfaceOrientation == UIInterfaceOrientationLandscapeRight);
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [_logo3DRealms release];
    [_logoGeneralArcade release];
    [_mainMenu release];
    [menuStack release];
    [_settingsMenu release];
    [_mainMenuView release];
    [_eaglView release];
    [_controlSchemeView release];
    [_pauseView release];
    [_levelSelectMenu release];
    [_skillSelectMenu release];
    [_loadingView release];
    [_controlsMenu release];
    [_pauseView release];
    [_controlsMenu release];
    [_loWangView release];
    [_hudView release];
    [_menuBackground release];
    [_intermissionView release];
    [_swLogo release];
    [_coolStuffMenu release];
    [_aboutMenu release];
    [_creditsMenu release];
    [_storeView release];
    [super dealloc];
}
- (void)viewDidUnload {
    [self setLogo3DRealms:nil];
    [self setLogoGeneralArcade:nil];
    [self setMainMenu:nil];
    [self setSettingsMenu:nil];
    [self setMainMenuView:nil];
    [self setEaglView:nil];
    [self setControlSchemeView:nil];
    [self setPauseView:nil];
    [self setLevelSelectMenu:nil];
    [self setSkillSelectMenu:nil];
    [self setLoadingView:nil];
    [self setControlSchemeView:nil];
    [self setPauseView:nil];
    [self setControlsMenu:nil];
    [self setLoWangView:nil];
    [self setHudView:nil];
    [self setMenuBackground:nil];
    [self setIntermissionView:nil];
    [self setSwLogo:nil];
    [self setCoolStuffMenu:nil];
    [self setAboutMenu:nil];
    [self setCreditsMenu:nil];
    [self setStoreView:nil];
    [super viewDidUnload];
}

#ifdef DEBUG

- (void)toggleControlsVisibility {
    for (UIView *v in [_controlSchemeView viewsForEditing]) {
        [v setHidden:!v.hidden];
    }
}

#endif

@end
