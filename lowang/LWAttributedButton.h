//
//  LWAttributedButton.h
//  lowang
//
//  Created by termit on 10/26/12.
//
//

#import <UIKit/UIKit.h>

@interface LWAttributedButton : UIButton
@property (retain, nonatomic) NSNumber *levelNumber;
@property (retain, nonatomic) NSString *fontName;
@property (retain, nonatomic) NSNumber *fontSize;

- (void)applyAttributes;


@end
