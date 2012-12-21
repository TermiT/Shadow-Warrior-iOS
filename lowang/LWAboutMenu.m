//
//  LWAboutMenu.m
//  lowang
//
//  Created by serge on 20/11/12.
//
//

#import "LWAboutMenu.h"
#import "LWGameController.h"

@implementation LWAboutMenu

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
- (IBAction)creditsButtonClicked:(id)sender {
    [self.gameController presentCreditsMenu];
}
- (IBAction)_3dRealmsWebsiteButtonClicked:(id)sender {
    [self.gameController openURL:@"http://www.3drealms.com/"];
}
- (IBAction)gaWebsiteClicked:(id)sender {
    [self.gameController openURL:@"http://www.generalarcade.com/"];
}
- (IBAction)_3dRealmsTwitterButtonClicked:(id)sender {
    [self.gameController openURL:@"http://twitter.com/3drealms"];
}
- (IBAction)gaTwitterButtonClicked:(id)sender {
    [self.gameController openURL:@"http://twitter.com/generalarcade"];
}

@end
