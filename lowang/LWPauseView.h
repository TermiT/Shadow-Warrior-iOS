//
//  PauseView.h
//  lowang
//
//  Created by termit on 10/26/12.
//
//

#import <UIKit/UIKit.h>

@interface LWPauseView : UIView

- (void) showPauseMenu;
- (void) hideMenu:(void(^)(BOOL finished))completion;
- (void) showDeathMenu;
- (void) showCheatsMenu;

@end
