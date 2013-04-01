//
//  MFTransitPlugin.m
//  MonacaFramework
//
//  Created by Yasuhiro Mitsuno on 2013/03/31.
//  Copyright (c) 2013年 ASIAL CORPORATION. All rights reserved.
//
#import <QuartzCore/QuartzCore.h>

#import "MFTransitPlugin.h"
#import "MFViewController.h"
#import "MFUtility.h"

@implementation MFTransitPlugin

- (BOOL)isValidOptions:(NSDictionary *)options {
    for (NSString *key in options) {
        if (((NSString *)[options objectForKey:key]).length > 512) {
            NSLog(@"[error] MonacaTransitException::Too long option length:%@, %@", key, [options objectForKey:key]);
            return NO;
        }
    }
    return YES;
}

- (BOOL)isValidString:(NSString *)urlString {
    if (urlString.length > 512) {
        NSLog(@"[error] MonacaTransitException::Too long path length:%@", urlString);
        return NO;
    }
    return YES;
}

- (NSURLRequest *)createRequest:(NSString *)urlString withQuery:(NSString *)query
{
    NSURL *url;
    if ([self.commandDelegate pathForResource:urlString]){
        url = [NSURL fileURLWithPath:[self.commandDelegate pathForResource:urlString]];
        if ([[query class] isSubclassOfClass:[NSString class]]) {
            url = [NSURL URLWithString:[url.absoluteString stringByAppendingFormat:@"?%@", query]];
        }
    }else {
        url = [NSURL URLWithString:[@"monaca404:///www/" stringByAppendingPathComponent:urlString]];
    }
    return [NSURLRequest requestWithURL:url];
}

- (NSString *) buildQuery:(NSDictionary *)jsonQueryParams urlString:(NSString *)urlString
{
    NSString *query = @"";
    NSArray *array = [urlString componentsSeparatedByString:@"?"];
    if (array.count > 1) {
        query = [array objectAtIndex:1];
    }
    
    if (jsonQueryParams.count > 0) {
        NSMutableArray *queryParams = [NSMutableArray array];
        for (NSString *key in jsonQueryParams) {
            NSString *encodedKey = [MFUtility urlEncode:key];
            NSString *encodedValue = nil;
            if ([[jsonQueryParams objectForKey:key] isEqual:[NSNull null]]){
                [queryParams addObject:[NSString stringWithFormat:@"%@", encodedKey]];
            }else {
                encodedValue = [MFUtility urlEncode:[jsonQueryParams objectForKey:key]];
                [queryParams addObject:[NSString stringWithFormat:@"%@=%@", encodedKey, encodedValue]];
            }
        }
        if([query isEqualToString:@""]){
            query = [[[queryParams reverseObjectEnumerator] allObjects] componentsJoinedByString:@"&"];
        }else{
            query = [NSString stringWithFormat:@"%@&%@",query,[[[queryParams reverseObjectEnumerator] allObjects] componentsJoinedByString:@"&"]];
        }
    }
    return [query isEqualToString:@""]?nil:query;
}

- (NSString *)getRelativePathTo:(NSString *)filePath{
    NSString *currentDirectory = [[MFUtility currentViewController].webView.request.URL URLByDeletingLastPathComponent].filePathURL.path;
    NSString *urlString = [currentDirectory stringByAppendingPathComponent:filePath];
    NSMutableArray *array = [NSMutableArray arrayWithArray:[urlString componentsSeparatedByString:@"www/"]];
    if (array.count > 0) {
        [array removeObjectAtIndex:0];
    }
    return [[array valueForKey:@"description"] componentsJoinedByString:@""];
}

- (NSString *) getQueryFromPluginArguments:(NSMutableArray *)arguments urlString:(NSString *)aUrlString{
    NSString *query = nil;
    if (arguments.count > 2 && ![[arguments objectAtIndex:2] isEqual:[NSNull null]]){
        query = [self buildQuery:[arguments objectAtIndex:2] urlString:aUrlString];
    }
    return query;
}
#pragma mark - plugins methods

- (void)push:(NSMutableArray*)arguments withDict:(NSMutableDictionary*)options
{
    NSString *urlString = [arguments objectAtIndex:1];
    if (![self isValidOptions:options] || ![self isValidString:urlString]) {
        return;
    }
    
    NSString *relativeUrlString = [self getRelativePathTo:urlString];
    NSString *query = [self getQueryFromPluginArguments:arguments urlString:relativeUrlString];
    NSString *urlStringWithoutQuery = [[relativeUrlString componentsSeparatedByString:@"?"] objectAtIndex:0];
    
//    [viewController.cdvViewController.webView loadRequest:[self createRequest:urlStringWithoutQuery withQuery:query]];
    MFTabBarController *viewController = [[MFTabBarController alloc] initWithWwwDir:[MFUtility currentViewController].wwwFolderName path:urlStringWithoutQuery];

    MFNavigationController *nav;
    if ([[options objectForKey:@"target"] isEqualToString:@"tab"] || [MFUtility currentTabBarController] == nil) {
        nav = (MFNavigationController *)[MFUtility currentViewController].navigationController;
    } else {
        nav = (MFNavigationController *)[MFUtility currentTabBarController].navigationController;
    }
    
    if ([[options objectForKey:@"tabbarHidden"] isEqualToString:@"YES"]) {
        viewController.hidesBottomBarWhenPushed = YES;
    }
    
    BOOL animated;
    if ([[options objectForKey:@"animated"] isEqualToString:@"NO"]) {
        animated = NO;
    } else {
        animated = YES;
    }
    
    [nav pushViewController:viewController animated:animated];
}

- (void)pop:(NSMutableArray*)arguments withDict:(NSMutableDictionary*)options
{
    if (![self isValidOptions:options]) {
        return;
    }
    
    MFNavigationController *nav;
    if([MFUtility currentViewController].tabBarController != nil) {
        if ([[options objectForKey:@"target"] isEqualToString:@"tab"]) {
            nav = (MFNavigationController *)[MFUtility currentViewController].navigationController;
        } else {
            nav = (MFNavigationController *)[MFUtility currentTabBarController].navigationController;
        }
    } else {
        if ([[options objectForKey:@"target"] isEqualToString:@"tab"] == NO) {
            nav = (MFNavigationController *)[MFUtility currentViewController].navigationController;
        } else {
            return;
        }
    }
    BOOL animated;
    if ([[options objectForKey:@"animated"] isEqualToString:@"NO"]) {
        animated = NO;
    } else {
        animated = YES;
    }

    [MFUtility setCurrentTabBarController:nil];
    MFViewController *vc = (MFViewController*)[nav popViewControllerAnimated:animated];
//    [vc destroy];
    
/*    BOOL res = [[self class] changeDelegate:[[nav viewControllers] lastObject]];
    if (res) {
        NSString *command =[NSString stringWithFormat:@"%@ && %@();", kMonacaTransitPluginJsReactivate, kMonacaTransitPluginJsReactivate];
        [self writeJavascriptOnDelegateViewController:command];
    }
*/
}
- (void)modal:(NSMutableArray *)arguments withDict:(NSMutableDictionary *)options
{
    NSString *urlString = [arguments objectAtIndex:1];
    if (![self isValidOptions:options] || ![self isValidString:urlString]) {
        return;
    }

    NSString *relativeUrlString = [self getRelativePathTo:urlString];
    NSString *query = [self getQueryFromPluginArguments:arguments urlString:relativeUrlString];
    NSString *urlStringWithoutQuery = [[relativeUrlString componentsSeparatedByString:@"?"] objectAtIndex:0];

    MFNavigationController *nav;
    if([MFUtility currentViewController].tabBarController != nil) {
        if ([[options objectForKey:@"target"] isEqualToString:@"tab"]) {
            nav = (MFNavigationController *)[MFUtility currentViewController].navigationController;
        } else {
            nav = (MFNavigationController *)[MFUtility currentTabBarController].navigationController;
        }
    } else {
        if ([[options objectForKey:@"target"] isEqualToString:@"tab"] == NO) {
            nav = (MFNavigationController *)[MFUtility currentViewController].navigationController;
        } else {
            return;
        }
    }
    
    MFTabBarController *viewController = [[MFTabBarController alloc] initWithWwwDir:[MFUtility currentViewController].wwwFolderName path:urlStringWithoutQuery];

    CATransition *transition = [CATransition animation];
    transition.duration = 0.4f;
    transition.type = kCATransitionMoveIn;
    transition.subtype = kCATransitionFromTop;
    [transition setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionDefault]];

    if ([[options objectForKey:@"tabbarHidden"] isEqualToString:@"YES"]) {
        viewController.hidesBottomBarWhenPushed = YES;
    }
    
    BOOL animated;
    if ([[options objectForKey:@"animated"] isEqualToString:@"NO"]) {
        animated = NO;
    } else {
        animated = YES;
    }
    
    [nav.view.layer addAnimation:transition forKey:kCATransition];
    [nav pushViewController:viewController animated:NO];

/*
    [viewController.webView loadRequest:[self createRequest:urlStringWithoutQuery withQuery:query]];
    
//    [self setupViewController:viewController options:options];
//    [[self class] changeDelegate:viewController];

 */
}

@end
