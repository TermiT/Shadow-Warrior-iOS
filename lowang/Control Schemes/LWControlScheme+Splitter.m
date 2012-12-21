//
// Created by serge on 30/11/12.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import "LWControlScheme+Splitter.h"
#import "LWHudLabel.h"

@implementation LWControlScheme (Splitter)

static
UILabel *createAreaLabel(NSString *text) {
    UILabel *label = [[[UILabel alloc] init] autorelease];
    label.text = text;
    label.numberOfLines = 0;
    label.font = [UIFont fontWithName:@"Bonzai" size:60];
    label.textColor = [UIColor whiteColor];
    label.backgroundColor = [UIColor clearColor];
    label.alpha = 0.16;
    [label sizeToFit];
    return label;
}

- (void)setupInstructionsOverlay:(UIView *)instructionsOverlay leftAreaName:(NSString *)leftAreaName rightAreaName:(NSString *)rightAreaName {
    UIView *splitter = [[[UIView alloc] initWithFrame:CGRectMake(0, 0, is_iPad ? 4 : 2, instructionsOverlay.bounds.size.height)] autorelease];
    [instructionsOverlay addSubview:splitter];
    splitter.center = CGPointMake(instructionsOverlay.bounds.size.width/2, instructionsOverlay.bounds.size.height/2);
    splitter.backgroundColor = [UIColor whiteColor];
    splitter.alpha = 0.7;

    if (leftAreaName != nil) {
        UILabel *leftAreaLabel = createAreaLabel(leftAreaName);
        [instructionsOverlay addSubview:leftAreaLabel];
        leftAreaLabel.center = CGPointMake(( gameConfig.leftHandedControls ? 0.75 : 0.25 ) * instructionsOverlay.bounds.size.width, instructionsOverlay.bounds.size.height * 0.5);
    }

    if (rightAreaName != nil) {
        UILabel *rightAreaLabel = createAreaLabel(rightAreaName);
        [instructionsOverlay addSubview:rightAreaLabel];
        rightAreaLabel.center = CGPointMake(( gameConfig.leftHandedControls ? 0.25 : 0.75 ) * instructionsOverlay.bounds.size.width, instructionsOverlay.bounds.size.height * 0.5);
    }
}

@end