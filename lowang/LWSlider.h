//
//  LWSlider.h
//  lowang
//
//  Created by serge on 18/11/12.
//
//

#import <UIKit/UIKit.h>

@interface LWSlider : UIControl

- (void)applyAttributes;

@property (assign) float value;

@property (nonatomic, retain) NSString *text;
@property (nonatomic, retain) NSString *fontName;
@property (nonatomic, retain) NSNumber *fontSize;
@property (nonatomic, retain) UIColor *fullColor;
@property (nonatomic, retain) UIColor *emptyColor;
@property (nonatomic, retain) NSNumber *labelOffset;
@property (nonatomic, retain) NSString *fullImageName;
@property (nonatomic, retain) NSString *emptyImageName;

@end
