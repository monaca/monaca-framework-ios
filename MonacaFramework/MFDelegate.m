//
//  MFDelegate.m
//  Template
//
//  Created by Hiroki Nakagawa on 11/06/07.
//  Copyright 2011 ASIAL CORPORATION. All rights reserved.
//

#import <objc/runtime.h>

#import "MFDelegate.h"
#import "MFViewController.h"
#import "MFTabBarController.h"
#import "NativeComponents.h"
#import "MFSecureFileURLProtocol.h"
#import "MonacaQueryParamURLProtocol.h"
#import "CDVViewController.h"
#import "CDVSplashScreen.h"
#import "MFUtility.h"

@class MFViewController;

// =====================================================================
// MFDelegate class.
// =====================================================================

@implementation MFDelegate

@synthesize monacaNavigationController = monacaNavigationController_;
@synthesize window;
@synthesize viewController = viewController_;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // for use getMonacaBundlePlist
    if (YES) {
        Class klass = [CDVViewController class];
        Method old = class_getClassMethod(klass, @selector(getBundlePlist:));
        Method new = class_getClassMethod(klass, @selector(getMonacaBundlePlist:));
        method_exchangeImplementations(old, new);
    }

    // local scope with if block
    if (YES) {
        Class klass = [CDVSplashScreen class];
        Method old = class_getInstanceMethod(klass, @selector(__show:));
        Method new = class_getInstanceMethod(klass, @selector(__showMonacaSplashScreen:));
        method_exchangeImplementations(old, new);
    }
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.viewController = [[MFViewController alloc] initWithFileName:@"index.html"];
    [MFUtility setupMonacaViewController:self.viewController];
    
    self.monacaNavigationController = [[MFNavigationController alloc] initWithRootViewController:self.viewController];
    
    // register protocols.
    [NSURLProtocol registerClass:[MonacaQueryParamURLProtocol class]];
    [NSURLProtocol registerClass:[MFJSInterfaceProtocol class]];
    [MFSecureFileURLProtocol registerMonacaURLProtocol];
    
    self.window.rootViewController = self.monacaNavigationController;
    [self.window makeKeyAndVisible];
    
    return YES;
}

- (NSURL *)getBaseURL {
    NSString *base_path = [NSString stringWithFormat:@"%@/www", [[NSBundle mainBundle] bundlePath]];
    return [NSURL fileURLWithPath:base_path];
}

- (UIInterfaceOrientation)currentInterfaceOrientation{
    return self.monacaNavigationController.interfaceOrientation;
}

- (NSDictionary *)getApplicationPlist
{
    return [[NSBundle mainBundle] infoDictionary];
}

@end
