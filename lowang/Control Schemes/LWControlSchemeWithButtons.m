//
// Created by serge on 10/11/12.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import "LWControlSchemeWithButtons.h"


@implementation LWControlSchemeWithButtons {
    VCFreelook *_attackButton;
    VCFreelook *_useButton;
    VCFreelook *_jumpButton;
    VCFreelook *_crouchButton;
    VCFreelook *_weaponModeButton;
}

- (id) init {
    if ((self = [super init]) != nil) {
        CGRect rect;

        rect = CGRectMake(200, 200, 48, 48);
        _attackButton = [[VCFreelook alloc] initWithFrame:rect
                                           andNormalImage:[UIImage imageNamed:@"button_attack.png"]
                                      andHighlightedImage:nil];
        _attackButton.tag = kControlButtonAttack;
        _attackButton.delegate = self;
        [self addSubview:_attackButton];

        rect = CGRectMake(200, 200, 38, 38);
        _useButton = [[VCFreelook alloc] initWithFrame:rect
                                           andNormalImage:[UIImage imageNamed:@"button_use.png"]
                                      andHighlightedImage:nil];
        _useButton.tag = kControlButtonUse;
        _useButton.delegate = self;
        [self addSubview:_useButton];

        _jumpButton = [[VCFreelook alloc] initWithFrame:rect
                                         andNormalImage:[UIImage imageNamed:@"button_jump.png"]
                                    andHighlightedImage:nil];
        _jumpButton.tag = kControlButtonJump;
        _jumpButton.delegate = self;
        [self addSubview:_jumpButton];

        _crouchButton = [[VCFreelook alloc] initWithFrame:rect
                                           andNormalImage:[UIImage imageNamed:@"button_crouch.png"]
                                      andHighlightedImage:nil];
        _crouchButton.tag = kControlButtonCrouch;
        _crouchButton.delegate = self;
        [self addSubview:_crouchButton];


        _weaponModeButton = [[VCFreelook alloc] initWithFrame:rect
                                           andNormalImage:[UIImage imageNamed:@"button_weaponmode.png"]
                                      andHighlightedImage:nil];
        _weaponModeButton.tag = kControlButtonWeaponMode;
        _weaponModeButton.delegate = self;
        [self addSubview:_weaponModeButton];
    }
    return self;
}

- (void)dealloc {
    [_attackButton release];
    [_useButton release];
    [_jumpButton release];
    [_crouchButton release];
    [_weaponModeButton release];
    [super dealloc];
}

- (NSArray *)viewsForEditing {
    return @[ _attackButton, _useButton, _jumpButton, _crouchButton, _weaponModeButton ];
}

@end