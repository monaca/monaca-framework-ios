//
//  MFDelegate.m
//  Template
//
//  Created by Hiroki Nakagawa on 11/06/07.
//  Copyright 2011 ASIAL CORPORATION. All rights reserved.
//

#import <objc/runtime.h>

#import "MFDelegate.h"
#import "MFSecureFileURLProtocol.h"
#import "MonacaQueryParamURLProtocol.h"
#import "MFJSInterfaceProtocol.h"
#import "CDVSplashScreen.h"
#import "MFUtility.h"
#import "MFViewBuilder.h"

@class MFViewController;

// =====================================================================
// MFDelegate class.
// =====================================================================

@implementation MFDelegate

@synthesize monacaNavigationController = monacaNavigationController_;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    if ([[NSUserDefaults standardUserDefaults] objectForKey:@"UUID"] == nil) {
        CFUUIDRef uuidObj = CFUUIDCreate(nil);
        NSString *uuidString = (__bridge NSString*)CFUUIDCreateString(nil, uuidObj);
        CFRelease(uuidObj);
        [[NSUserDefaults standardUserDefaults] setObject:uuidString forKey:@"UUID"];
    }

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
    self.monacaNavigationController = [[MFNavigationController alloc] initWithRootViewController:[MFViewBuilder createViewControllerWithPath:@"www/index.html"]];

    
    // register protocols.
    [NSURLProtocol registerClass:[MonacaQueryParamURLProtocol class]];
    [NSURLProtocol registerClass:[MFJSInterfaceProtocol class]];
    [MFSecureFileURLProtocol registerMonacaURLProtocol];
    
    self.window.rootViewController = self.monacaNavigationController;
    [self.window makeKeyAndVisible];
    
    return YES;
}

- (UIInterfaceOrientation)currentInterfaceOrientation{
    return self.monacaNavigationController.interfaceOrientation;
}

@end
