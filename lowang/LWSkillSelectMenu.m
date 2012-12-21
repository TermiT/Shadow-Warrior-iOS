//
//  LWSkillSelectMenu.m
//  lowang
//
//  Created by termit on 10/26/12.
//
//

#import "LWSkillSelectMenu.h"
#import "LWAttributedButton.h"
#import "LWGameController.h"
#import <QuartzCore/QuartzCore.h>

#define kNumberOfFreeLevels 4


@implementation LWSkillSelectMenu {
    IBOutlet UIScrollView *levelScrollView;
    IBOutlet UILabel *levelNameLabel;
    IBOutlet UIButton *leftButton;
    IBOutlet UIButton *rightButton;
    NSArray *levelNames;
    int currentPage;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)scrollToPage:(int)page animated:(BOOL)animated {
    CGRect rect = levelScrollView.frame;
    rect.origin.x = rect.size.width * page;
    [levelScrollView scrollRectToVisible:rect animated:animated];
}

- (IBAction)leftButtonClicked:(id)sender {
    [self scrollToPage:currentPage-1 animated:YES];
}
- (IBAction)rightButtonClicked:(id)sender {
    [self scrollToPage:currentPage+1 animated:YES];
}

- (void) awakeFromNib {
    levelNames = [@[@"Seppuku Station", @"Zilla Construction", @"Master Leep's Temple", @"Dark Woods of the Serpent", @"Rising Son", @"Killing Fields", @"Hara-Kiri Harbor", @"Zilla's Villa",  @"Monastery", @"Raider of the Lost Wang", @"Sumo Sky Palace", @"Bath House",  @"Unfriendly Skies", @"Crude Oil", @"Coolie Mines", @"Subpen 7", @"The Great Escape", @"Floating Fortress", @"Water Torture", @"Stone Rain"] retain];
    levelScrollView.layer.cornerRadius = 13.0f;
    levelScrollView.layer.masksToBounds = YES;

}

- (void) updateView {
    [self fillScrollView];
    [self scrollToPage:gameConfig.lastLevel-1 animated:NO];
    [self updateTitleAndButtons];
}

- (void) fillScrollView {
    for (UIView * view in [levelScrollView subviews])
         [view removeFromSuperview];
    int pageNumber = levelNames.count;
    for (int i=0; i < pageNumber; i++) {
        CGFloat xOrigin = i * levelScrollView.frame.size.width;
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(xOrigin, 0, levelScrollView.frame.size.width, levelScrollView.frame.size.height)];
        imageView.image = [UIImage imageNamed:[NSString stringWithFormat:@"level_%02d_preview.jpg", i+1]];
        imageView.contentMode = UIViewContentModeScaleToFill;
        imageView.backgroundColor = [UIColor clearColor];
        imageView.layer.cornerRadius = 13.0f;
        imageView.layer.masksToBounds = YES;
//        if (i+1 > [LWConfig sharedConfig].lastLevel) {
        if (i+1 > kNumberOfFreeLevels && ![self.gameController isFullGame]) {
            UIImageView * lockView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"levelLock.png"]];
            [lockView setFrame:imageView.bounds];
            lockView.backgroundColor = [UIColor clearColor];
            lockView.contentMode = UIViewContentModeCenter;
            [imageView addSubview:lockView];
            [lockView release];
        }

        [levelScrollView addSubview:imageView];
        [imageView release];
    }
    levelScrollView.contentSize = CGSizeMake(levelScrollView.frame.size.width * pageNumber, levelScrollView.frame.size.height);
    CGRect bounds = levelScrollView.bounds;
    if (IS_IPAD()) {
        bounds.size.width = 256.0f;
    } else {
        bounds.size.width = 128.0f;
    }
    
    [levelScrollView setBounds:bounds];
}

- (void)updateTitleAndButtons {
    levelNameLabel.text = [NSString stringWithFormat:@"%d. %@", currentPage+1, [levelNames objectAtIndex:(NSUInteger) currentPage]];
    rightButton.enabled = !(currentPage >= levelNames.count - 1);
    leftButton.enabled = !(currentPage <= 0);
}


- (IBAction)skillButtonClicked:(id)sender {
//    if (self.level > [LWConfig sharedConfig].lastLevel) {
//        UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"Level locked" message:@"Finish all previous levels to unlock this one." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
//        [alert show];
//        [alert release];
//        return;
//    }
    if (self.level > kNumberOfFreeLevels && ![self.gameController isFullGame]) {
        [self.gameController presentStoreView];
        return;
    }
    self.skill = [((LWAttributedButton *)sender).levelNumber unsignedIntValue];
    [self.gameController startNewGame];
}

- (NSUInteger)level {
    return (NSUInteger) (currentPage+1);
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
    [levelScrollView release];
    [levelNameLabel release];
    [leftButton release];
    [rightButton release];
    [levelNames release];
    [super dealloc];
}

#pragma mark - UIScrollView delegate

- (void)scrollViewDidScroll:(UIScrollView *)sender {
    CGFloat pageWidth = levelScrollView.frame.size.width;
    int page = (int) (floor((levelScrollView.contentOffset.x - pageWidth / 2) / pageWidth) + 1);
    if (page < levelNames.count && page >= 0  ) {
        currentPage = page;
        [self updateTitleAndButtons];
    }
}


@end
