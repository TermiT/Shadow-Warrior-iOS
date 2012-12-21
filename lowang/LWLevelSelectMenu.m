//
//  LWLevelSelect.m
//  lowang
//
//  Created by termit on 10/26/12.
//
//

#import "LWLevelSelectMenu.h"
#import "LWAttributedButton.h"

@implementation LWLevelSelectMenu

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (IBAction)levelButtonClicked:(id)sender {
    self.level = [((LWAttributedButton *)sender).levelNumber intValue];
    [self.gameController presentSkillSelectMenu];
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
