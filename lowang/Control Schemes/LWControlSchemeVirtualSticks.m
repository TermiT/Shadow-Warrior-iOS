//
// Created by serge on 13/11/12.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import "LWControlSchemeVirtualSticks.h"


@implementation LWControlSchemeVirtualSticks {
    VCStick *_moveStick;
    VCStick *_aimStick;
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
        [self addSubview:_moveStick];

        rect = CGRectMake(600, 200, 100, 100);
        _aimStick = [[VCStick alloc] initStickWithFrame:rect
                                           withStickType:VCStickTypeStatic
                                            andMaxOffset:50
                                          andThumbRadius:45
                                           andBackground:[UIImage imageNamed:@"stick_base.png"]
                                                andThumb:[UIImage imageNamed:@"stick_thumb.png"]];
        _aimStick.tag = kControlStickAim;
        _aimStick.delegate = self;
        [self addSubview:_aimStick];

    }
    return self;
}

- (void)dealloc {
    [_moveStick release];
    [_aimStick release];
    [super dealloc];
}

- (UIImage *)editorBackground {
    return [UIImage imageNamed:@""];
}

- (NSArray *)viewsForEditing {
    return [[super viewsForEditing] arrayByAddingObjectsFromArray:@[_moveStick, _aimStick]];
}

- (NSString *)schemeName {
    return @"VirtualSticks";
}

@end
