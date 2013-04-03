//
//  LWDownloadView.m
//  lowang
//
//  Created by termit on 12/23/12.
//
//

#import "LWDownloadView.h"
#import <QuartzCore/QuartzCore.h>

@implementation LWDownloadView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}


- (void)awakeFromNib {
    self.progressSlider.userInteractionEnabled = NO;
}

- (void) updateView {
    [super updateView];
    _popUpView.backgroundColor = [UIColor whiteColor];
    _popUpView.layer.cornerRadius = 13;
    _popUpView.layer.masksToBounds = YES;
    _popUpView.layer.borderWidth = 2.0;
    _popUpView.layer.borderColor = [UIColor colorWithRed:83/255.0f green:35/255.0f blue:35/255.0f alpha:1.0f].CGColor;

    self.progressSlider.value = 0.0f;
}

- (void)updateProgress:(float)progress {
    self.progressSlider.value = progress;
}

- (IBAction)closeButtonClicked:(id)sender {
    [self.gameController hideDownloadView];
    [self.gameController cancelAllDownloads];
}

- (void)dealloc {
    [_title release];
    [_progressSlider release];
    [_popUpView release];
    [super dealloc];
}
@end
