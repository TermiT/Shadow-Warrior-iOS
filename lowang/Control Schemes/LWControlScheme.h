//
//  LWControlScheme.h
//  lowang
//
//  Created by termit on 10/26/12.
//
//

#import <UIKit/UIKit.h>
#import "LWMenuView.h"

enum {
    /* editable inventoryItems */

    kControlButtonAttack = 1001,
    kControlButtonUse = 1002,
    kControlButtonJump = 1003,
    kControlButtonCrouch = 1004,
    kControlButtonWeaponMode = 1005,
    kControlStickMove = 1006,
    kControlStickAim = 1007,

    /* static inventoryItems */
    kControlAreaAim = 2001,
    kControlAreaMove = 2002,
};

@interface LWControlScheme : UIView <VCFreelookDelegate, VCStickDelegate> ;

@property (retain, nonatomic) LWGameController *gameController;

- (void)updateView;

- (NSArray*)viewsForEditing;
- (NSString*)schemeName;

- (void) setTransparency:(CGFloat)alpha;

- (void) setupEditorInstructions:(UIView*)instructionsView;

@end
