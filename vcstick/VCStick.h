//
//  VCStick.h
//  controlls
//
//  Created by Serge Shubin, Gennadiy Potapov on 22/10/11.
//  General Arcade
//

#import <UIKit/UIKit.h>

typedef enum {
    VCStickTypeStatic,
    VCStickTypeDynamic
} VCStickType;

@protocol VCStickDelegate <NSObject> 
@optional
- (void)didChangeOffset:(id)sender withNormalizedOffset:(CGPoint)normalizedOffset;
@end

@interface VCStick : UIView {
    VCStickType stickType;
    CGPoint offset;
    CGFloat maxOffset;
    CGPoint deadZone;
    CGFloat thumbRadius;
    id <VCStickDelegate> delegate;
@private
    CGPoint initialTouch;
    BOOL isTouched;
    CGPoint thumbCenter;
    UIImageView *thumb;
    UIImageView *background;
}
@property (readonly, nonatomic) VCStickType stickType;
@property (readonly, nonatomic) CGPoint offset;
@property (readonly, nonatomic) CGFloat maxOffset;
@property (assign, nonatomic) CGPoint deadZone;
@property (readonly, nonatomic) CGFloat thumbRadius;
@property (getter = getNormalizedOffset, readonly, nonatomic) CGPoint normalizedOffset;
@property (assign, nonatomic) id <VCStickDelegate> delegate; 

- (id)initStickWithFrame:(CGRect)frame withStickType:(VCStickType)_stickType andMaxOffset:(CGFloat)_maxOffset andThumbRadius:(CGFloat)_thumbRadius andBackground:(UIImage*)_background andThumb:(UIImage*)_thumb;

- (void)resetState;


@end