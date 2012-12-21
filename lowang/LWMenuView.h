//
//  LWMenuView.h
//  lowang
//
//  Created by termit on 10/24/12.
//
//

#import <UIKit/UIKit.h>
#import "LWGameController.h"

@interface LWMenuView : UIView
@property (retain, nonatomic) IBOutlet LWGameController *gameController;

- (void)updateView;
@end
