//
//  MonacaTabBarController+Bottom.h
//  MonacaFramework
//
//  Created by Nakagawa Hiroki on 12/02/17.
//  Copyright (c) 2012年 ASIAL CORPORATION. All rights reserved.
//

#import "MonacaTabBarController.h"

@interface MonacaTabBarController (Bottom)

+ (UIToolbar *)updateBottomToolbar:(UIToolbar *)toolbar with:(NSDictionary *)style;
- (void)applyBottomToolbar:(NSDictionary *)uidict;

- (void)showTabBar:(BOOL)visible;
- (void)hideTabbar;
- (void)applyBottomTabbar:(NSDictionary *)uidict;
+ (void)updateBottomTabbarStyle:(MonacaTabBarController *)tabbar with:(NSDictionary *)style;

@end
