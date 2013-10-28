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
#import "MFDummyViewController.h"
#import "MFUIChecker.h"

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
    
    [self getQueryFromPluginArguments:arguments urlString:urlString];
    NSString *urlStringWithoutQuery = [[urlString componentsSeparatedByString:@"?"] objectAtIndex:0];

    MFNavigationController *navigationController;
    navigationController = [MFUtility getAppDelegate].monacaNavigationController;
    
    MFViewController *viewController = [MFViewBuilder createViewControllerWithPath:[self getRelativePathTo:urlStringWithoutQuery]];

    if (parameter.transition != nil) {
        [navigationController.view.layer addAnimation:parameter.transition forKey:kCATransition];
    }
    
    [navigationController pushViewController:viewController animated:parameter.hasDefaultPushAnimation];
    if ([viewController isKindOfClass:[MFViewController class]]) {
        [viewController setTransitAnimated:parameter.hasDefaultPushAnimation];
    }
    
    if (parameter.clearStack) {
        NSMutableArray * controllers = [NSMutableArray arrayWithArray:[MFViewManager currentViewController].navigationController.viewControllers];
         if (controllers.count > 2) {
             [controllers removeObjectAtIndex:controllers.count - 2];
         }
         
        [[MFViewManager currentViewController].navigationController setViewControllers:controllers animated:NO];
    }
}

- (void)popGenerically:(NSMutableArray*)arguments withDict:(NSMutableDictionary*)options
{
    MFTransitPopParameter* parameter = [MFTransitPopParameter parseOptionsDict:options];
    
    MFNavigationController *navigationController;
    if ([MFViewManager isViewControllerTop]) {
        navigationController = [MFUtility getAppDelegate].monacaNavigationController;
    } else {
        navigationController = (MFNavigationController *)[MFViewManager currentViewController].navigationController;
    }

    
    MFViewController *vc = (MFViewController*)[navigationController popViewControllerAnimated:parameter.hasDefaultPopAnimation];
    [vc destroy];
    
    if (vc != nil) {
        if (parameter.transition != nil) {
            parameter.transition.delegate = self;
            [navigationController.view.layer addAnimation:parameter.transition forKey:kCATransition];
        } else {
            [NSTimer scheduledTimerWithTimeInterval:0.5f target:self selector:@selector(reactivate) userInfo:nil repeats:NO];
        }
    }
}

- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag
{
    [NSTimer scheduledTimerWithTimeInterval:0.0f target:self selector:@selector(reactivate) userInfo:nil repeats:NO];
}

- (void)reactivate
{
    NSString *command =[NSString stringWithFormat:@"%@ && %@();", kMonacaTransitPluginJsReactivate, kMonacaTransitPluginJsReactivate];
    [self writeJavascriptOnDelegateViewController:command];
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

    BOOL ret = [self popToHomeViewController:YES];

    if (ret) {
        if (fileName) {
            [[MFViewManager currentViewController].webView loadRequest:[self createRequest:fileName withQuery:nil]];
        }
        [NSTimer scheduledTimerWithTimeInterval:0.5f target:self selector:@selector(reactivate) userInfo:nil repeats:NO];
    }
}

- (void)clearPageStack:(NSMutableArray*)arguments withDict:(NSMutableDictionary*)options
{
    id clearAll = [arguments objectAtIndex:1];
    NSMutableArray *controllers;
    
    if ([clearAll isKindOfClass:NSNumber.class] && [clearAll isEqualToNumber:[NSNumber numberWithBool:YES]]) {
        controllers = [NSMutableArray array];
        [controllers addObject:[[MFDummyViewController alloc] init]];
        [controllers addObject:[MFViewManager currentViewController]];
    } else {
        controllers = [NSMutableArray arrayWithArray:[MFViewManager currentViewController].navigationController.viewControllers];
        if (controllers.count > 2) {
            [controllers removeObjectAtIndex:controllers.count - 2];
        }
    }
    
    [[MFViewManager currentViewController].navigationController setViewControllers:controllers animated:NO];
    [[MFViewManager currentViewController] applyBarUserInterface];
}

- (BOOL)popToHomeViewController:(BOOL)isAnimated
{
    NSArray *viewControllers = [[MFUtility getAppDelegate].monacaNavigationController popToRootViewControllerAnimated:isAnimated];
    
    for (MFViewController *vc in viewControllers) {
        [vc destroy];
    }
    
    return viewControllers != nil ? YES: NO;
}

- (void)browse:(NSMutableArray*)arguments withDict:(NSMutableDictionary*)options
{
    NSString *urlString = [arguments objectAtIndex:1];
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:urlString]];
}

- (void)link:(NSMutableArray*)arguments withDict:(NSMutableDictionary*)options
{
    NSString *urlString = [arguments objectAtIndex:1];
    [self getQueryFromPluginArguments:arguments urlString:urlString];
    NSString *urlStringWithoutQuery = [[urlString componentsSeparatedByString:@"?"] objectAtIndex:0];

    [[MFViewManager currentViewController] removeUserInterface];
    
    NSString *fullPath = [[MFViewManager currentWWWFolderName] stringByAppendingPathComponent:urlStringWithoutQuery];
    NSMutableDictionary *uidict = [[MFUtility parseJSONFile:[MFUtility getUIFileName:fullPath]] mutableCopy];
    [MFUIChecker checkUI:uidict];
    
    NSDictionary *bottom = [uidict objectForKey:kNCPositionBottom];
    if ([[bottom objectForKey:kNCTypeContainer] isEqualToString:kNCContainerTabbar] && ([MFViewManager isViewControllerTop])) {
        MFTabBarController *tabarController = [MFViewBuilder createTabbarControllerWithPath:fullPath withDict:uidict];
        [tabarController setCustomizableViewControllers:nil];
        NSMutableArray *viewControllers = [[MFViewManager currentViewController].navigationController.viewControllers mutableCopy];
        [viewControllers removeLastObject];
        [viewControllers addObject:tabarController];
        [[MFUtility getAppDelegate].monacaNavigationController setViewControllers:viewControllers];
    } else {
        if ([MFViewManager isTabbarControllerTop]) {
            [uidict removeObjectForKey:kNCPositionBottom];
        }
        [MFViewManager setCurrentWWWFolderName:[fullPath stringByDeletingLastPathComponent]];
        [[MFViewManager currentViewController] setBarUserInterface:uidict];
        [[MFViewManager currentViewController] applyBarVisibility:NO];
        [[MFViewManager currentViewController].webView loadRequest:[self createRequest:urlStringWithoutQuery withQuery:nil]];
    }
}

- (NSString *)encode:(id)object
{
    if ([object isKindOfClass:NSString.class]) {
        return [MFUtility urlEncode:object];
    }
    if ([object isKindOfClass:NSNumber.class]) {
        return [NSString stringWithFormat:@"%@", object];
    }
    if ([object isKindOfClass:NSArray.class]) {
        NSArray *array = (NSArray *)object;
        NSString *string = @"[";
        NSEnumerator *enumerator = [array objectEnumerator];
        id obj = [enumerator nextObject];
        while (obj) {
            string = [string stringByAppendingString:[self encode:obj]];
            obj = [enumerator nextObject];
            if (obj)
                string = [string stringByAppendingString:@","];
        }
        return [string stringByAppendingString:@"]"];
    }
/*    if ([object isKindOfClass:NSDictionary.class]) {
        NSDictionary *dict = (NSDictionary *)object;
        NSString *string = @"{";
        NSEnumerator *enumerator = [dict keyEnumerator];
        id key = [enumerator nextObject];
        while (key) {
            string = [string stringByAppendingFormat:@"%@=", [self encode:key]];
            string = [string stringByAppendingString:[self encode:[dict objectForKey:key]]];
            key = [enumerator nextObject];
                if (key)
                string = [string stringByAppendingString:@","];
        }
        return [string stringByAppendingString:@"}"];
    }
 */
    return @"";
}

- (NSString*) buildQuery:(NSDictionary *)jsonQueryParams urlString:(NSString *)urlString
{
    NSString *query = @"";
    NSArray *array = [urlString componentsSeparatedByString:@"?"];
    if (array.count > 1) {
        query = [array objectAtIndex:1];
    }
    
        NSMutableArray *queryParams = [NSMutableArray array];
        for (NSString *key in jsonQueryParams) {
            NSString *encodedKey = [MFUtility urlEncode:key];
            NSString *encodedValue = nil;
            if ([[jsonQueryParams objectForKey:key] isEqual:[NSNull null]]){
                [queryParams addObject:[NSString stringWithFormat:@"%@", encodedKey]];
            }else {
                id jsonQueryParamsValue = [jsonQueryParams objectForKey:key];
                
                if([jsonQueryParamsValue isKindOfClass:[NSString class]])
                {
                    encodedValue = [MFUtility urlEncode:[jsonQueryParams objectForKey:key]];
                    [queryParams addObject:[NSString stringWithFormat:@"%@=%@", encodedKey, encodedValue]];
                }
                else if([jsonQueryParamsValue isKindOfClass:[NSNumber class]])
                {
                    NSString *jsonStringValue = [jsonQueryParamsValue stringValue];
                    [queryParams addObject:[NSString stringWithFormat:@"%@=%@", encodedKey, jsonStringValue]];
                }            }
        }
        if([query isEqualToString:@""]){
            query = [[[queryParams reverseObjectEnumerator] allObjects] componentsJoinedByString:@"&"];
        }else{
            query = [NSString stringWithFormat:@"%@&%@",query,[[[queryParams reverseObjectEnumerator] allObjects] componentsJoinedByString:@"&"]];
        }
        [MFUtility setQueryParams:[NSMutableDictionary dictionaryWithObject:query forKey:@"queryString"]];

    return [query isEqualToString:@""]?nil:query;
}

- (NSString*) getQueryFromPluginArguments:(NSMutableArray *)arguments urlString:(NSString *)aUrlString{
    NSString *query = nil;
    if (arguments.count > 2 && ![[arguments objectAtIndex:2] isEqual:[NSNull null]]){
        query = [self buildQuery:[arguments objectAtIndex:2] urlString:aUrlString];
    } else {
        query = [self buildQuery:nil urlString:aUrlString];
    }
    return query;
}

- (BOOL)isValidString:(NSString *)urlString {
    if (![urlString isKindOfClass:[NSString class]]) {
        return NO;
    }
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
