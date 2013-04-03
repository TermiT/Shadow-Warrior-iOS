//
//  LWStoreView.h
//  lowang
//
//  Created by termit on 12/4/12.
//
//

#import "LWMenuView.h"
#import "LWAttributedButton.h"
#import "LWHudLabel.h"

@interface LWStoreView : LWMenuView
@property (nonatomic, assign) NSUInteger selectedFeatureIndex;

@property (retain, nonatomic) IBOutletCollection(LWAttributedButton) NSArray *bannersButtons;
@property (retain, nonatomic) IBOutlet LWHudLabel *featureTitle;
@property (retain, nonatomic) IBOutlet UITextView *featureDescription;

@end
