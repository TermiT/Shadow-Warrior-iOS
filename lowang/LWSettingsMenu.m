//
//  LWSettingsMenu.m
//  lowang
//
//  Created by termit on 10/24/12.
//
//

#import "LWSettingsMenu.h"
#import "LWSlider.h"
#import "LWSwitch.h"
#import "LWHudLabel.h"

@implementation LWSettingsMenu {
    IBOutlet LWSwitch *musicSwitch;
    IBOutlet LWSwitch *crosshairSwitch;
    IBOutlet LWSwitch *voxelsSwitch;
    IBOutlet LWSwitch *retroGraphicsSwitch;
    IBOutlet LWSwitch *weaponAutoSwitch;
    IBOutlet LWSlider *transparencySlider;    
    IBOutlet LWHudLabel *voxelsLabel;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void) updateView {
    transparencySlider.value = (gameConfig.hudTransparency-0.1)/0.9;
    musicSwitch.on = gameConfig.enableMusic;
    crosshairSwitch.on = gameConfig.enableCrosshair;
    voxelsSwitch.on = gameConfig.enableVoxels;
    retroGraphicsSwitch.on = gameConfig.enableRetroGraphics;
    weaponAutoSwitch.on = gameConfig.enableWeaponAutoSwitch;

    voxelsLabel.hidden = !is_hiEnd;
    voxelsSwitch.hidden = !is_hiEnd;

    if (!is_hiEnd) {
        gameConfig.enableVoxels = NO;
    }
}

- (IBAction)hudTransparencyChanged:(id)sender {
    gameConfig.hudTransparency = transparencySlider.value*0.9+0.1;
}

- (IBAction)musicSwitchChanged:(id)sender {
    gameConfig.enableMusic = musicSwitch.on;
    [gameInstance updateGameSettings];
}

- (IBAction)crosshairSwitchChanged:(id)sender {
    gameConfig.enableCrosshair = crosshairSwitch.on;
    [gameInstance updateGameSettings];
}
- (IBAction)voxelsSwitchChanged:(id)sender {
    gameConfig.enableVoxels = voxelsSwitch.on;
    [gameInstance updateGameSettings];
}

- (IBAction)retroGraphicsSwitchChanged:(id)sender {
    gameConfig.enableRetroGraphics = retroGraphicsSwitch.on;
    [gameInstance updateGameSettings];
}
- (IBAction)weaponAutoSwitchChanged:(id)sender {
    gameConfig.enableWeaponAutoSwitch = weaponAutoSwitch.on;
    [gameInstance updateGameSettings];
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
    [musicSwitch release];
    [crosshairSwitch release];
    [transparencySlider release];
    [voxelsSwitch release];
    [retroGraphicsSwitch release];
    [weaponAutoSwitch release];
    [voxelsLabel release];
    [super dealloc];
}
@end
