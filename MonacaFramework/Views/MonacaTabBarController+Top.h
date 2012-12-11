//
//  MonacaTabBarController+Top.h
//  MonacaFramework
//
//  Created by Nakagawa Hiroki on 12/02/17.
//  Copyright (c) 2012年 ASIAL CORPORATION. All rights reserved.
//

#import "MonacaTabBarController.h"

@interface MonacaTabBarController (Top)

- (void)apply:(NSDictionary *)uidict;
- (MonacaTabBarController *)updateTopToolbar:(NSDictionary *)style;
- (MonacaTabBarController *)setTopToolbar:(NSDictionary *)style;

- (BOOL)hasTitleView;
- (void)changeTitleView;

@end
