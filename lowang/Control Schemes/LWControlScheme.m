//
//  LWControlScheme.m
//  lowang
//
//  Created by termit on 10/26/12.
//
//


#import "LWControlScheme.h"
#import "iphone_api.h"
#import "LWGameInstance.h"
#import "LWHudLabel.h"
#import "LWGameController.h"
#import "controlSchemeHelpers.h"

#define kTagLabel       1001
#define kTagIcon        1002

#define kItemTagBase    8000
#define kButtonTagBase  7000

#define kWeaponButtonTagBase    1001
#define kWeaponAmmoLabelTabBase 2001

#define INVENTORY_Y 0


@implementation LWControlScheme {
    NSMutableArray *inventoryItems; // array of UIView containing views representing inventory items
    UIView *inventoryTrayView;      // inventory tray (appears on top of the screen)

    UIButton *currentWeaponButton;  // displays currently chosen weapon, triggers weapon select menu
    UILabel *currentAmmoLabel;      // label showing amount of ammo

    UIView *weaponScreen;           // screen-sized view containing weapon select menu loaded from xib
    NSArray *weaponButtons;         // array of pointers to buttons, taken from the xib
    NSArray *ammoLabels;            // array of pointers to labels, taken from the xib
    
    BOOL prevInvActive[7];          // needed for tracking changes in the inventory tray
    char prevInvAmount[7];          //
@private
    LWGameController *_gameController;
}
@synthesize gameController = _gameController;


- (id) init {
    if ((self = [super init]) != nil) {
        self.frame = CGRectMake(0, 0, screenSize.width, screenSize.height);
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onPlayerInfoChanged:) name:kLWPlayerInfoChanged object:nil];
        [self initView];
    }
    return self;
}

/* creates UIView representing particular inventory item: medkit, repair kit, etc */
/* those items appear on the top of the screen */
- (UIView *)createInventoryItem:(NSString*)name hasLabel:(BOOL)hasLabel inventoryIndex:(int)index {
    NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"LWItemView" owner:self options:nil];
    UIView *view = [topLevelObjects objectAtIndex:0];
    UIImageView *icon = (UIImageView *)[view viewWithTag:kTagIcon];
    icon.image = [UIImage imageNamed:name];
    
    UILabel *label = (UILabel *)[view viewWithTag:kTagLabel];
    label.hidden = !hasLabel;    
    
    UIButton *button = [[UIButton alloc] initWithFrame:view.frame];
    [button addTarget:self action:@selector(inventoryItemClicked:) forControlEvents:UIControlEventTouchUpInside];
    button.tag = index+kButtonTagBase;
    [view addSubview:button];
    [button release];
    view.tag = index+kItemTagBase;
    
    return view;
}

- (void) initInventory {
    inventoryItems = [[NSMutableArray alloc] initWithCapacity:MAX_INVENTORY];
    inventoryTrayView = [[UIView alloc] initWithFrame:CGRectZero];
    inventoryTrayView.backgroundColor = [UIColor clearColor];

    const char *iconNames[] = { "hud_medkit", "hud_repair_kit", "hud_cloak", "hud_night_vision", "hud_flashbomb", "hud_chembomb", "hud_caltrops" };
    for (int i = 0; i < MAX_INVENTORY; i++) {
        [inventoryItems addObject:[self createInventoryItem:[NSString stringWithUTF8String:iconNames[i]] hasLabel:(i != INVENTORY_REPAIR_KIT) inventoryIndex:i]];
    }
    [self addSubview:inventoryTrayView];
}

- (void) initWeaponButton {
    
    UIImage * currentWeaponImage = [UIImage imageNamed:@"weapon_sword"];
    CGSize size = currentWeaponImage.size;
    currentWeaponButton = [[UIButton alloc] initWithFrame:CGRectMake(self.bounds.size.width - size.width - 10, IS_IPAD() ? 10 : 5, size.width, size.height)];
    [currentWeaponButton setBackgroundImage:currentWeaponImage forState:UIControlStateNormal];
    [currentWeaponButton addTarget:self action:@selector(currentWeaponButtonClicked:) forControlEvents:(UIControlEventTouchUpInside)];
    currentWeaponButton.backgroundColor = [UIColor clearColor];
    currentAmmoLabel = [[UILabel alloc] initWithFrame:CGRectMake(currentWeaponButton.frame.origin.x, currentWeaponButton.frame.origin.y + currentWeaponButton.frame.size.height - (IS_IPAD() ? 15 : 7), currentWeaponButton.frame.size.width, IS_IPAD() ? 30 : 15)];
    [currentAmmoLabel setFont:[UIFont fontWithName:@"Bonzai" size: IS_IPAD() ? 30 : 15]];
    currentAmmoLabel.backgroundColor = [UIColor clearColor];
    currentAmmoLabel.textColor = [UIColor whiteColor];
    currentAmmoLabel.textAlignment = (NSTextAlignment) UITextAlignmentRight;

    [self addSubview:currentWeaponButton];
    [self addSubview:currentAmmoLabel];
}

- (void) initWeaponMenu {
    weaponScreen = [[UIView alloc] init];
    weaponScreen.frame = self.bounds;
    weaponScreen.backgroundColor = [UIColor clearColor];

    UIView *weaponSelectView = [[[[[NSBundle mainBundle] loadNibNamed:@"LWWeaponMenu" owner:nil options:nil] objectAtIndex:0] retain] autorelease];
    weaponSelectView.center = CGPointMake(weaponScreen.bounds.size.width/2, weaponScreen.bounds.size.height/2);
    [weaponScreen addSubview:weaponSelectView];

    UIButton *hideWeaponsButton = [[[UIButton alloc] initWithFrame:currentWeaponButton.frame] autorelease];
    hideWeaponsButton.backgroundColor = [UIColor clearColor];
    hideWeaponsButton.frame = currentWeaponButton.frame;
    [hideWeaponsButton addTarget:self action:@selector(hideWeaponsButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [weaponScreen addSubview:hideWeaponsButton];

    NSMutableArray *weapons = [NSMutableArray array];
    NSMutableArray *ammo = [NSMutableArray array];

    for (NSUInteger i = 0; i < 10; i++) {
        UIButton *button = (UIButton *) [weaponSelectView viewWithTag:kWeaponButtonTagBase+i];
        [button addTarget:self action:@selector(chageWeaponButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
        [weapons addObject:button];
        UIView *label = [weaponSelectView viewWithTag:kWeaponAmmoLabelTabBase+i];
        [ammo addObject:label];
    }

    weaponButtons = [[NSArray alloc] initWithArray:weapons];
    ammoLabels = [[NSArray alloc] initWithArray:ammo];

}

- (void) initMenuButton {
    UIButton *menuButton = [[UIButton alloc] initWithFrame:CGRectMake(20, 20, 114, 114)];
    menuButton.backgroundColor = [UIColor clearColor];
    [menuButton addTarget:self action:@selector(menuButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:menuButton];
    [menuButton release];
}

- (void)initView {
    UIButton *cheatButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [cheatButton setTitle:@"Cheat" forState:UIControlStateNormal];
    cheatButton.frame = CGRectMake(30, 150, 80, 30);
    [cheatButton addTarget:self action:@selector(cheat:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:cheatButton];
    cheatButton.hidden = YES;


    [self initInventory];
    [self initWeaponButton];
    [self initWeaponMenu];
    [self initMenuButton];
}

- (void)cheat:(id)cheat {
    extern void HealthRefill(void);
    CFRunLoopPerformBlock(gameRunLoop, (CFTypeRef) kCFRunLoopCommonModes, ^{
        HealthRefill();
        extern int GodMode;
        GodMode = 1;

    });
}

- (void)updateWeaponMenu {
    player_info_t *p = [gameInstance playerInfo];
    for (int i = 0; i < 10; i++) {
        UIButton *weaponButton = (UIButton*)[weaponButtons objectAtIndex:i];
        UILabel *ammoLabel = (UILabel*)[ammoLabels objectAtIndex:i];
        weaponButton.userInteractionEnabled = p->hasWeapon[i];
        weaponButton.alpha = p->hasWeapon[i] ? 1 : 0.5;
        if (i != WPN_FIST) {
            ammoLabel.hidden = !p->hasWeapon[i];
            ammoLabel.text = [NSString stringWithFormat:@"%d", p->ammo[i]];
        }
    }
}

- (void) showWeapons:(BOOL)show {
    [gameInstance setPaused:show];
    CGRect frame = self.frame;
    if (show) {
        [self addSubview:weaponScreen];
        frame.origin.x = frame.size.width;
        weaponScreen.frame = frame;
    }
    
    [UIView animateWithDuration:0.5 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        CGRect rect = frame;
        if (show) {
            rect.origin.x = 0;
        } else {
            rect.origin.x = frame.size.width;
        }
        weaponScreen.frame = rect;
        
    } completion:^(BOOL finished) {
        if (!show) {
            [weaponScreen removeFromSuperview];
        }
    }];
}

- (void) hideWeaponsButtonClicked:(id)sender {
    [self showWeapons:NO];
}


- (void)currentWeaponButtonClicked:(id)sender {
    [self updateWeaponMenu];
    [self showWeapons:YES];
}

static
BOOL weaponEquals(int wpn1, int wpn2) {
    if (wpn1 == wpn2) {
        return YES;
    }
    if (wpn1 > wpn2) {
        int t = wpn1;
        wpn1 = wpn2;
        wpn2 = t;
    }
    if (wpn1 == WPN_FIST && wpn2 == WPN_SWORD) {
        return YES;
    }
    if (wpn1 == WPN_HOTHEAD && (wpn2 == WPN_NAPALM || wpn2 == WPN_RING)) {
        return YES;
    }
    if (wpn1 == WPN_NAPALM && wpn2 == WPN_RING) {
        return YES;
    }
    if (wpn1 == WPN_MICRO && wpn2 == WPN_ROCKET) {
        return YES;
    }
    return NO;
}

- (void)chageWeaponButtonClicked:(id)sender {
    [self showWeapons:NO];
    int weaponIndex = ((UIView*)sender).tag - kWeaponButtonTagBase;
    player_info_t *pi = [gameInstance playerInfo];
    if (!weaponEquals(pi->weapon, weaponIndex)) {
        [gameInstance setButton:gamefunc_Weapon_1+weaponIndex];
        [gameInstance autoreleaseButton:gamefunc_Weapon_1+weaponIndex];
    }
}

- (void)onPlayerInfoChanged: (NSNotification *)notification {
    int flags = [((NSNumber*)notification.object) intValue];
    [self updatePlayerInfo:flags];
}

- (void)updateView {
    [self loadConfig];
    [self resetControlsState];
    memset(prevInvActive, 0, sizeof(prevInvActive));
    memset(prevInvAmount, 0, sizeof(prevInvAmount));
    for (UIView * view in inventoryTrayView.subviews) {
        [view removeFromSuperview];
    }
    [self updatePlayerInfo:0xFFFF];
    [self setTransparency:gameConfig.hudTransparency];
}

- (void)resetControlsState {
    for (UIView * v in [self subviews]) {
        if ([v isKindOfClass:[VCFreelook class]]) {
            [(VCFreelook *) v resetState];
        } else if ([v isKindOfClass:[VCStick class]]) {
            [(VCStick *) v resetState];
        }
    }
}

- (NSArray *)viewsForEditing {
    return [NSArray array];
}

- (UIImage *)editorBackground {
    return [[[UIImage alloc] init] autorelease];
}

- (NSString *)schemeName {
    return @"BaseControlScheme";
}

bool showOnOff(int i) {
    return (i==INVENTORY_CLOAK)||(i==INVENTORY_NIGHT_VISION);
}

- (void)updatePlayerInfo:(int)flags {
    player_info_t *p = [gameInstance playerInfo];
    if (flags & PI_INVENTORY) {
        CGFloat pos = 0;
        
        for (int i = 0; i < MAX_INVENTORY; i++) {
            UIView * itemView = [inventoryItems objectAtIndex:i];
            if (prevInvAmount[i] == 0 && p->invAmount[i] != 0) {
                [inventoryTrayView addSubview:[inventoryItems objectAtIndex:i]];
            }
            if (prevInvAmount[i] != 0 && p->invAmount[i] == 0) {
                [[inventoryTrayView viewWithTag:i + kItemTagBase] removeFromSuperview];
            }
            if (p->invAmount[i] > 0) {
                UILabel *label = (UILabel*)[itemView viewWithTag:kTagLabel];
                
                if (i == INVENTORY_MEDKIT) {
                    label.text = [NSString stringWithFormat:@"%d%%", p->invPercent[i]];
                } else if (showOnOff(i)) {
                    //leftLabel.text = p->invActive[i] ? @"ON" : @"OFF";
                    label.text = [NSString stringWithFormat:@"%d%%", p->invPercent[i]];
                } else {
                    label.text = p->invAmount[i] == 1 ? @"" : [NSString stringWithFormat:@"%d", p->invAmount[i]];
                }
            }
            if (!prevInvActive[i] && p->invActive[i]) {
                UIView *imgView = [itemView viewWithTag:kTagIcon];
                imgView.transform = CGAffineTransformIdentity;
                [UIView animateWithDuration:0.5f
                                      delay:0.0f
                                    options:UIViewAnimationOptionRepeat|UIViewAnimationOptionCurveEaseIn|UIViewAnimationOptionAutoreverse
                                 animations:^{
                                     imgView.transform = CGAffineTransformMakeScale(1.2f, 1.2f);
                                 } completion:nil];
            }
            if (/*prevInvActive[i] && */!p->invActive[i]) {
                UIView *imgView = [itemView viewWithTag:kTagIcon];
                [UIView animateWithDuration:0.01f
                                      delay:0.0f
                                    options:UIViewAnimationOptionBeginFromCurrentState
                                 animations:^{
                                     imgView.transform = CGAffineTransformIdentity;
                                 } completion:nil];
            }
        }
        NSArray *sortedView = [inventoryTrayView.subviews sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
            return (NSComparisonResult) (((UIView*)obj1).tag - ((UIView*)obj2).tag);
        }];
        CGSize itemSize = ((UIView*)[inventoryItems objectAtIndex:0]).bounds.size;
        CGRect frame = CGRectZero;
        for (NSInteger index = 0, num = [sortedView count]; index < num; index++) {
            UIView *v = (UIView*) [sortedView objectAtIndex:(NSUInteger) index];
            frame = v.frame;
            frame.origin.x = index * itemSize.width;
            v.frame = frame;
        }
        CGRect itemsFrame;
        itemsFrame.size.width = frame.origin.x + frame.size.width;
        itemsFrame.size.height = itemSize.height;
        itemsFrame.origin.x = (self.bounds.size.width-itemsFrame.size.width)/2.0f;
        itemsFrame.origin.y = INVENTORY_Y;
        inventoryTrayView.frame = itemsFrame;
        memcpy(prevInvActive, p->invActive, sizeof(prevInvActive));
        memcpy(prevInvAmount, p->invAmount, sizeof(prevInvAmount));
    }
    if (flags & PI_AMMO || flags & PI_WEAPON) {
        if (p->weapon == WPN_FIST || p->weapon == WPN_SWORD) {
            currentAmmoLabel.text = @"";
        } else {
            currentAmmoLabel.text = [NSString stringWithFormat:@"%d", p->ammo[p->weapon]];
        }
    }
    
    if (flags & PI_WEAPON ) {
        const char *weaponImages[] = {
            "weapon_sword",
            "weapon_shurikens",
            "weapon_shotgun",
            "weapon_uzi",
            "weapon_rocket_launcher",
            "weapon_grenade_launcher",
            "weapon_stickybomb",
            "weapon_railgun",
            "weapon_head",
            "weapon_heart",
            "weapon_head",
            "weapon_head",
            "weapon_rocket_launcher",
            "weapon_sword"
        };
        [currentWeaponButton setBackgroundImage:[UIImage imageNamed:[NSString stringWithUTF8String:weaponImages[p->weapon]]] forState:UIControlStateNormal];
    }
}

- (void)inventoryItemClicked:(id)sender {
    static int actions[] = {
        gamefunc_Med_Kit,
        -1,
        gamefunc_Smoke_Bomb,
        gamefunc_Night_Vision,
        gamefunc_Gas_Bomb,
        gamefunc_Flash_Bomb,
        gamefunc_Caltrops,
        gamefunc_TurnAround,
    };
    int item = ((UIButton *)sender).tag;
    if (item < kButtonTagBase || item > kItemTagBase+MAX_INVENTORY) {
        return;
    }
    item -= kButtonTagBase;
    int action = actions[item];
    if (action != -1) {
        [gameInstance setButton:action];
        [gameInstance autoreleaseButton:action];
    }
}

- (void)menuButtonClicked:(id)sender {
    [self.gameController setPaused];
}

- (void) loadConfig {
    applySchemeConfig([self viewsForEditing], [gameConfig schemeConfig:[self schemeName]], gameConfig.leftHandedControls);

}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [weaponButtons release];
    [ammoLabels release];
    [inventoryItems release];
    [inventoryTrayView release];
    [currentWeaponButton release];
    [currentAmmoLabel release];
    [_gameController release];
    [weaponScreen release];
    [super dealloc];
}

#pragma mark - VCFreelook delegate

- (void)didChangeState:(VCFreelook *)sender isPressed:(BOOL)pressed {
    switch (sender.tag) {
        case kControlButtonAttack:
            [gameInstance setButton:gamefunc_Fire value:pressed];
            break;
        case kControlButtonCrouch:
            [gameInstance setButton:gamefunc_Crouch value:pressed];
            break;
        case kControlButtonJump:
            [gameInstance setButton:gamefunc_Jump value:pressed];
            break;
        case kControlButtonUse:
            [gameInstance setButton:gamefunc_Open value:pressed];
            break;
        case kControlButtonWeaponMode: {
            player_info_t *p = [gameInstance playerInfo];
            [gameInstance setButton:gamefunc_Weapon_1+p->weapon value:pressed];
            break;
        }
        default:
            break;
    }
}

- (void)didMove:(id)sender withOffset:(CGPoint)offset {
    [gameInstance setFreelookMove:offset];
}

- (void)didChangeOffset:(VCStick *)sender withNormalizedOffset:(CGPoint)normalizedOffset {
    switch (sender.tag) {
        case kControlStickMove:
            [gameInstance setMoveStick:normalizedOffset];
            break;
        case kControlStickAim:
            [gameInstance setAimStick:normalizedOffset];
            break;
        default:
            break;
    }
}

#pragma mark -

- (void) setTransparency:(CGFloat)alpha {
    for (UIView *v in [self viewsForEditing]) {
        v.alpha = alpha;
    }
}

- (void)setupEditorInstructions:(UIView *)instructionsView {
}


@end
