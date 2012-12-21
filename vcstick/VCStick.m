//
//  VCStick.m
//  controlls
//
//  Created by Serge Shubin, Gennadiy Potapov on 22/10/11.
//  General Arcade
//

#import "VCStick.h"

static CGFloat distance(CGPoint a, CGPoint b) {
    return sqrtf( (a.x-b.x)*(a.x-b.x) + (a.y-b.y)*(a.y-b.y) );
}

@implementation VCStick
@synthesize offset, maxOffset, deadZone, thumbRadius, stickType, delegate;

- (id)initStickWithFrame:(CGRect)frame withStickType:(VCStickType)_stickType andMaxOffset:(CGFloat)_maxOffset andThumbRadius:(CGFloat)_thumbRadius andBackground:(UIImage*)_background andThumb:(UIImage*)_thumb {
    self = [super initWithFrame:frame];
        if (self) {
        maxOffset = _maxOffset;
        stickType = _stickType;
        thumbRadius = _thumbRadius;
        
        self.backgroundColor = [UIColor clearColor];
            
        thumbCenter = CGPointMake(self.frame.size.width/2, self.frame.size.height/2);    
            
        background = [[UIImageView alloc] initWithImage:_background];
        background.backgroundColor = [UIColor clearColor];
        background.userInteractionEnabled = NO;
        background.center = thumbCenter;
        [self addSubview:background];
        [background release];
        
        thumb = [[UIImageView alloc] initWithImage:_thumb];
        thumb.backgroundColor = [UIColor clearColor];
        thumb.userInteractionEnabled = NO;
        thumb.center = thumbCenter;
        [self addSubview:thumb];
        [thumb release];
        
        if (stickType == VCStickTypeDynamic) {
            background.hidden = YES;
            thumb.hidden = YES;
        }
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self initStickWithFrame:self.frame withStickType:VCStickTypeStatic andMaxOffset:50 andThumbRadius:45 andBackground:[UIImage imageNamed:@"VCStickBackground.png"] andThumb:[UIImage imageNamed:@"VCStickThumb.png"]];
    }
    return self;
}

- (void)callDelegate {
    if([delegate respondsToSelector:@selector(didChangeOffset:withNormalizedOffset:)])
        [delegate didChangeOffset:self withNormalizedOffset:self.normalizedOffset];
}

- (void) update {
    if (self.stickType == VCStickTypeDynamic) {
        thumb.hidden = !isTouched;
        background.hidden = !isTouched;
        thumbCenter = initialTouch;
    }
    [thumb setCenter:CGPointMake(thumbCenter.x + offset.x, thumbCenter.y + offset.y)];
    [background setCenter:thumbCenter];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    UITouch *touch = [touches anyObject];
    CGPoint touchLocation = [touch locationInView:self];
    CGPoint center = CGPointMake(self.frame.size.width/2, self.frame.size.height/2);
    if (stickType == VCStickTypeDynamic || (stickType == VCStickTypeStatic && distance(touchLocation, center) < thumbRadius)) {
        initialTouch = touchLocation;
        isTouched = YES;
        [self update];
    }
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    UITouch *touch = [touches anyObject];
    
    if (isTouched) {
        CGPoint currentTouch = [touch locationInView:self];
        CGFloat r = distance(initialTouch, currentTouch);
        if (r > maxOffset) {
            CGFloat k = maxOffset/r;
            currentTouch.x = initialTouch.x + k*(currentTouch.x - initialTouch.x);
            currentTouch.y = initialTouch.y + k*(currentTouch.y - initialTouch.y);
        }
        offset.x = currentTouch.x - initialTouch.x;
        offset.y = currentTouch.y - initialTouch.y;
        [self callDelegate];
        [self update];
    }
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    [self cancelTouches];
}

- (void)cancelTouches {
    offset.x = 0.0;
    offset.y = 0.0;
    isTouched = NO;
    [self callDelegate];
    [self update];
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
    [self touchesEnded:touches withEvent:event];
}

- (void)resetState {
    [self cancelTouches];
}

- (CGPoint)getNormalizedOffset {
    CGPoint off = offset;
    
    if (fabs(off.x) < deadZone.x) {
        off.x = 0.0;
    } else {
        off.x -= deadZone.x;
    }
    if (fabs(off.y) < deadZone.y) {
        off.y = 0.0;
    } else {
        off.y -= deadZone.y;
    }
    
    return CGPointMake(off.x/(maxOffset - deadZone.x), off.y/(maxOffset - deadZone.y));
}

@end
