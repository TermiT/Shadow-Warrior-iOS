//
//  LWMenuView.m
//  lowang
//
//  Created by termit on 10/24/12.
//
//

#import "LWMenuView.h"

@implementation LWMenuView
@synthesize gameController;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (IBAction)backButtonClicked:(id)sender {
    [self.gameController popMenu];
}

- (void)updateView {
    
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
