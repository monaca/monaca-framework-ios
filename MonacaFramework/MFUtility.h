//
//  MFUtility.h
//  MonacaFramework
//
//  Created by Yasuhiro Mitsuno on 2013/02/23.
//  Copyright (c) 2013年 ASIAL CORPORATION. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NativeComponents.h"

@interface MFUtility : NSObject
{
    
}
+ (MFTabBarController *)currentTabBarController;
+ (void)setCurrentTabBarController:(MFTabBarController *)tabBarController;
+ (UIInterfaceOrientation) currentInterfaceOrientation;
+ (BOOL) getAllowOrientationFromPlist:(UIInterfaceOrientation)interfaceOrientation;
+ (NSDictionary *)parseJSONFile:(NSString *)path;
+ (NSMutableDictionary *)parseQuery:(NSURLRequest *)request;
+ (NSString *)urlEncode:(NSString *)text;
+ (BOOL)isPhoneGapScheme:(NSURL *)url;
+ (BOOL)isExternalPage:(NSURL *)url;
+ (BOOL)hasAnchor:(NSURL *)url;
+ (NSURL *)standardizedURL:(NSURL *)url;
+ (NSURL *)getBaseURL;
+ (NSString *)getWWWShortPath:(NSString *)path;
+ (NSString *)insertMonacaQueryParams:(NSString *)html query:(NSString *)aQuery;
+ (NSString *)getUIFileName:(NSString *)filename;
+ (NSDictionary *)getApplicationPlist;
+ (void)fixedLayout:(MFViewController *)monacaViewController interfaceOrientation:
    (UIInterfaceOrientation)aInterfaceOrientation;
+ (void) show404PageWithWebView:(UIWebView *)webView path:(NSString *)aPath;
+ (MFDelegate *)getAppDelegate;
+ (MFViewController *)currentViewController;
+ (void)setCurrentViewController:(MFViewController *)viewController;

@end
