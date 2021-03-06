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
#import "MFViewManager.h"
#import "MFViewBuilder.h"

@class MFViewController;

// =====================================================================
// MFDelegate class.
// =====================================================================

@implementation MFDelegate

@synthesize monacaNavigationController = monacaNavigationController_;
@synthesize window;

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
    self.monacaNavigationController = [MFViewBuilder createMonacaNavigationControllerWithWwwDir:[MFUtility getBaseURL].path withPath:@"index.html"];
    
    // register protocols.
    [NSURLProtocol registerClass:[MonacaQueryParamURLProtocol class]];
    [NSURLProtocol registerClass:[MFJSInterfaceProtocol class]];
    [MFSecureFileURLProtocol registerMonacaURLProtocol];
    
    self.window.rootViewController = self.monacaNavigationController;
    [self.window makeKeyAndVisible];
    
    [[UIApplication sharedApplication] registerForRemoteNotificationTypes:(UIRemoteNotificationTypeBadge                                                                           | UIRemoteNotificationTypeSound | UIRemoteNotificationTypeAlert)];

    if (launchOptions) {
        NSDictionary *extraJson = [[launchOptions objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey] objectForKey:@"j"];
        [[NSUserDefaults standardUserDefaults] setObject:extraJson forKey:@"extraJSON"];
    }

    [MFUtility setMonacaCloudCookie];

    return YES;
}

- (UIInterfaceOrientation)currentInterfaceOrientation{
    return self.monacaNavigationController.interfaceOrientation;
}

- (NSDictionary *)getApplicationPlist
{
    NSMutableDictionary* applicationPlist = [NSMutableDictionary dictionaryWithDictionary:[[NSBundle mainBundle] infoDictionary]];
    //MonacaBackend Plugin always use
    [applicationPlist setObject:@"true" forKey:@"Monaca"];
    return applicationPlist;
}

- (void)applicationWillResignActive:(UIApplication *)application
{

}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    if ([[NSUserDefaults standardUserDefaults] objectForKey:@"deviceToken"]) {
        NSString *token = [[NSUserDefaults standardUserDefaults] objectForKey:@"deviceToken"];
        [MFUtility register_push:token];
    } else {
        [[UIApplication sharedApplication] registerForRemoteNotificationTypes:(UIRemoteNotificationTypeBadge                                                                           | UIRemoteNotificationTypeSound | UIRemoteNotificationTypeAlert)];
    }
    application.applicationIconBadgeNumber = 0;
    
    [MFUtility setMonacaCloudCookie];
}
- (void)applicationDidEnterBackground:(UIApplication *)application
{

}

- (void)applicationDidBecomeActive:(UIApplication *)application
{

}

- (void)applicationWillTerminate:(UIApplication *)application
{

}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken
{
    NSString *token = [[[[deviceToken description] stringByReplacingOccurrencesOfString:@"<"withString:@""]
                        stringByReplacingOccurrencesOfString:@">" withString:@""]
                       stringByReplacingOccurrencesOfString: @" " withString: @""];
    [[NSUserDefaults standardUserDefaults] setObject:token forKey:@"deviceToken"];
    [MFUtility register_push:token];
}

- (void)application:(UIApplication*)application didFailToRegisterForRemoteNotificationsWithError:(NSError*)err
{
    NSLog(@"ErrorInRegistration:%@",err);
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo
{
    NSString *pushProjectId = [userInfo objectForKey:@"i"];
    NSDictionary *extraJson = [userInfo objectForKey:@"j"];

    [[NSUserDefaults standardUserDefaults] setObject:pushProjectId forKey:@"pushProjectId"];
    [[NSUserDefaults standardUserDefaults] setObject:extraJson forKey:@"extraJSON"];
    application.applicationIconBadgeNumber = 0;

    [[MFViewManager currentViewController] sendPush];
}

@end
