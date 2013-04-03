//
//  LWStoreView.m
//  lowang
//
//  Created by termit on 12/4/12.
//
//

#import <QuartzCore/QuartzCore.h>
#import "LWStoreView.h"
#import "LWAttributedButton.h"
#import "MKStoreManager.h"

@implementation LWStoreView {
    IBOutlet UIView *popUpView;
    NSArray *featureNames;
    NSArray *featuresDescription;
}
@synthesize selectedFeatureIndex;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)awakeFromNib {
    popUpView.backgroundColor = [UIColor whiteColor];
    popUpView.layer.cornerRadius = 13;
    popUpView.layer.masksToBounds = YES;
    popUpView.layer.borderWidth = 2.0;
    popUpView.layer.borderColor = [UIColor colorWithRed:83/255.0f green:35/255.0f blue:35/255.0f alpha:1.0f].CGColor;
    selectedFeatureIndex = GAME_SHADOW_WARRIOR;
    for (LWAttributedButton * button in _bannersButtons) {
        button.layer.cornerRadius = 13;
        button.layer.masksToBounds = YES;
    }
    featureNames = [@[@"Shadow Warrior Full", @"Twin Dragon", @"Wanton Destruction"] retain];
    featuresDescription = [@[
                           @"Continue an amazing adventure of Lo Wang by purchasing full version and help him to stop dark forces of Zilla Corporation. Full version includes:\n- 16 more levels (+2 secret levels)\n- 8 hours of gameplay\n- new enemies, weapons, items and vehicles\n- 3 boss battles\n- more eastern eggs and secret locations\n- even more bunnies\nGet classic AAA title for the price of a cup of coffee!",
                           @"At the time Lo Wang was delivered into the world, he was not alone. Lo Wang's mother was blessed with twin baby boys. Unfortunately, due to the fact that his mother was unwed, she gave them both up for adoption. Lo Wang's new family was only able to afford to raise one child, therefore, his brother was adopted by another family. His brother, Hung Lo, was adopted and raised by the evil overlord Pu Tang.\nPu Tang was an evil man, and raised Hung Lo as a deciple of evil...\n- 12 levels (+1 secret level)",
                           @"Lo Wang visits his relatives in USA, but he is forced to fight off Zilla's forces again. Wanton Destruction features twelve of the most eye popping levels you will ever trip through! Featuring: Chinatown, Monastery Gardens, San Francisco Trolley Yards, Chinese Restaurant, Skyscraper Under Construction, on board a 747, high tech Secret Military Base, Japanese Bullet Train, Zilla's Auto Factory, and Tokyo Rooftops.\n - 10 levels (+ 2 secret levels)\n - New enimies"
                           ] retain];
}

- (void) updateView {    
    for (LWAttributedButton * button in _bannersButtons) {
        if ([button.numberValue intValue] == self.selectedFeatureIndex) {
            button.alpha = 1.0f;
        } else {
            button.alpha = 0.5f;
        }
    }
    
    self.featureTitle.text = [featureNames objectAtIndex:selectedFeatureIndex];
    self.featureDescription.text = [featuresDescription objectAtIndex:selectedFeatureIndex];
    [super updateView];
}

- (IBAction)closeButtonClicked:(id)sender {
    [self.gameController hideStoreView];
}

- (IBAction)buyButtonClicked:(id)sender {
    [self.gameController buyFeature:[self.gameController futureIDForGameType:self.selectedFeatureIndex]];
}

- (IBAction)restoreButtonClicked:(id)sender {
    [self.gameController restorePurchases];
}

- (IBAction)featureButtonClicked:(id)sender {
    selectedFeatureIndex = [((LWAttributedButton *)sender).numberValue unsignedIntValue];
    [self updateView];
    
}

- (void)dealloc {
    [popUpView release];
    [_bannersButtons release];
    [_featureTitle release];
    [_featureDescription release];
    [super dealloc];
}
@end
