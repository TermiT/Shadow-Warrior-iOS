//
//  LWDownloadView.h
//  lowang
//
//  Created by termit on 12/23/12.
//
//

#import "LWMenuView.h"
#import "LWHudLabel.h"
#import "LWSlider.h"

@interface LWDownloadView : LWMenuView
@property (retain, nonatomic) IBOutlet LWHudLabel *title;
@property (retain, nonatomic) IBOutlet LWSlider *progressSlider;
@property (retain, nonatomic) IBOutlet UIView *popUpView;

- (void)updateProgress:(float)progress;

@end
