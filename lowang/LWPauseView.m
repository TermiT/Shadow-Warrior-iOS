//
//  PauseView.m
//  lowang
//
//  Created by termit on 10/26/12.
//
//

#import "LWPauseView.h"
#import "LWPauseMenu.h"
#import "LWDeathMenu.h"
#import "LWCheatMenu.h"
#import <objc/runtime.h>

@implementation LWPauseView {
    IBOutlet LWPauseMenu *pauseMenu;
    IBOutlet LWDeathMenu *deathMenu;
    IBOutlet LWCheatMenu *cheatsMenu;
    UIView * currentMenu;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)animateMenu:(UIView *)menuView
            prepare:(void (^) (UIView*))prepare
            animate:(void (^) (UIView*))animate
         completion:(void (^) (BOOL finished))completion
           duration:(NSTimeInterval)duration
            options:(UIViewAnimationOptions)options
{
    CGRect frame = menuView.frame;
    frame.origin.x = self.frame.size.width-frame.size.width;
    menuView.frame = frame;
    
    NSUInteger maxTag = (NSUInteger) [[[menuView subviews] valueForKeyPath:@"@max.tag"] intValue];
    UIView *last = [menuView viewWithTag:maxTag];
    
    for (UIView *v in menuView.subviews) {
        prepare(v);
        [UIView animateWithDuration:duration
                              delay:((NSTimeInterval)v.tag)/1000.0
                            options:options
                         animations:^{
                             animate(v);
                         }
                         completion:v==last?completion:^(BOOL finished){}];
    }
}

static void *alphaContextKey = &alphaContextKey;


- (void)showMenu:(LWMenuView *)menu {
    [menu updateView];
    NSTimeInterval duration = 0.2;
    currentMenu = menu;
    
    [self addSubview:menu];
    [self animateMenu:menu
              prepare:^(UIView *v) {
                  if (objc_getAssociatedObject(v, alphaContextKey) == nil) {
                      objc_setAssociatedObject(v, alphaContextKey, @(v.alpha), OBJC_ASSOCIATION_RETAIN);
                  }
                  v.alpha = 0;
              }
              animate:^(UIView *v) {
                  NSNumber *alpha = objc_getAssociatedObject(v, alphaContextKey);
                  v.alpha = alpha.floatValue;
              }
           completion:^(BOOL finished) {
           }
             duration:duration
              options:UIViewAnimationOptionCurveEaseIn
     ];

}

- (void) showPauseMenu {
    [self showMenu:pauseMenu];
}

- (void) showDeathMenu {
    [self showMenu:deathMenu];
}

- (void) showCheatsMenu {
    [self showMenu:cheatsMenu];
}

- (void) hideMenu:(void(^)(BOOL finished))completion {
    NSTimeInterval duration = 0.2;
    [self animateMenu:currentMenu
              prepare:^(UIView *v) {
                  NSNumber *alpha = objc_getAssociatedObject(v, alphaContextKey);
                  v.alpha = alpha.floatValue;
              }
              animate:^(UIView *v) {
                  v.alpha = 0;
              }
           completion:^(BOOL finished) {
               [currentMenu removeFromSuperview];
               completion(finished);
           }
             duration:duration
              options:UIViewAnimationOptionCurveEaseIn
     ];
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
    [LWPauseView release];
    [pauseMenu release];
    [deathMenu release];
    [cheatsMenu release];
    [super dealloc];
}
@end
