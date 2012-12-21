//
//  LWCheatMenu.m
//  lowang
//
//  Created by termit on 12/5/12.
//
//

#import "LWCheatMenu.h"

@implementation LWCheatMenu

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void) updateView {
    
}

- (IBAction)godModeButtonClicked:(id)sender {
    [self.gameController hidePauseMenu:^{
            [gameInstance godMode];
    }];
}

- (IBAction)giveAllButtonClicked:(id)sender {
    [self.gameController hidePauseMenu:^{
        [gameInstance giveAll];
    }];
}

- (IBAction)bunnyCannonClicked:(id)sender {
    [self.gameController hidePauseMenu:^{
        [gameInstance bunnyRocket];
    }];
}

- (IBAction)backButtonClicked:(id)sender {
    [self.gameController hideCheatMenu];
    
}

@end
