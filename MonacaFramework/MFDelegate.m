//
//  MFDelegate.m
//  Template
//
//  Created by Hiroki Nakagawa on 11/06/07.
//  Copyright 2011 ASIAL CORPORATION. All rights reserved.
//

#import <objc/runtime.h>

#import "MFDelegate.h"
#import "MFUtility.h"

@class MFViewController;

// =====================================================================
// MFDelegate class.
// =====================================================================

@implementation MFDelegate

@synthesize viewController = viewController_;
@synthesize monacaNavigationController = monacaNavigationController_;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // for use getMonacaBundlePlist
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.viewController = [[MFViewController alloc] init];
    
    self.monacaNavigationController = [[MFNavigationController alloc] initWithWwwDir:[MFUtility getBaseURL].path];
    
    self.window.rootViewController = self.monacaNavigationController;
    [self.window makeKeyAndVisible];
    
    return YES;
}

- (UIInterfaceOrientation)currentInterfaceOrientation{
    return self.monacaNavigationController.interfaceOrientation;
}

@end
