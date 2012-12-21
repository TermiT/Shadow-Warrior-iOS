//
//  LWMainMenu.m
//  lowang
//
//  Created by termit on 10/24/12.
//
//

#import "LWMainMenu.h"
#import "LWGameController.h"
#import "LWGameInstance.h"

@implementation LWMainMenu {
    
    IBOutlet UIButton *resumeButton;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}


- (void)updateView {
    if ([gameInstance isLevelLoaded]) {
        resumeButton.enabled = YES;
    } else {
        resumeButton.enabled = [gameInstance isSaveSlotAvailable];
    }
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/
- (IBAction)settingsButtonClicked:(id)sender {
    [self.gameController presentSettings];
//    [[LWGameInstance sharedInstance] startGame:1 skill:0];
}

- (IBAction)newGameButtonClicked:(id)sender {
    [self.gameController presentSkillSelectMenu];
}

- (IBAction)resumeButtonClicked:(id)sender {
    [self.gameController resumeGame];
}

- (IBAction)coolStuffButtonClicked:(id)sender {
    [self.gameController presentCoolStuffMenu];
}
- (IBAction)aboutButtonClicked:(id)sender {
    [self.gameController presentAboutMenu];
}

- (IBAction)controlsButtonClicked:(id)sender {
    [self.gameController presentControlsMenu];
}

- (IBAction)storeButtonClicked:(id)sender {
    [self.gameController presentStoreView];
}


- (void)dealloc {
    [resumeButton release];
    [super dealloc];
}
@end
