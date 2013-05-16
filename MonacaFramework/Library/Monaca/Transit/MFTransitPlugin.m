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
#import "MFViewBuilder.h"

#define kMonacaTransitPluginJsReactivate @"window.onReactivate"
#define kMonacaTransitPluginOptionUrl @"url"
#define kMonacaTransitPluginOptionBg  @"bg"

@implementation MFTransitPlugin


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

- (NSString *)getRelativePathTo:(NSString *)filePath{
    NSString *currentDirectory = [[MFUtility currentViewController].webView.request.URL URLByDeletingLastPathComponent].filePathURL.path;
    NSString *urlString = [currentDirectory stringByAppendingPathComponent:filePath];
    if (urlString == nil)
        return filePath;
    NSURL *url = [NSURL fileURLWithPath:urlString];
    urlString = [url standardizedURL].path;
    NSMutableArray *array = [NSMutableArray arrayWithArray:[urlString componentsSeparatedByString:[MFViewBuilder getWwwDir]]];
    if (array.count > 0) {
        [array removeObjectAtIndex:0];
    }
    return [[array valueForKey:@"description"] componentsJoinedByString:@""];
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
    
    MFNavigationController *nav;
    if([MFUtility currentViewController].tabBarController != nil) {
        if ([[options objectForKey:@"target"] isEqualToString:@"tab"]) {
            [MFViewBuilder setIgnoreBottom:YES];
            [[MFUtility getAppDelegate].monacaNavigationController setNavigationBarHidden:YES];
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

    id viewController = [MFViewBuilder createViewControllerWithPath:urlStringWithoutQuery];
    [MFViewBuilder setIgnoreBottom:NO];
    
    [nav pushViewController:viewController animated:YES];
    
    if (query != nil) {
        if ([viewController isKindOfClass:[MFViewController class]]) {
            [[(MFViewController *)viewController webView] loadRequest:[self createRequest:urlStringWithoutQuery withQuery:query]];
        }
    }
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

    [(MFViewController *)[nav popViewControllerAnimated:animated] destroy];
    
/*    BOOL res = [[self class] changeDelegate:[[nav viewControllers] lastObject]];
    if (res) {
        NSString *command =[NSString stringWithFormat:@"%@ && %@();", kMonacaTransitPluginJsReactivate, kMonacaTransitPluginJsReactivate];
        [self writeJavascriptOnDelegateViewController:command];
    }
*/
}

- (void)modal:(NSMutableArray*)arguments withDict:(NSMutableDictionary*)options
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
            [MFViewBuilder setIgnoreBottom:YES];
            [[MFUtility getAppDelegate].monacaNavigationController setNavigationBarHidden:YES];
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
    
    CATransition *transition = [CATransition animation];
    transition.duration = 0.4f;
    transition.type = kCATransitionMoveIn;
    transition.subtype = kCATransitionFromTop;
    [transition setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionDefault]];

    id viewController = [MFViewBuilder createViewControllerWithPath:urlStringWithoutQuery];
    [MFViewBuilder setIgnoreBottom:NO];
    
    if ([viewController isKindOfClass:[MFViewController class]] && [[options objectForKey:@"tabbarHidden"] isEqualToString:@"YES"]) {
       ((MFViewController *)viewController).hidesBottomBarWhenPushed = YES;
    }
    
    BOOL animated;
    if ([[options objectForKey:@"animated"] isEqualToString:@"NO"]) {
        animated = NO;
    } else {
        animated = YES;
    }
    
    [nav.view.layer addAnimation:transition forKey:kCATransition];
    [nav pushViewController:viewController animated:NO];

    if (query != nil) {
        if ([viewController isKindOfClass:[MFViewController class]]) {
            [[(MFViewController *)viewController webView] loadRequest:[self createRequest:urlStringWithoutQuery withQuery:query]];
        }
    }
/*
    [viewController.webView loadRequest:[self createRequest:urlStringWithoutQuery withQuery:query]];
    
//    [self setupViewController:viewController options:options];
//    [[self class] changeDelegate:viewController];

 */
}

- (void)dismiss:(NSMutableArray*)arguments withDict:(NSMutableDictionary*)options
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
    
    CATransition *transition = [CATransition animation];
    transition.duration = 0.4f;
    transition.type = kCATransitionReveal;
    transition.subtype = kCATransitionFromBottom;
    [transition setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionDefault]];

    [nav.view.layer addAnimation:transition forKey:kCATransition];
    
    [(MFViewController *)[nav popViewControllerAnimated:NO] destroy];

/*
    BOOL res = [[self class] changeDelegate:[[nav viewControllers] lastObject]];
    if (res) {
        NSString *command =[NSString stringWithFormat:@"%@ && %@();", kMonacaTransitPluginJsReactivate, kMonacaTransitPluginJsReactivate];
        [self writeJavascriptOnDelegateViewController:command];
    }
 */
}


- (void)home:(NSMutableArray*)arguments withDict:(NSMutableDictionary*)options
{
    NSString *fileName = [options objectForKey:kMonacaTransitPluginOptionUrl];

    UINavigationController *nav = [MFUtility currentViewController].navigationController;
    [self popToHomeViewController:YES];

    UIViewController *viewController = [[nav viewControllers] objectAtIndex:0];

//    BOOL res = [[self class] changeDelegate:viewController];
//    if (res) {
        if (fileName) {
            [self.webView loadRequest:[self createRequest:fileName withQuery:nil]];
        }
        NSString *command =[NSString stringWithFormat:@"%@ && %@();", kMonacaTransitPluginJsReactivate, kMonacaTransitPluginJsReactivate];
        [self writeJavascript:command];
//    }
}

- (void)popToHomeViewController:(BOOL)isAnimated
{
    NSArray *viewControllers = [[MFUtility currentViewController].navigationController popToRootViewControllerAnimated:isAnimated];
    
    for (MFViewController *vc in viewControllers) {
        [vc destroy];
    }
}

- (void)browse:(NSMutableArray*)arguments withDict:(NSMutableDictionary*)options
{
    NSString *urlString = [arguments objectAtIndex:1];
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:urlString]];
}

- (void)link:(NSMutableArray*)arguments withDict:(NSMutableDictionary*)options
{
    NSString *urlString = [self getRelativePathTo:[arguments objectAtIndex:1]];
    NSString *query = [self getQueryFromPluginArguments:arguments urlString:urlString];
    NSString *urlStringWithoutQuery = [[urlString componentsSeparatedByString:@"?"] objectAtIndex:0];
    
    [[MFUtility currentViewController].webView loadRequest:[self createRequest:urlStringWithoutQuery withQuery:query]];
}


- (NSString*) buildQuery:(NSDictionary *)jsonQueryParams urlString:(NSString *)urlString
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

- (NSString*) getQueryFromPluginArguments:(NSMutableArray *)arguments urlString:(NSString *)aUrlString{
    NSString *query = nil;
    if (arguments.count > 2 && ![[arguments objectAtIndex:2] isEqual:[NSNull null]]){
        query = [self buildQuery:[arguments objectAtIndex:2] urlString:aUrlString];
    }
    return query;
}

- (BOOL)isValidString:(NSString *)urlString {
    if (urlString.length > 512) {
        NSLog(@"[error] MonacaTransitException::Too long path length:%@", urlString);
        return NO;
    }
    return YES;
}

- (BOOL)isValidOptions:(NSDictionary *)options {
    for (NSString *key in options) {
        NSObject *option = [options objectForKey:key];
        
        if ([option isKindOfClass:NSString.class] && ((NSString *)option).length > 512) {
            NSLog(@"[error] MonacaTransitException::Too long option length:%@, %@", key, [options objectForKey:key]);
            return NO;
        }
    }
    return YES;
}



@end
