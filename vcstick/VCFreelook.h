//
//  VCFreelook.h
//  VCFreelook
//
//  Created by Gennadiy Potapov on 24/10/11.
//  
//

#import <UIKit/UIKit.h>
@protocol VCFreelookDelegate <NSObject>
@optional
    - (void)didMove:(id)sender withOffset:(CGPoint)offset;
    - (void)didChangeState:(id)sender isPressed:(BOOL)pressed;
@end


@interface VCFreelook : UIView {
    id<VCFreelookDelegate> delegate;
@private
    UIImageView *background;
}

@property (assign, nonatomic) id<VCFreelookDelegate> delegate;
@property (assign, nonatomic) CGPoint speedLimit;

- (id)initWithFrame:(CGRect)frame andNormalImage:(UIImage*)normal andHighlightedImage:(UIImage*)highlighted;

- (void)resetState;


@end
