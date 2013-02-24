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
+ (UIInterfaceOrientation) currentInterfaceOrientation;
+ (BOOL) getAllowOrientationFromPlist:(UIInterfaceOrientation)interfaceOrientation;
+ (NSDictionary *)parseJSONFile:(NSString *)path;
+ (BOOL)isPhoneGapScheme:(NSURL *)url;
+ (BOOL)isExternalPage:(NSURL *)url;
+ (BOOL)hasAnchor:(NSURL *)url;
+ (NSURL *)standardizedURL:(NSURL *)url;
+ (NSURL *)getBaseURL;
+ (NSDictionary *)getApplicationPlist;
+ (void)fixedLayout:(MFViewController *)monacaViewController interfaceOrientation:
    (UIInterfaceOrientation)aInterfaceOrientation;
+ (MFDelegate *)getAppDelegate;
+ (MFViewController *)currentViewController;
+ (void)setCurrentViewController:(MFViewController *)viewController;

@end
