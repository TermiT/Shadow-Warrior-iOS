//
//  AppDelegate.h
//  lowang
//
//  Created by automation on 15/8/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "VCStick.h"
#import "VCFreelook.h"
#import "LWGameController.h"


@interface AppDelegate : UIResponder <UIApplicationDelegate, VCStickDelegate, VCFreelookDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) UIViewController *gameViewController;
@property (strong, nonatomic) LWGameController *gameController;


@end
