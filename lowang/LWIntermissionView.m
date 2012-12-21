//
//  LWIntermissionView.m
//  lowang
//
//  Created by serge on 15/11/12.
//
//

#import "LWIntermissionView.h"
#import "LWHudLabel.h"
#import "iphone_api.h"

@implementation LWIntermissionView {
    
    IBOutlet LWHudLabel *levelNameLabel;
    IBOutlet LWHudLabel *userTimeLabel;
    IBOutlet LWHudLabel *bestTimeLabel;
    IBOutlet LWHudLabel *parTimeLabel;
    IBOutlet LWHudLabel *secretsLabel;
    IBOutlet LWHudLabel *killsLabel;
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
    UIButton *screenButton = [[UIButton alloc] initWithFrame:self.bounds];
    screenButton.backgroundColor = [UIColor clearColor];
    [screenButton addTarget:self action:@selector(screenButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:screenButton];
    [screenButton release];
}

- (void)showInfo:(intermission_info_t*)info {
    levelNameLabel.text = [NSString stringWithUTF8String:info->map_name];
    userTimeLabel.text = [NSString stringWithFormat:@"Your Time:   %s", info->user_time];
    bestTimeLabel.text = [NSString stringWithFormat:@"3D Realms Best Time:   %s", info->best_time];
    parTimeLabel.text = [NSString stringWithFormat:@"Par Time:   %s", info->par_time];
    secretsLabel.text = [NSString stringWithFormat:@"Secrets:   %d/%d", info->found_secrets, info->level_secrets];
    killsLabel.text = [NSString stringWithFormat:@"Kills:   %d/%d", info->kills, info->total_killable];
}

- (void)updateView {
    
}

- (void) screenButtonTapped:(id)sender {
    [gameInstance quitIntermission];
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
    [levelNameLabel release];
    [userTimeLabel release];
    [bestTimeLabel release];
    [parTimeLabel release];
    [secretsLabel release];
    [killsLabel release];
    [super dealloc];
}
@end
