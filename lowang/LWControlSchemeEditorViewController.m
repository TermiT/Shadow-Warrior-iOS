//
//  LWControlSchemeEditorViewController.m
//  lowang
//
//  Created by serge on 8/11/12.
//
//

#import <QuartzCore/QuartzCore.h>
#import "LWControlSchemeEditorViewController.h"
#import "controlSchemeHelpers.h"
#include "sys_iphone.h"
#import "LWAttributedButton.h"

static
UIImageView* makeViewSnapshot(UIView *v) {
    UIImage *r = nil;
    UIGraphicsBeginImageContextWithOptions(v.bounds.size, NO, [UIScreen mainScreen].scale);
    CGContextScaleCTM( UIGraphicsGetCurrentContext(), 1.0f, 1.0f );
    [v.layer renderInContext:UIGraphicsGetCurrentContext()];
    r = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    UIImageView *iv = [[[UIImageView alloc] initWithImage:r] autorelease];
    iv.frame = v.frame;
    iv.tag = v.tag;
    return iv;
}

static
NSMutableArray* makeSnapshots(NSArray *views) {
    NSMutableArray *r = [NSMutableArray array];
    for (NSUInteger i = 0; i < views.count; i++) {
        UIView *v = [views objectAtIndex:i];
        CGFloat alpha = v.alpha;
        v.alpha = 1.0f;
        [r addObject:makeViewSnapshot(v)];
        v.alpha = alpha;
    }
    return r;
}

static
CGRect lefthandizeRect(CGRect rect, CGSize bounds) {
    return CGRectMake(bounds.width - (rect.origin.x+rect.size.width), rect.origin.y, rect.size.width, rect.size.height);
}

NSDictionary* schemeConfig(NSArray *schemeViews, BOOL leftHandedMode) {
    CGRect screenBounds = [UIScreen mainScreen].bounds;
    CGSize bounds = CGSizeMake(screenBounds.size.height, screenBounds.size.width);
    NSMutableDictionary *r = [NSMutableDictionary dictionary];
    for (UIView *v in schemeViews) {
        NSString *key = [NSString stringWithFormat:@"tag%d", v.tag];
        NSString *value = NSStringFromCGRect(leftHandedMode? lefthandizeRect(v.frame, bounds) : v.frame);
        [r setObject:value forKey:key];
    }
    return [NSDictionary dictionaryWithDictionary:r];
}

void applySchemeConfig(NSArray *schemeViews, NSDictionary *schemeConfig, BOOL leftHandedMode) {
    for (UIView *v in schemeViews) {
        NSString *key = [NSString stringWithFormat:@"tag%d", v.tag];
        NSString *value = [schemeConfig valueForKey:key];
        if (value != nil) {
            CGRect rect = CGRectFromString(value);
            v.frame = leftHandedMode ? lefthandizeRect(rect, screenSize) : rect;
        }
    }
}

@interface LWControlSchemeEditorViewController ()

@end

@implementation LWControlSchemeEditorViewController {
    NSArray *_viewsForEditing;
    UIView *_draggingView;
    UIImageView *_background;
    NSString *_schemeName;
    LWControlScheme *_controlScheme;
}

- (LWControlSchemeEditorViewController*) initWithControlScheme:(LWControlScheme*)controlScheme {
    if ((self = [super init]) != nil) {
        _viewsForEditing = [makeSnapshots(controlScheme.viewsForEditing) retain];
        _controlScheme = [controlScheme retain];
        _schemeName = [[NSString alloc] initWithString:controlScheme.schemeName];
        [self adjustViewPositions];
    }
    return self;
}

- (void) dealloc {
    [_viewsForEditing release];
    [_background release];
    [_schemeName release];
    [_controlScheme release];
    [super dealloc];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

static void
placeButtonsOverToolbar(UIView *toolbar, NSArray *buttons) {
    const CGFloat buttonSpacing = 20;
    CGRect rc = CGRectZero;
    CGFloat width = 0;
    CGFloat height = 0;

    for (UIView *v in buttons) {
        width += v.bounds.size.width + buttonSpacing;
        if (height < v.bounds.size.height) {
            height = v.bounds.size.height;
        }
    }
    width -= buttonSpacing;

    UIView *buttonContainer = [[[UIView alloc] initWithFrame:CGRectMake(0, 0, width, height)] autorelease];
    CGFloat x = 0;
    for (UIView *v in buttons) {
        rc = v.frame;
        rc.origin.x = x;
        rc.origin.y = (height - rc.size.height)/2;
        x += rc.size.width + buttonSpacing;
        v.frame = rc;
        [buttonContainer addSubview:v];
    }

    [toolbar.superview addSubview:buttonContainer];
    buttonContainer.center = toolbar.center;
}

UIButton *createToolbarButton(NSString *title, id target, SEL action, CGFloat width, CGFloat height) {
    LWAttributedButton *button = [[[LWAttributedButton alloc] init] autorelease];
    button.fontName = @"Bonzai";
    button.fontSize = @(is_iPad ? 50 : 25);

    [button setTitleColor:[UIColor colorWithRed:229/255.0 green:35/255.0 blue:35/255.0 alpha:1] forState:UIControlStateSelected];
    [button setTitleColor:[UIColor colorWithRed:229/255.0 green:35/255.0 blue:35/255.0 alpha:1] forState:UIControlStateHighlighted];
    [button setTitleColor:[UIColor colorWithRed:190/255.0 green:35/255.0 blue:35/255.0 alpha:1] forState:UIControlStateNormal];
    [button setTitleColor:[UIColor colorWithRed:83/255.0 green:35/255.0 blue:35/255.0 alpha:1] forState:UIControlStateDisabled];
    [button setTitle:title forState:UIControlStateNormal];
    [button applyAttributes];

    button.frame = CGRectMake(0, 0, width, height);
    [button addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
    return button;
}

- (void) addViewsForEditing {
    for (UIView *view in _viewsForEditing) {
        [self.view addSubview:view];
        view.userInteractionEnabled = NO;

        view.layer.shadowColor = [UIColor yellowColor].CGColor;
        view.layer.shadowRadius = 3;
        view.layer.shadowOffset = CGSizeMake(0, 0);
        view.layer.shadowOpacity = 1;

        CABasicAnimation* animation = [CABasicAnimation animationWithKeyPath:@"shadowOpacity"];
        animation.fromValue = [NSNumber numberWithFloat:0.5];
        animation.toValue = [NSNumber numberWithFloat:1.0];
        animation.repeatCount = HUGE_VAL;
        animation.duration = 0.5;
        animation.autoreverses = YES;
        animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];

        [view.layer addAnimation:animation forKey:@"pulse"];
    }
}

- (void) addBackground {
    NSString *imageName = is_iPad ? @"controlsBg~iPad.jpg" : (is_iPhone5 ? @"controlsBg~iPhone5.jpg" : @"controlsBg~iPhone.jpg");
    UIImageView *background = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:imageName]] autorelease];
    background.frame = self.view.bounds;
    [self.view addSubview:background];
}

- (void) addToolbar {
    CGRect toolbarFrame = { 0, 0, self.view.bounds.size.width, is_iPad ? 144 : 65 };

    UIView *toolbar = [[[UIView alloc] initWithFrame:toolbarFrame] autorelease];
    toolbar.backgroundColor = [UIColor whiteColor];
    toolbar.alpha = 0.7;
    [self.view addSubview:toolbar];

    CGRect instructionsRect = { 0, toolbarFrame.size.height, self.view.bounds.size.width, self.view.bounds.size.height - toolbarFrame.size.height };
    UIView *instructionsOverlay = [[[UIView alloc] initWithFrame:instructionsRect] autorelease];

    [_controlScheme setupEditorInstructions:instructionsOverlay];

    [self.view addSubview:instructionsOverlay];

    placeButtonsOverToolbar(toolbar, @[
            createToolbarButton(@"Save", self, @selector(closeButtonClicked:), is_iPad ? 110 : 50, is_iPad ? 55 : 30),
            createToolbarButton(@"Default", self, @selector(resetButtonClicked:), is_iPad ? 170 : 80, is_iPad ? 55 : 30),
            createToolbarButton(@"Cancel", self, @selector(cancelButtonClicked:), is_iPad ? 140 : 65, is_iPad ? 55 : 30),
    ]);
}

- (void)viewDidLoad {
    [super viewDidLoad];

    /* SHAME ON ME */ /* TODO: get rid of the shame */    
    CGRect b = self.view.bounds;
    CGFloat t = b.size.width;
    b.size.width = b.size.height;
    b.size.height = t;
    self.view.bounds = b;

    [self addBackground];

    [self loadSchemeConfig];

    [self addToolbar];

    [self addViewsForEditing];
}

static CGFloat
clampf(CGFloat v, CGFloat min, CGFloat max) {
    if (v < min) {
        return min;
    }
    if (v > max) {
        return max;
    }
    return v;
}

- (void)adjustViewPositions {
    CGRect bounds = self.view.bounds;
    for (UIView *v in _viewsForEditing) {
        CGRect frame = v.frame;
        frame.origin.x = clampf(frame.origin.x, 0, bounds.size.width - frame.size.width);
        frame.origin.y = clampf(frame.origin.y, 0, bounds.size.height - frame.size.height);
        v.frame = frame;
    }
}

- (void)resetButtonClicked:(id)resetButtonClicked {
    [gameConfig setSchemeConfig:_schemeName config:nil];
    [self loadSchemeConfig];
}

- (void)loadSchemeConfig {
    applySchemeConfig(_viewsForEditing, [gameConfig schemeConfig:_schemeName], gameConfig.leftHandedControls);
}

- (void)closeButtonClicked:(id)closeButtonClicked {
    [self saveConfig];
    CATransition* transition = [CATransition animation];
    transition.duration = 0.3;
    transition.type = kCATransitionFade;
    transition.subtype = kCATransitionFromTop;
    [self.navigationController.view.layer addAnimation:transition forKey:kCATransition];
    [self.navigationController popViewControllerAnimated:NO];
}

- (void)cancelButtonClicked:(id)sender {
    CATransition* transition = [CATransition animation];
    transition.duration = 0.3;
    transition.type = kCATransitionFade;
    transition.subtype = kCATransitionFromTop;
    [self.navigationController.view.layer addAnimation:transition forKey:kCATransition];
    [self.navigationController popViewControllerAnimated:NO];
}

- (void)saveConfig {
    [gameConfig setSchemeConfig:_schemeName config:schemeConfig(_viewsForEditing, gameConfig.leftHandedControls)];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (UIView *) viewAtPoint:(CGPoint)point {
    for (UIView *v in _viewsForEditing) {
        if (CGRectContainsPoint(v.frame, point)) {
            return v;
        }
    }
    return nil;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    if (touches.count == 1) {
        UITouch *touch = touches.anyObject;
        _draggingView = [self viewAtPoint:[touch locationInView:self.view]];
    }
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    if (_draggingView != nil) {
        UITouch *touch = touches.anyObject;
        CGPoint center = _draggingView.center;
        center.x += ([touch locationInView:self.view].x - [touch previousLocationInView:self.view].x);
        center.y += ([touch locationInView:self.view].y - [touch previousLocationInView:self.view].y);
        _draggingView.center = center;
    }
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    _draggingView = nil;
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
    _draggingView = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
    return (toInterfaceOrientation == UIInterfaceOrientationLandscapeLeft ||  toInterfaceOrientation == UIInterfaceOrientationLandscapeRight);
}

@end
