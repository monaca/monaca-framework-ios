//
//  MFTabBarController+Top.h
//  MonacaFramework
//
//  Created by Nakagawa Hiroki on 12/02/17.
//  Copyright (c) 2012年 ASIAL CORPORATION. All rights reserved.
//

#import "MFTabBarController.h"

@interface MFTabBarController (Top)

- (void)apply:(NSDictionary *)uidict;
- (MFTabBarController *)updateTopToolbar:(NSDictionary *)style;
- (MFTabBarController *)setTopToolbar:(NSDictionary *)style;
- (void)showRightComponent;
- (void)showLeftComponent;

- (BOOL)hasTitleView;
- (void)changeTitleView;

@end
