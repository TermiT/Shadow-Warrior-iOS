//
//  LWSkillSelectMenu.h
//  lowang
//
//  Created by termit on 10/26/12.
//
//

#import "LWMenuView.h"

@interface LWSkillSelectMenu : LWMenuView <UIScrollViewDelegate>

@property (nonatomic, assign) NSUInteger skill;
@property (nonatomic, readonly) NSUInteger level;

@end
