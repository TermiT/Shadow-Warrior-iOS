//
//  LWHardcodedScheme.m
//  lowang
//
//  Created by termit on 10/26/12.
//
//



#import "LWHardcodedScheme.h"
#import "VCFreelook.h"
#import "VCStick.h"
#include "iphone_input.h"
#import "LWGameController.h"
#import "LWGameInstance.h"


@implementation LWHardcodedScheme {
    VCFreelook * freelook;
    VCFreelook * fireButton;
    VCStick *  moveStick;
    VCFreelook * openDoorButton;
    VCFreelook * jumpButton;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        // Initialization code
        [self addVirtualControlstoView: self];
    }
    return self;
}

- (void)addVirtualControlstoView:(UIView *)view {
    
    // Move Sticks
    
    CGPoint speedLimit = { 10000000, 1000000 };
    
    CGFloat moveStickOffset = 60.0;
    CGFloat moveStickSize = 100.0;
    CGRect  moveStickFrame = CGRectMake(moveStickOffset, 0, moveStickSize, moveStickSize);
    moveStickFrame.origin.y = view.frame.size.height - moveStickOffset - moveStickFrame.size.height;
    moveStick = [[VCStick alloc] initStickWithFrame:moveStickFrame withStickType:VCStickTypeStatic andMaxOffset:50 andThumbRadius:45 andBackground:[UIImage imageNamed:@"VCStickBackground.png"] andThumb:[UIImage imageNamed:@"VCStickThumb.png"]];
    moveStick.deadZone = CGPointMake(0, 0);
    moveStick.delegate = self;
    moveStick.tag = 3001;
    
    // Freelook
    CGRect freelookFrame = CGRectMake(0, 0, view.frame.size.width, view.frame.size.height);
    freelook = [[VCFreelook alloc] initWithFrame:freelookFrame andNormalImage:nil andHighlightedImage:nil];
    freelook.speedLimit = speedLimit;
    freelook.delegate = self;
    
    // Fire button
    const CGFloat fireButtonOffset = 70.0;
    const CGFloat fireButtonSize = 92.0;
    
    CGRect buttonFrame = CGRectMake(0, 0, fireButtonSize, fireButtonSize);
    buttonFrame.origin.y = view.frame.size.height - fireButtonOffset - buttonFrame.size.height;
    buttonFrame.origin.x = view.frame.size.width - fireButtonOffset- buttonFrame.size.width;
    
    
    fireButton = [[VCFreelook alloc] initWithFrame:buttonFrame andNormalImage:[UIImage imageNamed:@"VCStickThumb.png"] andHighlightedImage:[UIImage imageNamed:@"VCStickThumb.png"]];
    fireButton.delegate = self;
    fireButton.speedLimit = speedLimit;
    fireButton.alpha = 0.5;
    fireButton.tag = 3002;
    
    
    // Jump Button
    const CGFloat jumpButtonXOffset = 70.0;
    const CGFloat jumpButtonYOffset = 10.0;
    const CGFloat jumoButtonSize = 92.0;
    
    CGRect jumpButtonFrame = CGRectMake(0, 0, fireButtonSize, fireButtonSize);
    jumpButtonFrame.origin.y = view.frame.size.height - jumpButtonXOffset - jumpButtonFrame.size.height;
    jumpButtonFrame.origin.x = view.frame.size.width - jumpButtonYOffset- jumpButtonFrame.size.width;
    
    jumpButton = [[VCFreelook alloc] initWithFrame:jumpButtonFrame andNormalImage:[UIImage imageNamed:@"VCStickThumb.png"] andHighlightedImage:[UIImage imageNamed:@"VCStickThumb.png"]];
    jumpButton.delegate = self;
    jumpButton.alpha = 0.5;
    jumpButton.tag = 3003;
    
    // Open door button
    CGRect openDoorButtonFrame = CGRectMake(0, 0, view.frame.size.width/3, view.frame.size.height/3);
    
    
    openDoorButton = [[VCFreelook alloc] initWithFrame:openDoorButtonFrame andNormalImage:nil andHighlightedImage:nil];
    
    openDoorButton.center = CGPointMake(view.frame.size.width/2, view.frame.size.height/2);
    openDoorButton.speedLimit = speedLimit;
    openDoorButton.delegate = self;
    
    
    [view addSubview:freelook];
    [view addSubview:moveStick];
    [view addSubview:fireButton];
    [view addSubview:openDoorButton];
    [view addSubview:jumpButton];
    
    //TEST code
    
        UIButton * button = [[UIButton buttonWithType:UIButtonTypeRoundedRect] retain];
        [button setFrame:CGRectMake(200, 20, 50, 20)];
        [button setTitle:[NSString stringWithFormat:@"cheat"] forState:UIControlStateNormal];
        [button addTarget:self action:@selector(cheat:) forControlEvents:UIControlEventTouchUpInside];
        [button setAlpha:0.5];
        [view addSubview:button];
        [button release];
    
}

- (void)didChangeOffset:(id)sender withNormalizedOffset:(CGPoint)normalizedOffset {
    //    extern long *joyaxis;
    //    joyaxis[0] = (long)(normalizedOffset.x * JOYSTICK_RANGE);
    //    joyaxis[1] = (long)(normalizedOffset.y * JOYSTICK_RANGE * 2);
    iphone_input.movestick_x = normalizedOffset.x;
    iphone_input.movestick_y = normalizedOffset.y;
}

- (void)didMove:(id)sender withOffset:(CGPoint)offset {
    //    extern long mousex;
    //    extern long mousey;
    //
    ////    if (sender == freelook) {
    //        mousex += (long)(offset.x * MOUSE_SENS_X);
    //        mousey += (long)(offset.y * MOUSE_SENS_Y);
    ////    }
    iphone_input.freelook_x += offset.x;
    iphone_input.freelook_y += offset.y;
}

- (void)didChangeState:(id)sender isPressed:(BOOL)pressed {
    extern long joyb;
    if (sender == fireButton) {
        if (pressed) {
            joyb |= (1 << 13);
            fireButton.alpha = 1.0;
        } else {
            joyb &= ~(1 << 13);
            fireButton.alpha = 0.5;
        }
    } else if (sender == openDoorButton){
        if (pressed) {
            joyb |= (1 << 3);
        } else {
            joyb &= ~(1 << 3);
        }
    } else if (sender == jumpButton) {
        if (pressed) {
            joyb |= (1 << 2);
            jumpButton.alpha = 1.0;
        } else {
            joyb &= ~(1 << 2);
            jumpButton.alpha = 0.5;
        }
        player_info_t *p = [gameInstance playerInfo];
        [gameInstance setButton:gamefunc_Weapon_1+p->weapon value:pressed];
    }
}

- (void)cheat:(id)sender {
    [self applyCheat];
    
}

- (void)applyCheat {
    extern void HealthRefill(void);
    CFRunLoopPerformBlock(gameRunLoop, (CFTypeRef) kCFRunLoopCommonModes, ^{
        HealthRefill();
        extern int GodMode;
        GodMode = 1;

    });
}

- (NSArray *)viewsForEditing {
    return @[ fireButton, jumpButton, moveStick ];
}

- (UIImage *)editorBackground {
    return [UIImage imageNamed:@"hud_medkit.png"];
}

- (NSString *)schemeName {
    return @"HardcodedControlScheme";
}

@end
