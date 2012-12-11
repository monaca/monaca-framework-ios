//
//  MonacaFrameworkDelegate.m
//  Template
//
//  Created by Hiroki Nakagawa on 11/06/07.
//  Copyright 2011 ASIAL CORPORATION. All rights reserved.
//

#import <objc/runtime.h>

#import "MonacaDelegate.h"
#import "MonacaViewController.h"
#import "MonacaTabBarController.h"
#import "NativeComponents.h"
#import "MonacaURLProtocol.h"
#import "CDVViewController.h"
#import "CDVSplashScreen.h"
#import "Utility.h"

#ifndef DISABLE_MONACA_TEMPLATE_ENGINE
#import "MonacaTemplateEngine.h"
#endif  // DISABLE_MONACA_TEMPLATE_ENGINE

@class MonacaViewController;

// =====================================================================
// MonacaDelegate class.
// =====================================================================

@implementation MonacaDelegate

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
    
    self.window = [[[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]] autorelease];
    self.viewController = [[[MonacaViewController alloc] initWithFileName:@"index.html" query:nil] autorelease];
    [Utility setupMonacaViewController:self.viewController];
    
    self.monacaNavigationController = [[[MonacaNavigationController alloc] initWithRootViewController:self.viewController] autorelease];
    
    [MonacaURLProtocol registerMonacaURLProtocol];
    
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
