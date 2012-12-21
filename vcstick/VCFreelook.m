//
//  VCFreelook.m
//  VCFreelook
//
//  Created by Gennadiy Potapov on 24/10/11.
//  
//

#import "VCFreelook.h"
#import <QuartzCore/QuartzCore.h>

@implementation VCFreelook
@synthesize delegate;
@synthesize speedLimit;


- (id)initWithFrame:(CGRect)frame andNormalImage:(UIImage*)normal andHighlightedImage:(UIImage*)highlighted {
    self = [super initWithFrame:frame];
    if (self) {
        speedLimit = CGPointMake(10000, 10000);
        self.backgroundColor = [UIColor clearColor];
        background = [[UIImageView alloc] initWithImage:normal highlightedImage:highlighted];
        background.center = CGPointMake(self.frame.size.width/2, self.frame.size.height/2);
        background.userInteractionEnabled = NO;
        background.contentMode = UIViewContentModeCenter;
        [self addSubview:background];
        [background release];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        speedLimit = CGPointMake(10000, 10000);
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}

-(id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}

- (void)dealloc {
    [super dealloc];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    if (background) {
        if (background.highlightedImage != nil) {
            background.highlighted = YES;
        } else {
            background.layer.shadowColor = [UIColor yellowColor].CGColor;
            background.layer.shadowRadius = 3;
            background.layer.shadowOffset = CGSizeMake(0, 0);
            background.layer.shadowOpacity = 1;
        }
    }
    
    if ([delegate respondsToSelector:@selector(didChangeState:isPressed:)])
        [delegate didChangeState:self isPressed:YES];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    UITouch *touch = [touches anyObject];
    CGPoint previous = [touch previousLocationInView:self];
    CGPoint current = [touch locationInView:self];
    CGPoint offset = CGPointMake(current.x-previous.x, current.y-previous.y);
    
    if (offset.x > speedLimit.x) {
        offset.x = speedLimit.x;
    }
    if (offset.x < -speedLimit.x) {
        offset.x = -speedLimit.x;
    }
    if (offset.y > speedLimit.y) {
        offset.y = speedLimit.y;
    }
    if (offset.y < -speedLimit.y) {
        offset.y = -speedLimit.y;
    }
    
    if ([delegate respondsToSelector:@selector(didMove:withOffset:)])
        [delegate didMove:self withOffset:offset];
}


- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    [self cancelTouches];
}

- (void)cancelTouches {
    if (background) {
        if (background.highlightedImage != nil) {
            background.highlighted = NO;
        } else {
            background.layer.shadowColor = [UIColor clearColor].CGColor;
            background.layer.shadowRadius = 0;
            background.layer.shadowOffset = CGSizeMake(0, 0);
            background.layer.shadowOpacity = 0;
        }

    }
    if ([delegate respondsToSelector:@selector(didChangeState:isPressed:)])
        [delegate didChangeState:self isPressed:NO];
}

- (void)resetState {
    [self cancelTouches];
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
    [self touchesEnded:touches withEvent:event];
}

@end
