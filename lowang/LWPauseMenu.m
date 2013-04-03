//
//  PauseMenu.m
//  lowang
//
//  Created by termit on 10/26/12.
//
//

#import "LWPauseMenu.h"
#import "LWGameInstance.h"
#import "build.h"
#ifdef TESTING
#import "TestFlight.h"
#endif


@implementation LWPauseMenu {
    
    IBOutlet UIButton *loadGameButton;
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
    loadGameButton.enabled =  [gameInstance isSaveSlotAvailable];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/
- (IBAction)resumeButtonClicked:(id)sender {
    [self.gameController pmResumeGame];
}
- (IBAction)mainMenuButtonClicked:(id)sender {
    [self.gameController switchToMainMenu];
}
- (IBAction)loadGameButtonClicked:(id)sender {
    [self.gameController doLoad];
}
- (IBAction)saveGameButtonClicked:(id)sender {
    [self.gameController doSave];
}
- (IBAction)restartLevelButtonClicked:(id)sender {
    [self.gameController restartLevel];
}
- (IBAction)mapButtonClicked:(id)sender {
    [self.gameController hidePauseMenu:^{
        [gameInstance toggleMap];
    }];
}
- (IBAction)cheatsButtonClicked:(id)sender {
    [self.gameController presentCheatsMenu];
}

- (void)dealloc {
    [loadGameButton release];
    [loadGameButton release];
    [super dealloc];
}

#if ENABLE_DEV_BUTTONS

UIButton*
createDevButton(NSString *title, CGRect frame, id target, SEL sel) {
    UIButton *butt = [UIButton buttonWithType:UIButtonTypeCustom]; // butt, hehe
    [butt addTarget:target action:sel forControlEvents:UIControlEventTouchUpInside];
    butt.frame = frame;
    butt.titleLabel.font = [UIFont fontWithName:@"Copperplate" size:16];
    [butt setTitle:title forState:UIControlStateNormal];
    [butt setTitleColor:[UIColor greenColor] forState:UIControlStateNormal];
    [butt setBackgroundImage:[UIImage imageNamed:@"devbtn.png"] forState:UIControlStateNormal];
    return butt;
}

- (void)awakeFromNib {
    CGRect rc = { 10, 10, 160, 40 };

    [self addSubview:createDevButton(@"god mode", rc, self, @selector(dev_godMode))];

    rc.origin.y += 50;
    [self addSubview:createDevButton(@"give all", rc, self, @selector(dev_giveAll))];

    rc.origin.y += 50;
    [self addSubview:createDevButton(@"end level", rc, self, @selector(dev_endLevel))];

    rc.origin.y += 50;
    [self addSubview:createDevButton(@"toggle controls", rc, self, @selector(dev_hideControls))];

    rc.origin.y += 50;
    [self addSubview:createDevButton(@"dump settings", rc, self, @selector(dev_dumpSettings))];

    rc.origin.y += 50;
    [self addSubview:createDevButton(@"feedback", rc, self, @selector(dev_feedback))];

    rc.origin.y += 50;
    [self addSubview:createDevButton(@"tex filter", rc, self, @selector(dev_toggleTextureFilter))];

}

- (void)dev_dumpSettings {
    [self.gameController hidePauseMenu:^{
        [gameConfig dumpSettings];
    }];
}

- (void)dev_hideControls {
    [self.gameController hidePauseMenu:^{
        [self.gameController toggleControlsVisibility];
    }];
}

- (void)dev_endLevel {
    [self.gameController hidePauseMenu:^{
        [gameInstance endLevel];
    }];
}

- (void)dev_giveAll {
    [self.gameController hidePauseMenu:^{
        [gameInstance giveAll];
    }];
}

- (void)dev_godMode {
    [self.gameController hidePauseMenu:^{
        [gameInstance godMode];
    }];
}

- (void)dev_feedback {
    if (IS_IPAD()) {
#ifdef TESTING
        [TestFlight openFeedbackView];
#endif
    } else {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Submit feedback" message:@"Please describe the issue:" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"OK", nil];
        alert.alertViewStyle = UIAlertViewStylePlainTextInput;
        [alert show];
        [alert release];
    }
}


- (void)dev_toggleTextureFilter {
    gameInstance.textureFilterMode = 5 - gameInstance.textureFilterMode;
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (buttonIndex != alertView.cancelButtonIndex) {
        UITextField * textField = [alertView textFieldAtIndex:0];
        #ifdef TESTING
        [TestFlight submitFeedback:textField.text];
    #endif
    }
}


#endif

@end
