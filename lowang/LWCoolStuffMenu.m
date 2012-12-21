//
//  LWCoolStuffMenu.m
//  lowang
//
//  Created by serge on 20/11/12.
//
//

#import "LWCoolStuffMenu.h"

@implementation LWCoolStuffMenu

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
- (IBAction)moreGamesButtonClicked:(id)sender {
    [self.gameController openURL:@"http://more.generalarcade.com/"];
}

- (IBAction)walkthroughButtonClicked:(id)sender {
    [self.gameController openURL:@"http://www.3drealms.com/sw/walkthroughs.html"];
}

- (IBAction)weaponsButtonClicked:(id)sender {
     [self.gameController openURL:@"http://www.3drealms.com/sw/weapons.html"];
}

- (IBAction)enemiesButtonClicked:(id)sender {
    [self.gameController openURL:@"http://www.3drealms.com/sw/enemies.html"];
}
- (IBAction)secretsButtonClicked:(id)sender {
    [self.gameController openURL:@"http://www.3drealms.com/sw/secrets.html"];
}

@end
