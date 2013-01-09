//
//  MonacaTransitPlugin.m
//  MonacaFramework
//
//  Created by air on 12/06/28.
//  Copyright (c) 2012年 ASIAL CORPORATION. All rights reserved.
//
#import <QuartzCore/QuartzCore.h>

#import "MFTransitPlugin.h"
#import "MFDelegate.h"
#import "MFViewController.h"
#import "MFTabBarController.h"
#import "MFUtility.h"

#define kMonacaTransitPluginJsReactivate @"window.onReactivate"
#define kMonacaTransitPluginOptionUrl @"url"
#define kMonacaTransitPluginOptionBg  @"bg"

@implementation MFTransitPlugin

#pragma mark - private methods

- (MFDelegate *)monacaDelegate
{
    return (MFDelegate *)[self appDelegate];
}

- (MFNavigationController *)monacaNavigationController
{
    return [[self monacaDelegate] monacaNavigationController];
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

// @see [MonacaDelegate application: didFinishLaunchingWithOptions:]
- (void)setupViewController:(MFViewController *)viewController options:(NSDictionary *)options
{
    viewController.monacaPluginOptions = options;
    [MFUtility setupMonacaViewController:viewController];
}

+ (void)setBgColor:(MFViewController *)viewController color:(UIColor *)color
{
    viewController.cdvViewController.webView.backgroundColor = [UIColor clearColor];
    viewController.cdvViewController.webView.opaque = NO;

    UIScrollView *scrollView = nil;
    if ([[[UIDevice currentDevice] systemVersion] floatValue] < 5.0f) {
        for (UIView *subview in [viewController.cdvViewController.webView subviews]) {
            if ([[subview.class description] isEqualToString:@"UIScrollView"]) {
                scrollView = (UIScrollView *)subview;
            }
        }
    } else {
        scrollView = (UIScrollView *)[viewController.cdvViewController.webView scrollView];
    }

    if (scrollView) {
        scrollView.opaque = NO;
        scrollView.backgroundColor = [UIColor clearColor];
        // Remove shadow
        for (UIView *subview in [scrollView subviews]) {
            if([subview isKindOfClass:[UIImageView class]]){
                subview.hidden = YES;
            }
        }
    }

    viewController.view.opaque = YES;
    viewController.view.backgroundColor = color;
}

#pragma mark - public methods

+ (BOOL)changeDelegate:(UIViewController *)viewController
{
    if(![viewController isKindOfClass:[MFViewController class]]){
        return NO;
    }

    MFDelegate *monacaDelegate = (MFDelegate *)[[UIApplication sharedApplication] delegate];
    monacaDelegate.viewController = (MFViewController *)viewController;

    return YES;
}

#pragma mark - MonacaViewController actions

+ (void)viewDidLoad:(MFViewController *)viewController
{
    // @todo MonacaViewController内部にて実行すべき事柄
    if(![viewController isKindOfClass:[MFViewController class]]) {
        return;
    }

    if (viewController.monacaPluginOptions) {
        NSString *bgName = [viewController.monacaPluginOptions objectForKey:kMonacaTransitPluginOptionBg];
        if (bgName) {
            NSURL *appWWWURL = [[MFUtility getAppDelegate] getBaseURL];
            NSString *bgPath = [appWWWURL.path stringByAppendingFormat:@"/%@", bgName];
            UIImage *bgImage = [UIImage imageWithContentsOfFile:bgPath];
            if (bgImage) {
                [[self class] setBgColor:viewController color:[UIColor colorWithPatternImage:bgImage]];
            }
        }
    }
}

+ (void)webViewDidFinishLoad:(UIWebView*)theWebView viewController:(MFViewController *)viewController
{
    if (!viewController.monacaPluginOptions || ![viewController.monacaPluginOptions objectForKey:kMonacaTransitPluginOptionBg]) {
        theWebView.backgroundColor = [UIColor blackColor];
    }
}

- (NSString *)getRelativePathTo:(NSString *)filePath{
    NSString *currentDirectory = [[self monacaDelegate].viewController.cdvViewController.webView.request.URL URLByDeletingLastPathComponent].filePathURL.path;
    NSString *urlString = [currentDirectory stringByAppendingPathComponent:filePath];
    NSMutableArray *array = [NSMutableArray arrayWithArray:[urlString componentsSeparatedByString:@"www/"]];
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

    MFViewController *viewController = [[MFViewController alloc] initWithFileName:urlStringWithoutQuery];
    [viewController.cdvViewController.webView loadRequest:[self createRequest:urlStringWithoutQuery withQuery:query]];

    [self setupViewController:viewController options:options];
    [[self class] changeDelegate:viewController];

    [[self monacaNavigationController] pushViewController:viewController animated:YES];
}

- (void)pop:(NSMutableArray*)arguments withDict:(NSMutableDictionary*)options
{
    MFNavigationController *nav = [self monacaNavigationController];
    MFViewController *vc = (MFViewController*)[nav popViewControllerAnimated:YES];
    [vc destroy];

    BOOL res = [[self class] changeDelegate:[[nav viewControllers] lastObject]];
    if (res) {
        NSString *command =[NSString stringWithFormat:@"%@ && %@();", kMonacaTransitPluginJsReactivate, kMonacaTransitPluginJsReactivate];
        [self writeJavascriptOnDelegateViewController:command];
    }
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
    
    MFViewController *viewController = [[MFViewController alloc] initWithFileName:urlStringWithoutQuery];
    [viewController.cdvViewController.webView loadRequest:[self createRequest:urlStringWithoutQuery withQuery:query]];

    [self setupViewController:viewController options:options];
    [[self class] changeDelegate:viewController];

    NSString *transitionSubtype;
    UIInterfaceOrientation orientation = viewController.interfaceOrientation;
    switch (orientation) {
        case UIInterfaceOrientationPortrait: // Device oriented vertically, home button on the bottom
            transitionSubtype = kCATransitionFromTop;
            break;
        case UIInterfaceOrientationPortraitUpsideDown: // Device oriented vertically, home button on the top
            transitionSubtype = kCATransitionFromBottom;
            break;
        case UIInterfaceOrientationLandscapeLeft: // Device oriented horizontally, home button on the right
            transitionSubtype = kCATransitionFromRight;
            break;
        case UIInterfaceOrientationLandscapeRight: // Device oriented horizontally, home button on the left
            transitionSubtype = kCATransitionFromLeft;
            break;
        default:
            transitionSubtype = kCATransitionFromTop;
            break;
    }

    CATransition *transition = [CATransition animation];
    transition.duration = 0.4f;
    transition.type = kCATransitionMoveIn;
    transition.subtype = transitionSubtype;
    [transition setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionDefault]];

    MFNavigationController *nav = [self monacaNavigationController];
    [nav.view.layer addAnimation:transition forKey:kCATransition];
    [nav pushViewController:viewController animated:NO];
}

- (void)dismiss:(NSMutableArray*)arguments withDict:(NSMutableDictionary*)options
{
    NSString *transitionSubtype;
    UIInterfaceOrientation orientation = self.viewController.interfaceOrientation;
    switch (orientation) {
        case UIInterfaceOrientationPortrait: // Device oriented vertically, home button on the bottom
            transitionSubtype = kCATransitionFromBottom;
            break;
        case UIInterfaceOrientationPortraitUpsideDown: // Device oriented vertically, home button on the top
            transitionSubtype = kCATransitionFromTop;
            break;
        case UIInterfaceOrientationLandscapeLeft: // Device oriented horizontally, home button on the right
            transitionSubtype = kCATransitionFromLeft;
            break;
        case UIInterfaceOrientationLandscapeRight: // Device oriented horizontally, home button on the left
            transitionSubtype = kCATransitionFromRight;
            break;
        default:
            transitionSubtype = kCATransitionFromBottom;
            break;
    }

    CATransition *transition = [CATransition animation];
    transition.duration = 0.4f;
    transition.type = kCATransitionReveal;
    transition.subtype = transitionSubtype;
    [transition setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionDefault]];

    MFNavigationController *nav = [self monacaNavigationController];
    [nav.view.layer addAnimation:transition forKey:kCATransition];
    MFViewController *vc = (MFViewController*)[nav popViewControllerAnimated:YES];
    [vc destroy];

    BOOL res = [[self class] changeDelegate:[[nav viewControllers] lastObject]];
    if (res) {
        NSString *command =[NSString stringWithFormat:@"%@ && %@();", kMonacaTransitPluginJsReactivate, kMonacaTransitPluginJsReactivate];
        [self writeJavascriptOnDelegateViewController:command];
    }
}

- (void)home:(NSMutableArray*)arguments withDict:(NSMutableDictionary*)options
{
    NSString *fileName = [options objectForKey:kMonacaTransitPluginOptionUrl];

    UINavigationController *nav = [self monacaNavigationController];
    [self popToHomeViewController:YES];

    UIViewController *viewController = [[nav viewControllers] objectAtIndex:0];
    BOOL res = [[self class] changeDelegate:viewController];
    if (res) {
        if (fileName) {
            [self.webView loadRequest:[self createRequest:fileName withQuery:nil]];
        }
        NSString *command =[NSString stringWithFormat:@"%@ && %@();", kMonacaTransitPluginJsReactivate, kMonacaTransitPluginJsReactivate];
        [self writeJavascript:command];
    }
}

- (void)popToHomeViewController:(BOOL)isAnimated
{
    NSArray *viewControllers = [[self monacaNavigationController] popToRootViewControllerAnimated:isAnimated];
    
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
    
    [[self monacaDelegate].viewController.cdvViewController.webView loadRequest:[self createRequest:urlStringWithoutQuery withQuery:query]];
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

- (NSString *) getQueryFromPluginArguments:(NSMutableArray *)arguments urlString:(NSString *)aUrlString{
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
        if (((NSString *)[options objectForKey:key]).length > 512) {
            NSLog(@"[error] MonacaTransitException::Too long option length:%@, %@", key, [options objectForKey:key]);
            return NO;
        }
    }
    return YES;
}

- (NSString*) writeJavascriptOnDelegateViewController:(NSString*)javascript
{
    MFViewController *vc = [self monacaDelegate].viewController;
    return [vc.cdvViewController.webView stringByEvaluatingJavaScriptFromString:javascript];
}

@end
