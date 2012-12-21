//
//  LWDeathMenu.m
//  lowang
//
//  Created by termit on 10/27/12.
//
//

#import "LWDeathMenu.h"
#import "LWGameInstance.h"

@implementation LWDeathMenu {
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

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

- (void)updateView {
    loadGameButton.enabled =  [gameInstance isSaveSlotAvailable];
}


- (IBAction)mainMenuButtonClicked:(id)sender {
    [gameInstance setPaused:NO];
    [self.gameController switchToMainMenu];
}
- (IBAction)loadGameButtonClicked:(id)sender {
    [gameInstance setPaused:NO];
    [self.gameController doLoad];
}
- (IBAction)restartLevelButtonClicked:(id)sender {
    [gameInstance setPaused:NO];
    [self.gameController restartLevel];
}

- (void)dealloc {
    [loadGameButton release];
    [super dealloc];
}
@end
