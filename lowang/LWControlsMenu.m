//
//  LWControlsView.m
//  lowang
//
//  Created by termit on 10/27/12.
//
//

#import <QuartzCore/QuartzCore.h>
#import "LWControlsMenu.h"
#import "LWHudLabel.h"
#import "LWSwitch.h"
#import "LWSlider.h"

@implementation LWControlsMenu {
    
    IBOutlet LWSwitch *leftHandedSwitch;
    IBOutlet LWSwitch *verticalAimSwitch;
    IBOutlet LWSwitch *invertYAxisSwitch;
    IBOutlet LWSlider *sensSlider;
    IBOutlet UIScrollView *controlSchemeSV;
    IBOutlet LWHudLabel *schemeNameLabel;
    int currentSchemeIndex;
    NSArray *schemeNames;
    NSArray *schemeDisplayNames;
    IBOutlet UIButton *leftButton;
    IBOutlet UIButton *rightButton;
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
    schemeNames = [@[@"Classic", @"ScreenTap", @"VirtualSticks"] retain];
    schemeDisplayNames = [@[@"Classic", @"Screen Tap", @"Virtual Sticks"] retain];
    controlSchemeSV.layer.cornerRadius = 13.0f;
    controlSchemeSV.layer.masksToBounds = YES;
    [self fillScrollView];
}

- (void) fillScrollView {
    
    int schemeNumber = schemeNames.count;
    for (int i = 0; i < schemeNumber; i++) {
        CGFloat xOrigin = i * controlSchemeSV.frame.size.width;
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(xOrigin, 0, controlSchemeSV.frame.size.width, controlSchemeSV.frame.size.height)];
        imageView.image = [UIImage imageNamed:[schemeNames objectAtIndex:(NSUInteger) i]];
        imageView.contentMode = UIViewContentModeScaleToFill;
        imageView.backgroundColor = [UIColor clearColor];
        [controlSchemeSV addSubview:imageView];
        [imageView release];
    }
    controlSchemeSV.contentSize = CGSizeMake(controlSchemeSV.frame.size.width * schemeNumber, controlSchemeSV.frame.size.height);
    CGRect bounds = controlSchemeSV.bounds;
    if(IS_IPAD()){
       bounds.size.width = 186.0f;
    } else {
        bounds.size.width = 93.0f;
    }

    [controlSchemeSV setBounds:bounds];
}


- (void)updateView {
    currentSchemeIndex = [schemeNames indexOfObject:gameConfig.controlScheme];
    [self scrollToPage:currentSchemeIndex animated:NO];
    controlSchemeSV.delegate = self;
    [self updateTitleAndButtons];

    leftHandedSwitch.on = gameConfig.leftHandedControls;
    sensSlider.value = gameConfig.aimSensitivity;
    verticalAimSwitch.on = gameConfig.enableVerticalAim;
    invertYAxisSwitch.on = gameConfig.invertYAxis;
}
- (IBAction)leftHandedChanged:(id)sender {
    LWSwitch *sw = (LWSwitch *)sender;
    gameConfig.leftHandedControls = sw.on;
    [self.gameController reloadSettings];
}
- (IBAction)sensSliderChanged:(id)sender {
    LWSlider *slider = (LWSlider *)sender;
    gameConfig.aimSensitivity = slider.value;
    [self.gameController reloadSettings];
}

- (IBAction)verticalAimChanged:(id)sender {
    gameConfig.enableVerticalAim = verticalAimSwitch.on;
    [gameInstance updateGameSettings];    
}

- (IBAction)invertYAxisChanged:(id)sender {
    gameConfig.invertYAxis = invertYAxisSwitch.on;
    [gameInstance updateGameSettings];
}

- (IBAction)customizeButtonClicked:(id)sender {
    [self.gameController presentControlSchemeEditor];
}

- (void)scrollToPage:(int)page animated:(BOOL)animated {
    CGRect rect = controlSchemeSV.bounds;
    rect.origin.x = rect.size.width * page;
    [controlSchemeSV scrollRectToVisible:rect animated:animated];
}

- (IBAction)leftButtonClicked:(id)sender {
    [self scrollToPage:currentSchemeIndex -1 animated:YES];
}
- (IBAction)rightButtonClicked:(id)sender {
    [self scrollToPage:currentSchemeIndex +1 animated:YES];
}

#pragma mark - UIScrollView delegate

- (void)scrollViewDidScroll:(UIScrollView *)sender {
    CGFloat pageWidth = controlSchemeSV.frame.size.width;
    int page = (int) (floor((controlSchemeSV.contentOffset.x - pageWidth / 2) / pageWidth) + 1);
    if (page < schemeNames.count && page >= 0  ) {
        currentSchemeIndex = page;
        [self changeControlScheme:currentSchemeIndex];
        [self updateTitleAndButtons];
    }
}

- (void)updateTitleAndButtons {
    schemeNameLabel.text = [schemeDisplayNames objectAtIndex:(NSUInteger) currentSchemeIndex];
    rightButton.enabled = !(currentSchemeIndex >= schemeNames.count - 1);
    leftButton.enabled = !(currentSchemeIndex <= 0);
}

- (void)changeControlScheme:(int)index {
    if (gameConfig.controlScheme != [schemeNames objectAtIndex:(NSUInteger) index]) {
        gameConfig.controlScheme = [schemeNames objectAtIndex:(NSUInteger) index];
        [self.gameController reloadSettings];
    }
}

- (IBAction)backButtonClicked:(id)sender {
    controlSchemeSV.delegate = nil;
    [self.gameController popMenu];
}


/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

- (void)dealloc {
    [leftHandedSwitch release];
    [sensSlider release];
    [verticalAimSwitch release];
    [invertYAxisSwitch release];
    [controlSchemeSV release];
    [schemeNameLabel release];
    [leftButton release];
    [rightButton release];
    [schemeNames release];
    [schemeDisplayNames release];
    [super dealloc];
}
@end
