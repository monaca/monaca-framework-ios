//
//  MFViewManager.h
//  MonacaFramework
//
//  Created by Yasuhiro Mitsuno on 2013/06/02.
//  Copyright (c) 2013年 ASIAL CORPORATION. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MFViewController.h"

@interface MFViewManager : NSObject
{
    
}

+ (void)setCurrentViewController:(MFViewController *)viewController;
+ (MFViewController *)currentViewController;
+ (void)setCurrentWWWFolderName:(NSString *)wwwFolderName;
+ (NSString *)currentWWWFolderName;
+ (BOOL)isTabbarControllerTop;
+ (BOOL)isViewControllerTop;
+ (void)show404PageWithWebView:(UIWebView *)webView path:(NSString *)aPath;


@end
