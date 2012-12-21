//
// Created by serge on 10/11/12.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import "LWControlSchemeScreenTap.h"
#import "LWControlScheme+Splitter.h"


@implementation LWControlSchemeScreenTap {
    VCStick *_moveStick;
    VCFreelook *_aimArea;
}

- (id) init {
    if ((self = [super init]) != nil) {
        CGRect rect;

        rect = CGRectMake(0, 0, screenSize.width/2, screenSize.height);
        _moveStick = [[VCStick alloc] initStickWithFrame:rect
                                           withStickType:VCStickTypeDynamic
                                            andMaxOffset:50
                                          andThumbRadius:45
                                           andBackground:[UIImage imageNamed:@"stick_base.png"]
                                                andThumb:[UIImage imageNamed:@"stick_thumb.png"]];
        _moveStick.tag = kControlStickMove;
        _moveStick.delegate = self;
        [self insertSubview:_moveStick atIndex:0];

        rect = CGRectMake(screenSize.width/2, 0, screenSize.width/2, screenSize.height);
        _aimArea = [[VCFreelook alloc] initWithFrame:rect];
        _aimArea.tag = kControlAreaAim;
        _aimArea.delegate = self;
        [self insertSubview:_aimArea atIndex:0];
    }
    return self;
}

- (void)dealloc {
    [_moveStick release];
    [_aimArea release];
    [super dealloc];
}

- (UIImage *)editorBackground {
    return [UIImage imageNamed:@""];
}

- (NSString *)schemeName {
    return @"ScreenTap";
}

- (void) setTransparency:(CGFloat)alpha {
    [super setTransparency:alpha];
    _moveStick.alpha = alpha;
}

- (void)setupEditorInstructions:(UIView *)instructionsView {
    [self setupInstructionsOverlay:instructionsView leftAreaName:@"Move" rightAreaName:@"Aim"];
}

@end
