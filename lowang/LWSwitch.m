//
// Created by serge on 21/11/12.
//
// To change the template use AppCode | Preferences | File Templates.
//

#import <QuartzCore/QuartzCore.h>
#import "LWSwitch.h"
#import "compat.h"

#define DRAG_THRESHOLD 10
#define TOUCH_THRESHOLD 0.3

@implementation LWSwitch {

@private
    BOOL _on;

    UIView *_mask;
    
    UIImageView *_coveringView;
    UIImageView *_sliderView;
    UIImageView *_tipView;

    NSString *_coveringImageName;
    NSString *_sliderImageName;
    NSString *_tipImageName;

    CGSize sliderBounds, tipBounds;
    CGFloat sliderPosMin, sliderPosMax;
    CGFloat tipWidth;
    CGFloat tipOffset;

    CGFloat trackingStartPosition;
    CGFloat trackingStartSliderX;

    BOOL trackDragging; /* YES - track dragging, NO - track clicking */
    NSTimeInterval touchDownTime;
}

@synthesize coveringImageName = _coveringImageName;
@synthesize sliderImageName = _sliderImageName;
@synthesize tipImageName = _tipImageName;


- (void) recalculateTipMetrics {
    CGSize viewSize = self.bounds.size;
    CGSize coveringSize = _coveringView.image.size;
    CGSize sliderSize = _sliderView.image.size;
    CGSize tipSize = _tipView.image.size;

    CGFloat coveringToViewScaleX = viewSize.width/coveringSize.width;

    CGFloat sliderToCoveringScale = sliderSize.height/coveringSize.height;
    CGFloat tipToCoveringScale = tipSize.height / coveringSize.height;

    sliderBounds.width = sliderSize.width * sliderToCoveringScale * coveringToViewScaleX;
    sliderBounds.height = viewSize.height;

    tipWidth = tipSize.width * tipToCoveringScale * coveringToViewScaleX;
    tipOffset = (sliderBounds.width-tipWidth)/2;

    sliderPosMax = 0;
    sliderPosMin = viewSize.width - sliderBounds.width;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self initControl];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    if ((self = [super initWithCoder:aDecoder]) != nil) {
        [self initControl];
    }
    return self;
}

- (void) initControl {
    self.clipsToBounds = YES;
    
    _mask = [[UIView alloc] init];
    
    _coveringView = [[UIImageView alloc] init];
    _sliderView = [[UIImageView alloc] init];
    _tipView = [[UIImageView alloc] init];
    _coveringView.frame = self.bounds;
    
    _mask.userInteractionEnabled = NO;
    
    [_mask addSubview:_sliderView];
    
    [self addSubview:_mask];
    
    
    [self addSubview:_coveringView];
    _coveringView.hidden = YES;
    [self addSubview:_tipView];
}

- (void)awakeFromNib {
    self.covering = [UIImage imageNamed:_coveringImageName];
    self.slider = [UIImage imageNamed:_sliderImageName];
    self.tip = [UIImage imageNamed:_tipImageName];
    if (self.covering == nil) {
        self.covering = [UIImage imageNamed:@"switch-covering.png"];
    }
    if (self.slider == nil) {
        self.slider = [UIImage imageNamed:@"switch-slider.png"];
    }
    if (self.tip == nil) {
        self.tip = [UIImage imageNamed:@"switch-tip.png"];
    }

    [self adjustPositionsForState:self.on];
    
//    self.layer.cornerRadius = self.bounds.size.height / 2.0f;
//    self.layer.masksToBounds = YES;
//    self.layer.borderWidth = 2;
//    self.layer.borderColor = [UIColor colorWithRed:75/255.0 green:0 blue:1/255.0 alpha:1].CGColor;
//    _coveringView.alpha = 0;
    
    _mask.layer.cornerRadius = self.bounds.size.height / 2.0f;
    _mask.layer.masksToBounds = YES;
    _mask.layer.borderWidth = 2;
    _mask.layer.borderColor = [UIColor colorWithRed:75/255.0 green:0 blue:1/255.0 alpha:1].CGColor;

    _tipView.layer.cornerRadius = self.bounds.size.height / 2.0f;
    _tipView.layer.masksToBounds = YES;
    _tipView.layer.borderWidth = 1;
    _tipView.layer.borderColor = [UIColor colorWithRed:75/255.0 green:0 blue:1/255.0 alpha:1].CGColor;

//    _tipView.alpha = 0;
//    _sliderView.alpha = 0;
    
}

- (void)adjustPositionsForState:(BOOL)on {
    [self recalculateTipMetrics];
    _sliderView.frame = CGRectMake(on? sliderPosMax : sliderPosMin, 0, sliderBounds.width, sliderBounds.height);
    CGRect rc = CGRectMake(_sliderView.frame.origin.x+tipOffset, 0, tipWidth, self.bounds.size.height);
    _tipView.frame = rc;
    
    _mask.frame = self.bounds;
}

- (BOOL)on {
    return _on;
}

- (void)setOn:(BOOL)on {
    _on = on;
    [self adjustPositionsForState:_on];
}

- (UIImage *)covering {
    return _coveringView.image;
}

- (void)setCovering:(UIImage *)covering {
    _coveringView.image = covering;
}

- (UIImage *)slider {
    return _sliderView.image;
}

- (void)setSlider:(UIImage *)slider {
    _sliderView.image = slider;
}

- (UIImage *)tip {
    return _tipView.image;
}

- (void)setTip:(UIImage *)tip {
    _tipView.image = tip;
}

- (void)dealloc {
    [_coveringImageName release];
    [_sliderImageName release];
    [_coveringView release];
    [_sliderView release];
    [_tipImageName release];
    [_tipView release];
    [_mask release];
    [super dealloc];
}

- (BOOL)beginTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event {
    CGPoint locationOnTip = [touch locationInView:_sliderView];
    CGFloat dist = fabsf(locationOnTip.x - sliderBounds.width/2);

    touchDownTime = [[NSDate dateWithTimeIntervalSinceNow:0] timeIntervalSince1970];
    trackingStartSliderX = _sliderView.frame.origin.x;
    trackingStartPosition = [touch locationInView:self].x;
    if (dist > tipWidth/2) {
        trackDragging = NO;
    } else {
        trackDragging = YES;
    }
    return YES;
}

static
float clampf(float v, float min, float max) {
    if (v < min) {
        return min;
    }
    if (v > max) {
        return max;
    }
    return v;
}

- (BOOL)continueTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event {
    if (trackDragging) {
        CGFloat offset = [touch locationInView:self].x - trackingStartPosition;
        CGRect rc = _sliderView.frame;
        rc.origin.x = clampf(trackingStartSliderX + offset, sliderPosMin, sliderPosMax);
        _sliderView.frame = rc;
        _tipView.center = _sliderView.center;
    }
    return YES;
}

- (void)endTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event {
    CGFloat offset = [touch locationInView:self].x - trackingStartPosition;
    BOOL savedOn = _on;

    if (trackDragging && fabsf(offset) > DRAG_THRESHOLD) {
        CGFloat x = clampf(trackingStartSliderX + offset, sliderPosMin, sliderPosMax);
        if ((x - sliderPosMin) > (sliderPosMax - sliderPosMin)/2) {
            _on = YES;
        } else {
            _on = NO;
        }

    }
    else {
        NSTimeInterval touchUpTime = [[NSDate dateWithTimeIntervalSinceNow:0] timeIntervalSince1970];
        if (touchUpTime - touchDownTime < TOUCH_THRESHOLD && fabsf(offset) < DRAG_THRESHOLD) {
            _on = !_on;
        }
    }
    [UIView animateWithDuration:0.2 animations:^{
        [self adjustPositionsForState:_on];
    } completion: ^(BOOL x) {
        if (_on != savedOn) {
            [self sendActionsForControlEvents:UIControlEventValueChanged];
        }
    }];
}

@end
