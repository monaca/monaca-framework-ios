//
//  AppDelegate.m
//  UnitTests
//
//  Created by Katsuya SAITO on 12/06/04.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "AppDelegate.h"
#import "CustomWebView.h"
#import "MonacaTemplateEngine.h"

@implementation AppDelegate

@synthesize window = _window;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    // Override point for customization after application launch.
    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];
    
    //---
    CustomWebView *webView = [[CustomWebView alloc] initWithFrame:[[UIScreen mainScreen] applicationFrame]];
    webView.delegate = webView;
    self.window.frame = CGRectMake(0, 20, self.window.frame.size.width, self.window.frame.size.height-20);
    [self.window addSubview:webView];
    
    NSString *path = [NSString stringWithFormat: @"%@/www/index.html", [[NSBundle mainBundle] resourcePath]];
    NSURL *url = [NSURL fileURLWithPath: path];
    NSString *html = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
    NSLog(@"html %@", html);
    //html = [MonacaTemplateEngine compileFromString:html path:url.path];
    html = [MonacaTemplateEngine compileFromFile:url.path];
    NSLog(@"path %@", path);
    
//    NSString *html = [MonacaTemplateEngine compileFromFile:[url absoluteString]];
    [webView loadHTMLString:html baseURL:url];
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
