//
//  MFTabBarController+Bottom.h
//  MonacaFramework
//
//  Created by Nakagawa Hiroki on 12/02/17.
//  Copyright (c) 2012年 ASIAL CORPORATION. All rights reserved.
//

#import "MFTabBarController.h"

@interface MFTabBarController (Bottom)

+ (UIToolbar *)updateBottomToolbar:(UIToolbar *)toolbar with:(NSDictionary *)style;
- (void)applyBottomToolbar:(NSDictionary *)uidict;

- (void)showTabBar:(BOOL)visible;
- (void)hideTabbar;
- (void)applyBottomTabbar:(NSDictionary *)uidict;
+ (void)updateBottomTabbarStyle:(MFTabBarController *)tabbar with:(NSDictionary *)style;

@end
