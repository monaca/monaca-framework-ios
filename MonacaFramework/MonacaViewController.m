//
//  MonacaViewController.m
//  Template
//
//  Created by Hiroki Nakagawa on 11/06/07.
//  Copyright 2011 ASIAL CORPORATION. All rights reserved.
//

#import "MonacaViewController.h"
#import "MonacaTabBarController.h"
#import "JSONKit.h"
#import "MonacaTemplateEngine.h"
#import "MonacaTransitPlugin.h"
#import "Utility.h"
#import "MonacaEvent.h"

@interface MonacaViewController ()
- (NSString *)careWWWdir:(NSString *)path;
- (void)processDataTypes;
@end

@implementation MonacaViewController

@synthesize scrollView = scrollView_;
@synthesize previousPath = previousPath_;
@synthesize recall = recall_;
@synthesize monacaPluginOptions;

@synthesize tabBarController;
@synthesize appNavigationController;
@synthesize cdvViewController;

// Parses *.ui files.

- (NSDictionary *)parseJSONFile:(NSString *)path {
    NSError *error = nil;
    NSString *data = [NSString stringWithContentsOfFile:path
                                               encoding:NSUTF8StringEncoding
                                                  error:&error];
    if (data == nil) {
        NSMutableDictionary *info = [NSMutableDictionary dictionary];
        [info setObject:path forKey:@"path"];
        [MonacaEvent dispatchEvent:monacaEventNoUIFile withInfo:info];
        return nil;
    }
    if (YES){
        data = [data stringByReplacingOccurrencesOfString:@"((?:\".*?\"[^\"]*?)*)[\"]*(\\w+)[\"]*\\s*:"
                                               withString:@"$1\"$2\":"
                                                  options:NSRegularExpressionSearch
                                                    range:NSMakeRange(0, [data length])];
    }
    id jsonString = [data cdvjk_objectFromJSONStringWithParseOptions:CDVJKParseOptionStrict error:&error];
    
    // send log error
    if (error) {
        NSMutableDictionary *info = [NSMutableDictionary dictionary];
        [info setObject:error forKey:@"error"];
        [info setObject:path forKey:@"path"];
        [MonacaEvent dispatchEvent:monacaEventNCParseError withInfo:info];
    } else {
        NSMutableDictionary *info = [NSMutableDictionary dictionary];
        [info setObject:path forKey:@"path"];
        [MonacaEvent dispatchEvent:monacaEventNCParseSuccess withInfo:info];
    }

    // return ui dictionary
    if (jsonString == nil) {
        return [NSMutableDictionary dictionary];
    } else {
        CFDictionaryRef cfUiDict = CFPropertyListCreateDeepCopy(kCFAllocatorDefault,
                                                                (__bridge CFPropertyListRef)(jsonString),
                                                                kCFPropertyListMutableContainers);
        NSMutableDictionary *uidict = [NSMutableDictionary dictionaryWithDictionary:(__bridge NSMutableDictionary *)cfUiDict];
        CFRelease(cfUiDict);
        return uidict;
    }
}

+ (BOOL)isPhoneGapScheme:(NSURL *)url {
    return ([[url scheme] isEqualToString:@"gap"]);
}

+ (BOOL)isExternalPage:(NSURL *)url {
    return ([[url scheme] isEqualToString:@"http"] ||
            [[url scheme] isEqualToString:@"https"]);
}

// Returns YES if |url| has anchor parameter (http://example.com/index.html#aaa).
// TODO(nhiroki): Should use fragment method in NSURL class.
+ (BOOL)hasAnchor:(NSURL *)url {
    NSRange searchResult = [[url absoluteString] rangeOfString:@"#"];
    return searchResult.location != NSNotFound;
}

+ (NSURL *)standardizedURL:(NSURL *)url {
    // Standardize relative path ("." and "..").
    url = [url standardizedURL];
    NSString *last = [url lastPathComponent];
    
    // Replace double thrash to single thrash ("//" => "/").
    NSString *tmp = [url absoluteString];
    NSString *str = [tmp stringByReplacingOccurrencesOfString:@"//" withString:@"/"];
    while (![str isEqualToString:tmp]) {
        tmp = str;
        str = [tmp stringByReplacingOccurrencesOfString:@"//" withString:@"/"];
    }
    
    // Remove |index.html| ("/www/item/index.html" => "/www/item").
    if ([last isEqualToString:@"index.html"]) {
        str = [str substringToIndex:[str length] - [@"/index.html" length]];
    }
    
    return [NSURL URLWithString:str];
}

- (id)init{
    self = [super init];
    if (self){
        uiSetting = nil;
    }
    return self;
}

- (id)initWithFileName:(NSString *)fileName query:(NSString *)aQuery{
    self = [self init];
    if (nil != self) {
        cdvViewController = [[CDVViewController alloc] init];
        cdvViewController.wwwFolderName = @"www";
        cdvViewController.startPage = fileName;
        
        self.recall = NO;
        self.previousPath = nil;
        isFirstRendering = YES;
        initialQuery = aQuery;
        interfaceOrientationUnspecified = YES;
        interfaceOrientation = UIInterfaceOrientationPortrait;
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receivedOrientationChange)
                                                     name:UIDeviceOrientationDidChangeNotification object:nil];

        // create native component items.
        monacaTabViewControllers = [[NSMutableArray alloc] init];
        [monacaTabViewControllers addObject:cdvViewController];
        tabBarController = [[MonacaTabBarController alloc] init];
        [tabBarController setViewControllers:monacaTabViewControllers];
        
        appNavigationController = [[UINavigationController alloc] initWithRootViewController:tabBarController];
    }
    
    return self;
}

- (void)dealloc {
    appNavigationController = nil;
    tabBarController = nil;
    cdvViewController = nil;
    scrollView_ = nil;
    //    [previousPath_ release]; previousPath_ = nil;
    uiSetting = nil;
    initialQuery = nil;
    
    // TODO:fix leaking on popPage
    // [monacaTabViewControllers release]; monacaTabViewControllers = nil;
}

#pragma mark - UIScrollViewDelegate

- (BOOL)scrollViewShouldScrollToTop:(UIScrollView *)scrollView {
    UIWebView *webView = ((MFDelegate *)[UIApplication sharedApplication].delegate).viewController.cdvViewController.webView;
    NSString *js = [NSString stringWithFormat:@"window.onTapStatusBar && window.onTapStatusBar();"];
    [webView stringByEvaluatingJavaScriptFromString:js];
    return YES;
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    [cdvViewController.webView scrollViewDidEndDecelerating:scrollView];
}

#pragma mark - View lifecycle

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    if ([MFDevice iOSVersionMajor] < 5) {
        [self.tabBarController viewDidAppear:animated];
    }
    [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if ([MFDevice iOSVersionMajor] < 5) {
        [self.tabBarController viewWillAppear:animated];
    }
    if (!uiSetting) [tabBarController applyUserInterface:uiSetting];
    //todo: I want to set this in viewdidload, but iOS4.3 doesn't load viewdidload.
    cdvViewController.webView.delegate = self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [Utility fixedLayout:self interfaceOrientation:self.interfaceOrientation];

    // only first page, set splash screen setting.
    if ([self.navigationController viewControllers].count == 1) {
        id autoHideSplashScreenValue = [self.cdvViewController.settings objectForKey:@"AutoHideSplashScreen"];
        if ([autoHideSplashScreenValue boolValue] == NO) {
            self.cdvViewController.useSplashScreen = YES;
            [self showSplash:YES];
        }
    }
    // whether auto link for datatype
    [self processDataTypes];

    // set componet
    [self.view addSubview:appNavigationController.view];
    [tabBarController applyUserInterface:uiSetting];
    
    [self initPlugins]; // 画面を消す手前でdestroyを実行すること

    // transit
    [MonacaTransitPlugin viewDidLoad:self];
}

- (void)viewDidUnload {
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)aInterfaceOrientation
{
    return [Utility getAllowOrientationFromPlist:aInterfaceOrientation];
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {

    // Adjust height of the navigation bar when the device ratates.
    // FIXME: the bug that colors of buttons is reset when the device rotates (iOS 4).

    UINavigationController *currentController = self.appNavigationController;
    if (UIInterfaceOrientationIsPortrait(toInterfaceOrientation)) {
        float width = [MFDevice widthOfWindow:UIInterfaceOrientationPortrait];
        float height = [MFDevice heightOfNavigationBar:UIInterfaceOrientationPortrait];
        currentController.navigationBar.frame = CGRectMake(currentController.navigationBar.frame.origin.x, currentController.navigationBar.frame.origin.y, width, height);
    } else if (UIInterfaceOrientationIsLandscape(toInterfaceOrientation)) {
        float width = [MFDevice widthOfWindow:UIInterfaceOrientationLandscapeLeft];
        float height = [MFDevice heightOfNavigationBar:UIInterfaceOrientationLandscapeLeft];
        currentController.navigationBar.frame = CGRectMake(currentController.navigationBar.frame.origin.x, currentController.navigationBar.frame.origin.y, width, height);
    }

    if ([[Utility currentTabBarController] hasTitleView]) {
        [[Utility currentTabBarController] changeTitleView];
    }
}

- (void)processDataTypes
{
    // dataDetectorTypes from plist
    id types = [[[Utility getAppDelegate] getApplicationPlist] objectForKey:@"DetectDataTypes"];
    if ([types respondsToSelector:@selector(boolValue)]) {
        BOOL res = [types boolValue];
        cdvViewController.webView.dataDetectorTypes = res ? UIDataDetectorTypeAll : UIDataDetectorTypeNone;
    }
}

- (NSString *)careWWWdir:(NSString *)path {
    return path;
}

- (BOOL)webView:(UIWebView *)webView_ shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    BOOL hasAnchor = [[self class] hasAnchor:[request URL]];
    // ネイティブコンポーネントをMonacaへ持ち込むにあたって、path取得を切り替えたため、standarizedURLを見直しています katsuya
    //NSURL *url = [[self class] standardizedURL:[request URL]];
    NSURL *url = [[request URL] standardizedURL];
    //NSLog(@"[URL] %@, %@", self.cdvViewController.webView, [request URL]);
    
    // avoid to open gap schema and about scheme ---
    if ([url.scheme isEqual:@"gap"] || [url.scheme isEqual:@"http"] || [url.scheme isEqual:@"https"]){
        return [cdvViewController webView:webView_ shouldStartLoadWithRequest:request navigationType:navigationType];
    }
    
    MFDelegate *delegate = (MFDelegate *)[UIApplication sharedApplication].delegate;
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *startPagePath = [[delegate getBaseURL].path stringByAppendingFormat:@"/%@", self.cdvViewController.startPage];
    
    NSString *errorPath = nil;
    if (![fileManager fileExistsAtPath:startPagePath] && !self.recall) {
        // for push
        errorPath = [self careWWWdir:[self.cdvViewController.wwwFolderName stringByAppendingFormat:@"/%@", self.cdvViewController.startPage]];
    }else if (![fileManager fileExistsAtPath:[url path]]){
        // for link
        errorPath = url.path;
    }
    if (errorPath != nil) {
        NSMutableDictionary *info = [NSMutableDictionary dictionary];
        [info setObject:errorPath forKey:@"path"];
        [MonacaEvent dispatchEvent:monacaEvent404Error withInfo:info];
        
        self.recall = YES;
        [Utility show404PageWithWebView:webView_ path:errorPath];
        
        return NO;
    }
    
    // care about scheme after FW checked 404
    if ([url.scheme isEqual:@"about"]){
        return [cdvViewController webView:webView_ shouldStartLoadWithRequest:request navigationType:navigationType];
    }
    // ---

    if (self.recall == NO && [url isFileURL]) {
        NSMutableDictionary *info = [NSMutableDictionary dictionary];
        [info setObject:[url path] forKey:@"path"];
        [MonacaEvent dispatchEvent:monacaEventOpenPage withInfo:info];

        // Treat anchor parameters.
        if (hasAnchor) {
            if (self.previousPath && [[url path] isEqualToString:self.previousPath]) {
                self.recall=YES;
                return YES;
            }
        }
        [MonacaEvent dispatchEvent:monacaEventWillLoadUIFile withInfo:info];
        self.previousPath = [url path];

        BOOL isDir;
        NSFileManager *fileManager = [NSFileManager defaultManager];
        [fileManager fileExistsAtPath:[url path] isDirectory:&isDir];

        NSString *filepath = [url path];
        NSString *uipath;

        if (isDir == YES) {
            uipath = [filepath stringByAppendingPathComponent:@"index.ui"];
            filepath = [filepath stringByAppendingPathComponent:@"index.html"];
        } else {
            uipath = [[filepath stringByDeletingPathExtension] stringByAppendingPathExtension:@"ui"];
        }

        @try {
            if (cdvViewController.webView.tag != kWebViewIgnoreStyle) {
                // Apply user interface definitions.
                NSDictionary *uiDict = [self parseJSONFile:uipath];

                if (![fileManager fileExistsAtPath:uipath]) {
                    uiDict = nil;
                }
                [[Utility currentTabBarController] applyUserInterface:uiDict];
                
                // when use splash screen, dosen't show native component. @see monacaSplashScreen.
                uiSetting = [NSMutableDictionary dictionaryWithDictionary:uiDict];

                // タブバーが存在し、かつ activeIndex が指定されている場合はその html ファイルを読む
                NSMutableDictionary *bottomDict = [uiDict objectForKey:kNCPositionBottom];
                NSString *containerType = [bottomDict objectForKey:kNCTypeContainer];
                if ([containerType isEqualToString:kNCContainerTabbar]) {
                    NSMutableDictionary *style = [bottomDict objectForKey:kNCTypeStyle];
                    NSArray *items = [bottomDict objectForKey:kNCTypeItems];
                    int activeIndex = [[style objectForKey:kNCStyleActiveIndex] intValue];
                    if (activeIndex != 0) {
                        NSString *dirpath = [filepath stringByDeletingLastPathComponent];
                        filepath = [NSString stringWithFormat:@"%@/%@", dirpath, [[items objectAtIndex:activeIndex] objectForKey:kNCTypeLink]];
                        // 初回表示時activeIndexが0以外の場合には、ここで指定してpreviousPathをactiveIndexの示すパスに対応させる。
                        self.previousPath = filepath;
                    }
                }
            }
            cdvViewController.webView.tag = kWebViewNormal;
        }
        @catch (NSException *exception) {
            cdvViewController.webView.tag = kWebViewNormal;
            [[Utility currentTabBarController] applyUserInterface:nil];
        }

        NSString *html = [NSString stringWithContentsOfFile:filepath encoding:NSUTF8StringEncoding error:nil];
#ifndef DISABLE_MONACA_TEMPLATE_ENGINE
        NSURL *url = ((NSURL *)[NSURL fileURLWithPath:filepath]);
        html = [MonacaTemplateEngine compileFromString:html path:url.path];
#else
        if (nil == html) {
            [NSException raise:@"RuntimeException" format:@"File Not Found"];
        }
#endif  // DISABLE_MONACA_TEMPLATE_ENGINE
        // query params---
        NSString *query;
        if (isFirstRendering){
            query = initialQuery;
            isFirstRendering = NO;
        }else {
            query = request.URL.query;
        }
        html = [Utility insertMonacaQueryParams:html query:query];
        //----------
        html = [self hookForLoadedHTML:html request:request];

        // The |loadHTMLString| method calls the |webView:shouldStartLoadWithRequest|
        // method, so infinite loop occurs. We stop it by |recall| flag.
        self.recall = YES;
        NSString *basepath = [[NSURL fileURLWithPath:filepath] description];
        [webView_ loadHTMLString:html baseURL:[NSURL URLWithString:basepath]];

        return NO;
    }
    
    self.recall = NO;
    return [cdvViewController webView:webView_ shouldStartLoadWithRequest:request navigationType:navigationType];
}

/*
 * I want to this at debugger with overriding
 */
- (NSString *)hookForLoadedHTML:(NSString *)html request:(NSURLRequest *)aRequest {
    return html;
}

- (void) webViewDidFinishLoad:(UIWebView*) theWebView 
{
    // Black base color for background matches the native apps
    //theWebView.backgroundColor = [UIColor blackColor];
    
    [MonacaEvent dispatchEvent:monacaEventDidLoadUIFile withInfo:nil];
    [MonacaTransitPlugin webViewDidFinishLoad:theWebView viewController:self];
    
    return [cdvViewController webViewDidFinishLoad:theWebView];
}

- (void)setFixedInterfaceOrientation:(UIInterfaceOrientation)orientation
{
  interfaceOrientation = orientation;
  [self setInterfaceOrientationUnspecified:NO];
}

- (UIInterfaceOrientation)getFixedInterfaceOrientation
{
  return interfaceOrientation;
}

- (void)setInterfaceOrientationUnspecified:(BOOL)flag
{
    interfaceOrientationUnspecified = flag;
}

- (BOOL)isInterfaceOrientationUnspecified
{
    return interfaceOrientationUnspecified;
}

- (void)webViewDidStartLoad:(UIWebView *)_webView {
    [self.cdvViewController webViewDidStartLoad:_webView];
}

- (void)webView:(UIWebView *)_webView didFailLoadWithError:(NSError *)error {
    [self.cdvViewController webView:_webView didFailLoadWithError:error];
}

#pragma mark - splash screen

- (void)showSplash:(BOOL)show
{
    cdvViewController.imageView.hidden = !show;
    if (show) {
        [cdvViewController.activityView startAnimating];
    } else {
        [cdvViewController.activityView stopAnimating];
    }
}

- (void)receivedOrientationChange
{
    // fix cdvcViewController splash screen frame
    // @see showSplashScreen
    UIImageView *imageView = self.cdvViewController.imageView;
    imageView.frame = CGRectMake(0, -20, imageView.frame.size.width, imageView.frame.size.height);
    [imageView removeFromSuperview];
    [self.view addSubview:imageView];

    UIView *activityView = self.cdvViewController.activityView;
    id showSplashScreenSpinnerValue = [self.cdvViewController.settings objectForKey:@"ShowSplashScreenSpinner"];
    if ((showSplashScreenSpinnerValue == nil) || [showSplashScreenSpinnerValue boolValue]) {
        [activityView removeFromSuperview];
        [imageView addSubview:activityView];
    }
}

#pragma mark - Cordova Plugin

- (void)initPlugins {
    for (CDVPlugin *plugin in [self.cdvViewController.pluginObjects allValues]) {
        if ([plugin respondsToSelector:@selector(setViewController:)]) {
            [plugin setViewController:self];
        }
        
        if ([plugin respondsToSelector:@selector(setCommandDelegate:)]) {
            [plugin setCommandDelegate:self.cdvViewController.commandDelegate];
        }
        
        if ([plugin respondsToSelector:@selector(setWebView:)]) {
            [plugin setWebView:self.cdvViewController.webView];
        }
    }
}

- (void)resetPlugins {
    for (CDVPlugin *plugin in [self.cdvViewController.pluginObjects allValues]) {
        if ([plugin respondsToSelector:@selector(setViewController:)]) {
            [plugin setViewController:nil];
        }
        
        if ([plugin respondsToSelector:@selector(setCommandDelegate:)]) {
            [plugin setCommandDelegate:nil];
        }
        
        if ([plugin respondsToSelector:@selector(setWebView:)]) {
            [plugin setWebView:nil];
        }
    }
}

- (void)releaseWebView {
    if (self.cdvViewController && self.cdvViewController.webView) {
        self.cdvViewController.webView.delegate = nil; // 解放しておかないとTransitを繰り返すとアプリが固まる
        self.cdvViewController.webView = nil; // 解放しておかないとWebViewが増え続ける
    }
}

- (void)destroy {
    [self resetPlugins];
    [self releaseWebView];
}

@end
