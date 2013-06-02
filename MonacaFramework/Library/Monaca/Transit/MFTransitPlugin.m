//
//  MFTransitPlugin.m
//  MonacaFramework
//
//  Created by air on 12/06/28.
//  Copyright (c) 2012年 ASIAL CORPORATION. All rights reserved.
//
#import <QuartzCore/QuartzCore.h>

#import "MFTransitPlugin.h"
#import "MFViewController.h"
#import "MFUtility.h"
#import "MFViewBuilder.h"
#import "MFViewManager.h"
#import "MFTransitPushParameter.h"
#import "MFTransitPopParameter.h"

@implementation MFTransitPlugin

- (NSURLRequest *)createRequest:(NSString *)urlString withQuery:(NSString *)query
{
    NSString *path, *fragment = nil;
    // separate to path and fragment
    {
        NSArray *array = [urlString componentsSeparatedByString:@"#"];
        path = [array objectAtIndex:0];
        fragment = nil;
        if (array.count > 1) {
            fragment = [array objectAtIndex:1];
        }
    }
    
    NSURL *url;
    if ([self.commandDelegate pathForResource:path]) {
        url = [NSURL fileURLWithPath:[self.commandDelegate pathForResource:path]];
        if ([query.class isSubclassOfClass:[NSString class]]) {
            url = [NSURL URLWithString:[url.absoluteString stringByAppendingFormat:@"?%@", query]];
        }
        if ([fragment.class isSubclassOfClass:[NSString class]]) {
            url = [NSURL URLWithString:[url.absoluteString stringByAppendingFormat:@"#%@", fragment]];
        }
    } else {
        url = [NSURL URLWithString:[@"monaca404:///www/" stringByAppendingPathComponent:urlString]];
    }
    
    return [NSURLRequest requestWithURL:url];
}

- (NSString *)getRelativePathTo:(NSString *)filePath{
    if ([self.commandDelegate pathForResource:filePath]) {
        NSString *path = [MFUtility getWWWShortPath:[self.commandDelegate pathForResource:filePath]];
        return [path substringFromIndex:[path rangeOfString:@"www"].location + [@"www" length]];
    }
    return filePath;
}

- (void)pushGenerically:(NSMutableArray *)arguments withDict:(NSMutableDictionary *)options
{
    NSString *urlString = [arguments objectAtIndex:1];
    if (![self isValidOptions:options] || ![self isValidString:urlString]) {
        return;
    }
    
    MFTransitPushParameter* parameter = [MFTransitPushParameter parseOptionsDict:options];
    
    NSString *relativeUrlString = [self getRelativePathTo:urlString];
    NSString *query = [self getQueryFromPluginArguments:arguments urlString:relativeUrlString];
    NSString *urlStringWithoutQuery = [[relativeUrlString componentsSeparatedByString:@"?"] objectAtIndex:0];

    MFNavigationController *navigationController;
    if ([parameter.target isEqualToString:@"_parent"]) {
        navigationController = [MFUtility getAppDelegate].monacaNavigationController;
    } else {
        [MFViewBuilder setIgnoreBottom:YES];
        navigationController = (MFNavigationController *)[MFViewManager currentViewController].navigationController;
    }
    
    MFViewController *viewController = [MFViewBuilder createViewControllerWithPath:urlStringWithoutQuery];
    [MFViewBuilder setIgnoreBottom:NO];

//    [self.class changeDelegate:viewController];

    UIViewController *previousController;
    if (parameter.clearStack) {
        previousController = [navigationController popViewControllerAnimated:NO];
    }

    if (parameter.transition != nil) {
        [navigationController.view.layer addAnimation:parameter.transition forKey:kCATransition];
    }
    
    [navigationController pushViewController:viewController animated:parameter.hasDefaultPushAnimation];
    
    if (parameter.clearStack) {
        if (previousController == nil) {
            [navigationController setViewControllers:[NSArray arrayWithObject:viewController] animated:NO];
        }
    }
    if (query != nil) {
        [viewController.webView loadRequest:[self createRequest:urlStringWithoutQuery withQuery:query]];
     }
}

- (void)popGenerically:(NSMutableArray*)arguments withDict:(NSMutableDictionary*)options
{
    MFTransitPopParameter* parameter = [MFTransitPopParameter parseOptionsDict:options];
    
    MFNavigationController *navigationController;
    if ([parameter.target isEqualToString:@"_parent"]) {
        navigationController = [MFUtility getAppDelegate].monacaNavigationController;
    } else {
        [MFViewBuilder setIgnoreBottom:YES];
        navigationController = (MFNavigationController *)[MFViewManager currentViewController].navigationController;
    }

    if (parameter.transition != nil) {
        [navigationController.view.layer addAnimation:parameter.transition forKey:kCATransition];
    }
    
    MFViewController *vc = (MFViewController*)[navigationController popViewControllerAnimated:parameter.hasDefaultPopAnimation];
    [vc destroy];
/*
    BOOL res = [[self class] changeDelegate:[[navigationController viewControllers] lastObject]];
    if (res) {
        NSString *command =[NSString stringWithFormat:@"%@ && %@();", kMonacaTransitPluginJsReactivate, kMonacaTransitPluginJsReactivate];
        [self writeJavascriptOnDelegateViewController:command];
    }
 */
}

#pragma mark - plugins methods


- (void)push:(NSMutableArray*)arguments withDict:(NSMutableDictionary*)options
{
    [self pushGenerically:arguments withDict:options];
}


- (void)slideRight:(NSMutableArray*)arguments withDict:(NSMutableDictionary*)options
{
    [self pushGenerically:arguments withDict:options];
}

- (void)modal:(NSMutableArray*)arguments withDict:(NSMutableDictionary*)options
{
    [self pushGenerically:arguments withDict:options];
}

- (void)pop:(NSMutableArray*)arguments withDict:(NSMutableDictionary*)options
{
    [self popGenerically:arguments withDict:options];
}

- (void)dismiss:(NSMutableArray*)arguments withDict:(NSMutableDictionary*)options
{
    [self popGenerically:arguments withDict:options];
}

- (void)home:(NSMutableArray*)arguments withDict:(NSMutableDictionary*)options
{
    NSString *fileName = [options objectForKey:kMonacaTransitPluginOptionUrl];

    UINavigationController *nav = [MFViewManager currentViewController].navigationController;
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

- (void)clearPageStack:(NSMutableArray*)arguments withDict:(NSMutableDictionary*)options
{
    id clearAll = [arguments objectAtIndex:1];
    NSMutableArray *controllers;
    
    if ([clearAll isKindOfClass:NSNumber.class] && [clearAll isEqualToNumber:[NSNumber numberWithBool:YES]]) {
        controllers = [NSMutableArray arrayWithObject:[MFViewManager currentViewController]];
    } else {
        controllers = [NSMutableArray arrayWithArray:[MFViewManager currentViewController].navigationController.viewControllers];
        if (controllers.count > 1) {
            [controllers removeObjectAtIndex:controllers.count - 2];
        }
    }
    
    [[MFUtility getAppDelegate].monacaNavigationController setViewControllers:controllers animated:NO];
}

- (void)popToHomeViewController:(BOOL)isAnimated
{
    NSArray *viewControllers = [[MFViewManager currentViewController].navigationController popToRootViewControllerAnimated:isAnimated];
    
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
    NSString *urlString = [arguments objectAtIndex:1];
    NSString *query = [self getQueryFromPluginArguments:arguments urlString:urlString];
    NSString *urlStringWithoutQuery = [[urlString componentsSeparatedByString:@"?"] objectAtIndex:0];

    [[MFViewManager currentViewController] removeUserInterface];
    
    NSString *fullPath = [[MFViewManager currentWWWFolderName] stringByAppendingPathComponent:urlStringWithoutQuery];
    NSMutableDictionary *uidict = [[MFUtility parseJSONFile:[MFUtility getUIFileName:fullPath]] mutableCopy];
    
    NSDictionary *bottom = [uidict objectForKey:kNCPositionBottom];
    if ([[bottom objectForKey:kNCTypeContainer] isEqualToString:kNCContainerTabbar] && [MFViewManager isViewControllerTop]) {
        MFTabBarController *tabarController = [MFViewBuilder createTabbarControllerWithPath:fullPath withDict:uidict];
        NSMutableArray *viewControllers = [[MFViewManager currentViewController].navigationController.viewControllers mutableCopy];
        [viewControllers removeLastObject];
        [viewControllers addObject:tabarController];
        [[MFViewManager currentViewController].navigationController setViewControllers:viewControllers];
    } else {
        [[MFViewManager currentViewController] setBarUserInterface:uidict];
        [[MFViewManager currentViewController] applyBarUserInterface];
        [[MFViewManager currentViewController].webView loadRequest:[self createRequest:urlStringWithoutQuery withQuery:query]];
    }
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

- (NSString*) writeJavascriptOnDelegateViewController:(NSString*)javascript
{
    MFViewController *vc = [MFViewManager currentViewController];
    return [vc.webView stringByEvaluatingJavaScriptFromString:javascript];
}

@end
