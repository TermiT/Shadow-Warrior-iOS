//
//  LWHud.m
//  lowang
//
//  Created by termit on 10/29/12.
//
//

#import "LWHud.h"
#import "LWGameInstance.h"
#import "LWSlider.h"

#define kAirThickness 4
#define kAirThickness_iPhone 2

static const NSTimeInterval messageDuration = 3;
static const NSTimeInterval cookieDuration = 8;

@interface LWHud () {
    NSMutableArray * keys;
    UIView * keysView;
    UIImageView *airView;
    LWSlider *bossMeterView;
}
@property (retain, nonatomic) IBOutlet UILabel *healthLabel;
@property (retain, nonatomic) IBOutlet UILabel *armorLabel;
@property (retain, nonatomic) IBOutlet UILabel *messagesLabel;
@property (retain, nonatomic) IBOutlet UILabel *cookieLabel;
@property (retain, nonatomic) IBOutlet UIImageView *statusBase;


@end

@implementation LWHud

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        // Initialization code
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onShowMessage:) name:kLWShowInfoMessage object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onPlayerInfoChanged:) name:kLWPlayerInfoChanged object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onShowQuoteMessage:) name:kLWShowQuoteMessage object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onBossMeterChanged:) name:kLWBossMeterChanged object:nil];
    }
    return self;
}

- (UIView *)createKeyView:(NSString*)keyName {
//    UILabel * label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 80, 20)];
//    label.text = [NSString stringWithFormat:@"%d key", keyNumber];
//    label.backgroundColor = [UIColor clearColor];
//    label.textColor = [UIColor greenColor];
    
    UIImage * image = [UIImage imageNamed:keyName];
    UIImageView * keyImage = [[[UIImageView alloc] initWithImage:image] autorelease];
    keyImage.backgroundColor = [UIColor clearColor];
    [keyImage setFrame:CGRectMake(0, 0, image.size.width,image.size.height)];
    return keyImage;
}

- (void)awakeFromNib {
    keysView = [[UIView alloc] init];
    keysView.backgroundColor = [UIColor clearColor];
    [self addSubview:keysView];
    self.messagesLabel.text = @"";
    self.cookieLabel.text = @"";
    keys = [[NSMutableArray alloc] initWithCapacity:8];
        
    [keys addObject:[self createKeyView:@"Cardred"]];
    [keys addObject:[self createKeyView:@"Cardblue"]];
    [keys addObject:[self createKeyView:@"Cardgreen"]];
    [keys addObject:[self createKeyView:@"Cardyellow"]];
    [keys addObject:[self createKeyView:@"Skullgold"]];
    [keys addObject:[self createKeyView:@"Skullsilver"]];
    [keys addObject:[self createKeyView:@"Skullbronze"]];
    [keys addObject:[self createKeyView:@"Skullred"]];
    
    CGRect airViewFrame = self.statusBase.frame;
    CGFloat thickness = kAirThickness;
    if (!IS_IPAD()) thickness = kAirThickness_iPhone;
    airViewFrame.size.width += thickness;
    airViewFrame.size.height += thickness;
    airView = [[UIImageView alloc] initWithFrame:airViewFrame];
    airView.center = self.statusBase.center;
    [self addSubview:airView];

    CGFloat bossY = (IS_IPAD() ? 80 : 40);
    UIImage * bossImage = [UIImage imageNamed:@"BossBarEmpty.png"];
    CGRect bossMeterFrame = CGRectMake(0, 0, bossImage.size.width, bossImage.size.height);
    bossMeterView = [[LWSlider alloc] initWithFrame:bossMeterFrame];
    bossMeterView.center = CGPointMake(self.center.x, bossY);
    bossMeterView.hidden = YES;
    bossMeterView.userInteractionEnabled = NO;
    bossMeterView.fullImageName = @"BossBarFull.png";
    bossMeterView.emptyImageName = @"BossBarEmpty.png";
    bossMeterView.text = @"";
    bossMeterView.backgroundColor = [UIColor clearColor];
    [self addSubview:bossMeterView];
    [bossMeterView applyAttributes];
}

- (void) renderAir:(CGFloat)percent {
    UIGraphicsBeginImageContextWithOptions(airView.bounds.size, NO, [UIScreen mainScreen].scale);
    CGContextRef context = UIGraphicsGetCurrentContext();

    CGFloat thickness = kAirThickness;
    if (!IS_IPAD()) thickness = kAirThickness_iPhone;

    
    CGRect bounds = airView.bounds;
    CGPoint arcCenter = CGPointMake(bounds.size.width/2, bounds.size.height/2);
    CGFloat arcRadius = (bounds.size.width)/2 - thickness;
    
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathAddArc(path, NULL, arcCenter.x, arcCenter.y, arcRadius, (CGFloat) (-M_PI_2 - 2*M_PI*percent), (CGFloat) -M_PI_2, 0);
    
    CGContextSetLineWidth(context, thickness);
    CGContextSetStrokeColorWithColor(context, [UIColor whiteColor].CGColor);
    CGContextAddPath(context, path);
    CGContextStrokePath(context);
    
    airView.image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
}

- (void)onPlayerInfoChanged: (NSNotification *)notification {
    int flags = [((NSNumber*)notification.object) intValue];
    [self updatePlayerInfo:flags];
}

- (void)onBossMeterChanged: (NSNotification *)notification {
    NSNumber *meter = notification.object;
    if (meter.floatValue == 0) {
        bossMeterView.hidden = YES;
    } else {
        bossMeterView.hidden = NO;
        bossMeterView.value = meter.floatValue;
    }
}

- (void)updateView {
    [self updatePlayerInfo:0xFFFF];
    [self renderAir:1];
    bossMeterView.hidden = YES;
//    self.alpha = gameConfig.hudTransparency;
}

- (void)updatePlayerInfo:(int)flags {
    player_info_t *p = [gameInstance playerInfo];
    if (flags & PI_HEALTH) {
        self.healthLabel.text = [NSString stringWithFormat:@"%d", p->health];
    }
    if (flags & PI_ARMOR) {
        if (p->armor > 0 ) {
            self.armorLabel.text = [NSString stringWithFormat:@"%d", p->armor];
        } else {
            self.armorLabel.text = @"0";
        }
    }
    if (flags & PI_AIR) {
        if (p->air < 50) {
            [self renderAir:0.0f];
        } else if (p->air >= 1440) {
            [self renderAir:1.0f];
        } else {
            [self renderAir:p->air/1440.0f];
        }
    }
    
    if (flags & PI_KEYS) {
        float ypos = 0;
        for(UIView * view in keysView.subviews)
            [view removeFromSuperview];
        
        for (int i = 0; i < 8; i++) {
            if (p->hasKey[i]) {
                UIView * view = [keys objectAtIndex:(NSUInteger) i];
                CGRect frame = view.frame;
                frame.origin.y = ypos;
                ypos += frame.size.height + 10;
                view.frame = frame;
                [keysView addSubview:view];
            }
        }
        CGRect rect = self.frame;
        rect.size.height = ypos;
        rect.size.width = 44;
        rect.origin.x = 10;
        rect.origin.y = (self.frame.size.height - ypos) / 2;
        [keysView setFrame:rect];
    }
}

 
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
/*
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
 */


- (void)dealloc {
    [_healthLabel release];
    [_armorLabel release];
    [_messagesLabel release];
    [_cookieLabel release];
    [_statusBase release];
    [keysView release];
    [keys release];
    [airView release];
    [bossMeterView release];
    [super dealloc];
}

#pragma mark - notification handlers


-(void) onShowMessage:(NSNotification*)notification {
    NSString *message = (NSString*)notification.object;
    if ([message rangeOfString:@"$"].location != NSNotFound) return;
    [UIView animateWithDuration:0.01 delay:0 options:UIViewAnimationCurveEaseInOut|UIViewAnimationOptionBeginFromCurrentState
                     animations:^{
                         _messagesLabel.alpha = 0;
                     }
                     completion:^(BOOL finished) {
                         _messagesLabel.text = message;
                         _messagesLabel.alpha = 1;
                         [UIView animateWithDuration:messageDuration delay:0 options:(UIViewAnimationOptions) UIViewAnimationCurveEaseIn
                                          animations:^{
                                              _messagesLabel.alpha = 0;
                                          }
                                          completion:^(BOOL _f) {
                                          }];
                     }];
}

-(void) onShowQuoteMessage:(NSNotification*)notification {
    NSString *message = (NSString*)notification.object;
    [UIView animateWithDuration:0.01 delay:0 options:UIViewAnimationCurveEaseIn|UIViewAnimationOptionBeginFromCurrentState
                     animations:^{
                         _cookieLabel.alpha = 0;
                     }
                     completion:^(BOOL finished) {
                         _cookieLabel.text = message;
                         _cookieLabel.alpha = 1;
                         [UIView animateWithDuration:cookieDuration delay:0 options:(UIViewAnimationOptions) UIViewAnimationCurveEaseInOut
                                          animations:^{
                                              _cookieLabel.alpha = 0;
                                          }
                                          completion:^(BOOL _f) {
                                          }];
                     }];
}


@end
