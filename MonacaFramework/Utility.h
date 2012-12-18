//
//  Utility.h
//  Template
//
//  Created by Hiroki Nakagawa on 11/06/07.
//  Copyright 2011 ASIAL CORPORATION. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MFDelegate.h"
#import "MonacaViewController.h"
#import "MonacaTabBarController.h"


@interface Utility : NSObject {

}

+ (MonacaTabBarController *) currentTabBarController;
+ (UIInterfaceOrientation) currentInterfaceOrientation;
+ (BOOL) getAllowOrientationFromPlist:(UIInterfaceOrientation)interfaceOrientation;
+ (void) setupMonacaViewController:(MonacaViewController *)monacaViewController;
+ (void) fixedLayout:(MonacaViewController *)monacaViewController interfaceOrientation:(UIInterfaceOrientation)aInterfaceOrientation;
+ (void) show404PageWithWebView:(UIWebView *)webView path:(NSString *)aPath;
+ (NSString *)getWWWShortPath:(NSString *)path;
+ (NSString *)insertMonacaQueryParams:(NSString *)html query:(NSString *)aQuery;
+ (NSString *)urlEncode:(NSString *)text;
+ (NSString *)urlDecode:(NSString *)text;
+ (MFDelegate *)getAppDelegate;

@end
