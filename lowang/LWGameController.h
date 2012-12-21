//
//  MenuViewController.h
//  lowang
//
//  Created by termit on 10/23/12.
//
//

#import <UIKit/UIKit.h>

@interface LWGameController : UIViewController

- (void)reloadSettings;

- (void) popMenu;

- (void)presentControlSchemeEditor;

- (void) presentSettings;
- (void) presentSkillSelectMenu;
- (void) presentControlsMenu;
- (void) presentAboutMenu;
- (void) presentCoolStuffMenu;
- (void) presentCreditsMenu;
- (void) startNewGame;
- (void) setPaused;
- (void) pmResumeGame;
- (void) presentCheatsMenu;
- (void) hideCheatMenu;

- (void) presentStoreView;
- (void) hideStoreView;
- (void) buyFullGame;
- (void) restorePurchases;

- (BOOL) isFullGame;

- (void)showMessage:(NSString *)message withTitle:(NSString *)title;

- (void)openURL:(NSString *)url;

#ifdef DEBUG
- (void)toggleControlsVisibility;
#endif

- (void) switchToMainMenu;

- (void)hidePauseMenu:(void (^)())completion;

- (void) resumeGame;
- (void) restartLevel;
- (void) doSave;
- (void) doLoad;

@end
