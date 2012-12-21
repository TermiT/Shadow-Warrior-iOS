//
//  LWSlider.m
//  lowang
//
//  Created by serge on 18/11/12.
//
//

#import "LWSlider.h"

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

@implementation LWSlider {
    UIImage *_full;
    UIImage *_empty;
    float _value;
    NSString *_text;
    UIFont *_font;

    /* To be set using "User Defined Runtime Attributes" */
    NSString *_fontName;
    NSNumber *_fontSize;
    UIColor *_fullColor;
    UIColor *_emptyColor;
    NSNumber *_labelOffset;
    NSString *_fullImageName;
    NSString *_emptyImageName;
}
@synthesize fontName = _fontName;
@synthesize fontSize = _fontSize;
@synthesize fullColor = _fullColor;
@synthesize emptyColor = _emptyColor;
@synthesize labelOffset = _labelOffset;
@synthesize fullImageName = _fullImageName;
@synthesize emptyImageName = _emptyImageName;
@synthesize text = _text;


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

- (void)applyAttributes {
    _full = [[UIImage imageNamed:self.fullImageName] retain];
    _empty = [[UIImage imageNamed:self.emptyImageName] retain];
    _font = [[UIFont fontWithName:self.fontName size:self.fontSize.intValue] retain];
}

- (void)initControl {
    /* set default attribute values */
    self.text = @"LWSlider";
    self.fontName = @"Helvetica";
    self.fontSize = @(20);
    self.fullColor = [UIColor redColor];
    self.emptyColor = [UIColor grayColor];
    self.labelOffset = @(5);
    self.fullImageName = @"slider-full.png";
    self.emptyImageName = @"slider-empty.png";
    [self applyAttributes];
    _value = 0;
}

- (float)value {
    return _value;
}

- (void)setValue:(float)value {
    [self setNeedsDisplay];
    _value = value;
}

- (void) awakeFromNib {
    [self applyAttributes];
    [self setNeedsDisplay];
}

- (void)dealloc {
    [_full release];
    [_text release];
    [_font release];
    [_empty release];
    [_fontName release];
    [_fontSize release];
    [_fullColor release];
    [_emptyColor release];
    [_labelOffset release];
    [_fullImageName release];
    [_emptyImageName release];
    [super dealloc];
}

- (void)updateWithPoint:(CGPoint)point {
    self.value = clampf(point.x, CGRectGetMinX(self.bounds), CGRectGetMaxX(self.bounds))/self.bounds.size.width;
}

- (BOOL)beginTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event {
    [self updateWithPoint:[touch locationInView:self]];
    return YES;
}

- (BOOL)continueTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event {
    [self updateWithPoint:[touch locationInView:self]];
    return YES;
}

- (void)endTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event {
    [self updateWithPoint:[touch locationInView:self]];
    [self sendActionsForControlEvents:UIControlEventValueChanged];
}

- (void)render:(BOOL)state {
    CGContextRef c = UIGraphicsGetCurrentContext();
//    CGContextDrawImage(c, self.bounds, (state?_full:_empty).CGImage);
    [state?_full:_empty drawInRect:self.bounds];
    CGContextSetTextMatrix(c, CGAffineTransformMakeScale(1, -1));
    [(state?self.fullColor:self.emptyColor) set];
    CGContextSelectFont(c, _font.fontName.UTF8String, _font.pointSize, kCGEncodingMacRoman);
    CGSize s = [_text sizeWithFont:_font];
    CGPoint textPos = { (self.bounds.size.width - s.width)/2, (self.bounds.size.height - s.height)/2 + s.height  };
    textPos.y += self.labelOffset.floatValue;
    CGContextShowTextAtPoint(c, textPos.x, textPos.y, _text.UTF8String, _text.length);
}

- (void)drawRect:(CGRect)rect {
    CGContextRef c = UIGraphicsGetCurrentContext();
    CGRect clipRect;

    CGContextSaveGState(c);
    clipRect = CGRectMake(0, 0, _value * self.bounds.size.width, self.bounds.size.height);
    CGContextClipToRect(c, clipRect);
    [self render:YES];
    CGContextRestoreGState(c);

    CGContextSaveGState(c);
    clipRect = CGRectMake(_value * self.bounds.size.width, 0, (1-_value) * self.bounds.size.width, self.bounds.size.height);
    CGContextClipToRect(c, clipRect);
    [self render:NO];
    CGContextRestoreGState(c);
}

@end
