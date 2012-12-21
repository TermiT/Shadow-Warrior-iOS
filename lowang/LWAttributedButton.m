//
//  LWAttributedButton.m
//  lowang
//
//  Created by termit on 10/26/12.
//
//

#import "LWAttributedButton.h"

@implementation LWAttributedButton {
@private
    NSString *_fontName;
}

@synthesize levelNumber;
@synthesize fontName = _fontName;


- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void) applyAttributes {
    if (self.fontName != nil && self.fontSize != nil) {
        self.titleLabel.font = [UIFont fontWithName:self.fontName size:self.fontSize.intValue];
    }
}

- (void)awakeFromNib {
    [super awakeFromNib];
    [self applyAttributes];
}

- (void)dealloc {
    [levelNumber release];
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
