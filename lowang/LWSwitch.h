//
// Created by serge on 21/11/12.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import <Foundation/Foundation.h>


@interface LWSwitch : UIControl

@property (assign, nonatomic) BOOL on;

@property (retain, nonatomic) UIImage *covering;
@property (retain, nonatomic) UIImage *slider;
@property (retain, nonatomic) UIImage *tip;

/* to be configured using User Runtime Attributes from within IB */
@property (retain, nonatomic) NSString *coveringImageName;
@property (retain, nonatomic) NSString *sliderImageName;
@property (retain, nonatomic) NSString *tipImageName;

@end