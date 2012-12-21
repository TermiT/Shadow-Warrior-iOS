//
//  LWHudLabel.m
//  lowang
//
//  Created by termit on 11/3/12.
//
//

#import "LWHudLabel.h"

@implementation LWHudLabel {
@private
    NSString *_fontName;
}

@synthesize fontName = _fontName;


- (id)init {
    self = [super init];
    if (self) {
    }
    return self;
}

- (void)awakeFromNib {
    if (self.fontName != nil) {
        self.font = [UIFont fontWithName:self.fontName size:self.font.pointSize];
    } else {
        self.font = [UIFont fontWithName:@"Bonzai" size:self.font.pointSize];
    }
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)dealloc {
    [_fontName release];
    [super dealloc];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
