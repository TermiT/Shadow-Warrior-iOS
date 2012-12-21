//
// Created by serge on 11/11/12.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import "LWControlSchemeClassic.h"
#import "LWControlScheme+Splitter.h"

@implementation LWControlSchemeClassic {
    VCStick *_moveStick;
    VCFreelook *_aimArea;
}

- (id) init {
    if ((self = [super init]) != nil) {
        CGRect rect;
        
        rect = CGRectMake(300, 200, 100, 100);
        _moveStick = [[VCStick alloc] initStickWithFrame:rect
                                           withStickType:VCStickTypeStatic
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

- (NSArray *)viewsForEditing {
    return [[super viewsForEditing] arrayByAddingObject:_moveStick];
}

- (NSString *)schemeName {
    return @"Classic";
}

- (void)setupEditorInstructions:(UIView *)instructionsView {
    [self setupInstructionsOverlay:instructionsView leftAreaName:@"Move" rightAreaName:@"Aim"];
}

@end
