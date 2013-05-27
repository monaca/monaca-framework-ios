//
//  MonacaViewController.m
//  Template
//
//  Created by Hiroki Nakagawa on 11/06/07.
//  Copyright 2011 ASIAL CORPORATION. All rights reserved.
//

#import "MFViewController.h"
#import "MFTabBarController.h"
#import "JSONKit.h"
#import "MFTransitPlugin.h"
#import "MFUtility.h"
#import "MFEvent.h"
#import "MFVIewBackground.h"

@interface MFViewController ()
@property(nonatomic,retain)NSString* query;
- (NSString *)careWWWdir:(NSString *)path;
- (void)processDataTypes;
@end

@implementation MFViewController

@synthesize scrollView = scrollView_;
@synthesize previousPath = previousPath_;
@synthesize recall = recall_;
@synthesize monacaPluginOptions;

@synthesize tabBarController;
@synthesize appNavigationController;
@synthesize cdvViewController;

// Parses *.ui files.

- (NSDictionary *)loadUIFile:(NSString *)path {

    if (![NSFileManager.defaultManager fileExistsAtPath:path]) {
        return nil;
    }
    
    NSError *error = nil;
    NSString *data = [NSString stringWithContentsOfFile:path
                                               encoding:NSUTF8StringEncoding
                                                  error:&error];
    if (data == nil) {
        NSMutableDictionary *info = [NSMutableDictionary dictionary];
        [info setObject:path forKey:@"path"];
        [MFEvent dispatchEvent:monacaEventNoUIFile withInfo:info];
        return nil;
    }
    
    if (YES){
        NSRegularExpression *reg = [[NSRegularExpression alloc] initWithPattern:@"(^[^\"]*?(\"[^\"]*?\"[^\"]*?)*?[^\"\\w]+)\\s*(\\w+)\\s*:"
                                                                        options:0
                                                                          error:nil];
        NSArray *results;
        do {
            results  = [reg matchesInString:data options:0 range:NSMakeRange(0, data.length)];
            for (NSTextCheckingResult *result in results) {
                NSRange range = [result rangeAtIndex:3];
                NSString *str = [data substringWithRange:range];
                data = [data stringByReplacingOccurrencesOfString:[data substringWithRange:range]
                                                       withString:[NSString stringWithFormat:@"\"%@\"", str]
                                                          options:0
                                                            range:range];
            }
        } while ([results count] != 0);
    }

    id jsonString = [data cdvjk_objectFromJSONStringWithParseOptions:CDVJKParseOptionStrict error:&error];
    
    // send log error
    if (error) {
        NSMutableDictionary *info = [NSMutableDictionary dictionary];
        [info setObject:error forKey:@"error"];
        [info setObject:path forKey:@"path"];
        [MFEvent dispatchEvent:monacaEventNCParseError withInfo:info];
    } else {
        NSMutableDictionary *info = [NSMutableDictionary dictionary];
        [info setObject:path forKey:@"path"];
        [MFEvent dispatchEvent:monacaEventNCParseSuccess withInfo:info];
    }

    // return ui dictionary
    if (jsonString == nil) {
        return nil;
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

- (id)init {
    self = [super init];
    if (self){
        uiSetting = nil;
    }
    return self;
}

- (id)initWithFileName:(NSString *)fileName {
    self = [self init];
    if (nil != self) {
        cdvViewController = [[CDVViewController alloc] init];
        cdvViewController.wwwFolderName = @"www";
        cdvViewController.startPage = [self removeFragment:fileName];
        
        self.recall = NO;
        self.previousPath = nil;
        
        isFirstRendering = YES;
        interfaceOrientationUnspecified = YES;
        interfaceOrientation = UIInterfaceOrientationPortrait;
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receivedOrientationChange)
                                                     name:UIDeviceOrientationDidChangeNotification object:nil];

        // create native component items.
        monacaTabViewControllers = [[NSMutableArray alloc] init];
        [monacaTabViewControllers addObject:cdvViewController];
        tabBarController = [[MFTabBarController alloc] init];
        [tabBarController setViewControllers:monacaTabViewControllers];
        
        appNavigationController = [[UINavigationController alloc] initWithRootViewController:tabBarController];
    }
    
    return self;
}

- (NSString *)removeFragment:(NSString*)fileName {
    return [[fileName componentsSeparatedByString:@"#"] objectAtIndex:0];
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
    [MFUtility fixedLayout:self interfaceOrientation:self.interfaceOrientation];

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
}

- (void)viewDidUnload {
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)aInterfaceOrientation
{
    return [MFUtility getAllowOrientationFromPlist:aInterfaceOrientation];
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

    if ([[MFUtility currentTabBarController] hasTitleView]) {
        [[MFUtility currentTabBarController] changeTitleView];
    }
}

- (void)processDataTypes
{
    // dataDetectorTypes from plist
    id types = [MFUtility.getAppDelegate.getApplicationPlist objectForKey:@"DetectDataTypes"];
    
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
    NSURL *url = request.URL.standardizedURL;
    
    //NSString* absoluteUrl = request.URL.absoluteString;
    
    NSString* query = nil;
    query = request.URL.query;
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSMutableDictionary *queryParams = [NSMutableDictionary dictionary];
    if(query){
        [queryParams setObject:query forKey:@"queryParams"];
      // absoluteUrl =  [absoluteUrl stringByReplacingOccurrencesOfString: [@"?" stringByAppendingString: query] withString: @""];
    }
    [userDefaults registerDefaults:queryParams];
    //aタグでの画面遷移時はurlにqueryParamsが含まれる　将来的にpushPageの仕様と合わせる
    //NSURL* url = [[NSURL alloc]initWithString:absoluteUrl];

    // avoid to open gap schema and about scheme ---
    if ([url.scheme isEqual:@"gap"] || [url.scheme isEqual:@"http"] || [url.scheme isEqual:@"https"] || [url.scheme isEqual:@"about"]){
        return [cdvViewController webView:webView_ shouldStartLoadWithRequest:request navigationType:navigationType];
    }
    
    MFDelegate *delegate = (MFDelegate *)UIApplication.sharedApplication.delegate;
    NSFileManager *fileManager = NSFileManager.defaultManager;
    NSString *startPagePath = [delegate.getBaseURL.path stringByAppendingFormat:@"/%@", self.cdvViewController.startPage];
    
    NSString *errorPath = nil;
    if (![fileManager fileExistsAtPath:startPagePath] && !self.recall) {
        // for push
        errorPath = [self careWWWdir:[self.cdvViewController.wwwFolderName stringByAppendingFormat:@"/%@", self.cdvViewController.startPage]];
    }else if (![fileManager fileExistsAtPath:[url path]]){
        // for link
        errorPath = url.path;
    }
    if ([request.URL.scheme isEqualToString:@"file"] && [request.URL.absoluteString hasSuffix:@"/"]) {
        errorPath = request.URL.absoluteString;
    }
    if (errorPath != nil) {
        NSMutableDictionary *info = [NSMutableDictionary dictionary];
        [info setObject:errorPath forKey:@"path"];
        [MFEvent dispatchEvent:monacaEvent404Error withInfo:info];
        
        self.recall = YES;
        [MFUtility show404PageWithWebView:webView_ path:errorPath];
        
        return NO;
    }
    // ---

    if ([url isFileURL]) {
        NSMutableDictionary *info = [NSMutableDictionary dictionary];
        [info setObject:url.path forKey:@"path"];
        [MFEvent dispatchEvent:monacaEventOpenPage withInfo:info];

        // Treat anchor parameters.
        if (hasAnchor) {
            if (self.previousPath && [url.path isEqualToString:self.previousPath]) {
                self.recall = YES;
                return YES;
            }
        }
        [MFEvent dispatchEvent:monacaEventWillLoadUIFile withInfo:info];
        self.previousPath = url.path;

        BOOL isDir;
        NSFileManager *fileManager = [NSFileManager defaultManager];
        [fileManager fileExistsAtPath:url.path isDirectory:&isDir];

        NSString *filepath = url.path;
        NSString *uipath;

        if (isDir == YES) {
            uipath = [filepath stringByAppendingPathComponent:@"index.ui"];
            filepath = [filepath stringByAppendingPathComponent:@"index.html"];
        } else {
            uipath = [filepath.stringByDeletingPathExtension stringByAppendingPathExtension:@"ui"];
        }

        @try {
            if (cdvViewController.webView.tag != kWebViewIgnoreStyle && withinSinglePage == NO) {
                cdvViewController.webView.tag = kWebViewNormal;
                // Apply user interface definitions.
                NSDictionary *uiDict = [self loadUIFile:uipath];

                [MFUtility.currentTabBarController applyUserInterface:uiDict];
                
                // when use splash screen, dosen't show native component. @see monacaSplashScreen.
                uiSetting = [NSMutableDictionary dictionaryWithDictionary:uiDict];
                
                // setting for page style.
                id dict = [uiDict objectForKey:@"style"];
                if ([dict isKindOfClass:NSDictionary.class]) {
                    styleDict_ = [NSMutableDictionary dictionaryWithDictionary:(NSDictionary *)dict];
                } else {
                    styleDict_ = nil;
                }
                [self applyStyleDict:styleDict_];

            } else {
                cdvViewController.webView.tag = kWebViewNormal;
            }
        }
        @catch (NSException *exception) {
            cdvViewController.webView.tag = kWebViewNormal;
            [MFUtility.currentTabBarController applyUserInterface:nil];
        }
    }
    
    return [cdvViewController webView:webView_ shouldStartLoadWithRequest:request navigationType:navigationType];
}

/*
 * I want to this at debugger with overriding
 */
- (NSString *)hookForLoadedHTML:(NSString *)html request:(NSURLRequest *)aRequest {
    return html;
}

- (void)sendPush
{
    NSString *js = [NSString stringWithFormat:@"monaca.cloud.Push.send(%@);", [[NSUserDefaults standardUserDefaults] objectForKey:@"extraJSON"]];
    [self.cdvViewController.webView stringByEvaluatingJavaScriptFromString:js];
    [[NSUserDefaults standardUserDefaults] setObject:nil forKey:@"extraJSON"];
}

- (void)applyStyleDict:(NSMutableDictionary*)pageStyle
{
    // monaca.updateUIStyle対策
    styleDict_ = pageStyle;
    
    self.cdvViewController.webView.backgroundColor = [UIColor clearColor];
    self.cdvViewController.webView.opaque = NO;
    
    UIInterfaceOrientation orientation = [MFUtility currentInterfaceOrientation];
    float navBarHeight = [MFDevice heightOfNavigationBar:orientation];
    if ( self.appNavigationController.navigationBar.hidden == YES) {
        navBarHeight = 0;
    }

    float tabBarHeight = 0;
    
    //tabBarは表示が定義されていない場合も画面外に保持されている
    if ( self.tabBarController.tabBar.frame.origin.y < self.view.frame.size.height) {
        tabBarHeight = [MFDevice heightOfTabBar];
    }
    
    // remove old background
    if( [[self.view viewWithTag:kWebViewBackground] isKindOfClass:UIImageView.class] )
    {
        [[self.view viewWithTag:kWebViewBackground] removeFromSuperview];
    }
    
    MFVIewBackground* backgroundImageView = [[MFVIewBackground alloc] initWithFrame:CGRectMake( self.view.frame.origin.x,
                                                                                               self.view.frame.origin.y + navBarHeight,
                                                                                               self.view.frame.size.width,
                                                                                               self.view.frame.size.height  - navBarHeight - tabBarHeight)];

    backgroundImageView.tag = kWebViewBackground;
    [backgroundImageView setAutoresizingMask:UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth ];
    [backgroundImageView setBackgroundStyle:styleDict_];
    [self.view insertSubview:backgroundImageView atIndex:0];
    [backgroundImageView sendSubviewToBack:self.view];
    [tabBarController.ncManager setComponent:backgroundImageView forID:kNCContainerPage];
    
}

- (void) webViewDidFinishLoad:(UIWebView*) theWebView 
{
    // Black base color for background matches the native apps
    //theWebView.backgroundColor = [UIColor blackColor];
    
    if ([[NSUserDefaults standardUserDefaults] objectForKey:@"extraJSON"] != nil) {
        [self sendPush];
    }

    [MFEvent dispatchEvent:monacaEventDidLoadUIFile withInfo:nil];
    
    withinSinglePage = NO;

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
    withinSinglePage = YES;
}

- (void)webView:(UIWebView *)_webView didFailLoadWithError:(NSError *)error {
    if (error.code == -999) {
        NSLog(@"Failed to load webpage with debug: %@", [error localizedDescription]);
    } else {
        [self.cdvViewController webView:_webView didFailLoadWithError:error];
    }
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

    [self applyStyleDict:styleDict_];
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
    [self.cdvViewController.webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"about:blank"]]];
    [self resetPlugins];
    [self releaseWebView];
}

#pragma mark - Other methods

// Setup page's background color
-(void)setupBackgroundColor:(UIColor *)color
{
    self.cdvViewController.webView.backgroundColor = [UIColor clearColor];
    self.cdvViewController.webView.opaque = NO;
    
    UIScrollView *scrollView = nil;
    if ([[[UIDevice currentDevice] systemVersion] floatValue] < 5.0f) {
        for (UIView *subview in [self.cdvViewController.webView subviews]) {
            if ([[subview.class description] isEqualToString:@"UIScrollView"]) {
                scrollView = (UIScrollView *)subview;
            }
        }
    } else {
        scrollView = (UIScrollView *)[self.cdvViewController.webView scrollView];
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
    
    self.view.opaque = YES;
    self.view.backgroundColor = color;
}

@end
