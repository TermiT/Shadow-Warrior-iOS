//
//  LWGameSelectMenu.m
//  lowang
//
//  Created by termit on 12/22/12.
//
//

#import "LWGameSelectMenu.h"
#import "LWAttributedButton.h"
#include "iphone_api.h"
#import <QuartzCore/QuartzCore.h>

@implementation LWGameSelectMenu
@synthesize game;
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)awakeFromNib {
    for (LWAttributedButton * button in _bannerButtons) {
        button.layer.cornerRadius = 13;
        button.layer.masksToBounds = YES;
    }

}

- (IBAction)gameButtonClicked:(id)sender {
    game = [((LWAttributedButton *)sender).numberValue unsignedIntValue];
    NSString *featureID = [self.gameController futureIDForGameType:game];
    if (game != GAME_SHADOW_WARRIOR) {
        if ([self.gameController isFeaturePurchased:featureID]) {
            [self.gameController downloadBundle:featureID finished:^{
                [self.gameController presentSkillSelectMenu];
            }];
        } else {
            [self.gameController presentStoreView:game];
        }
    } else {
        [self.gameController presentSkillSelectMenu];
    }
    
    
}

- (void)dealloc {
    [_bannerButtons release];
    [super dealloc];
}
@end
