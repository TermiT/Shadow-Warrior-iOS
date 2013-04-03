//
//  LWGameSelectMenu.h
//  lowang
//
//  Created by termit on 12/22/12.
//
//

#import "LWMenuView.h"
#import "LWAttributedButton.h"

@interface LWGameSelectMenu : LWMenuView
@property (nonatomic, readonly) NSUInteger game;
@property (retain, nonatomic) IBOutletCollection(LWAttributedButton) NSArray *bannerButtons;

@end
