//
//  LWStoreView.m
//  lowang
//
//  Created by termit on 12/4/12.
//
//

#import "LWStoreView.h"
#import <QuartzCore/QuartzCore.h>

@implementation LWStoreView {
    IBOutlet UIView *popUpView;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)awakeFromNib {
    popUpView.backgroundColor = [UIColor whiteColor];
    popUpView.layer.cornerRadius = 13;
    popUpView.layer.masksToBounds = YES;
    popUpView.layer.borderWidth = 2.0;
    popUpView.layer.borderColor = [UIColor colorWithRed:83/255.0f green:35/255.0f blue:35/255.0f alpha:1.0f].CGColor;
}

- (void) updateView {
    [super updateView];
}

- (IBAction)closeButtonClicked:(id)sender {
    [self.gameController hideStoreView];
}

- (IBAction)buyButtonClicked:(id)sender {
    [self.gameController buyFullGame];
}

- (IBAction)restoreButtonClicked:(id)sender {
    [self.gameController restorePurchases];
}

- (void)dealloc {
    [popUpView release];
    [super dealloc];
}
@end
