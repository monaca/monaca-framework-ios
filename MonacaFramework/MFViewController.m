//
//  MonacaViewController.m
//  Template
//
//  Created by Hiroki Nakagawa on 11/06/07.
//  Copyright 2011 ASIAL CORPORATION. All rights reserved.
//

#import "MFViewController.h"
#import "MFDevice.h"
#import "MFUtility.h"
#import "MFEvent.h"
#import "CDVPlugin.h"
#import "MFTransitPlugin.h"
#import "MFViewBackground.h"
#import "MFViewManager.h"

#define kWebViewBackground  @"bg"

@interface MFViewController ()

@end

@implementation MFViewController

@synthesize previousPath = _previousPath;
@synthesize ncManager = _ncManager;
@synthesize uiDict = _uiDict;
@synthesize backButton = _backButton;

- (id)initWithFileName:(NSString *)fileName
{
    self = [super init];
    
    if (self) {
        self.startPage = [self removeFragment:fileName];
        self.ncManager = [[NCManager alloc] init];
        _ncStyle = [[NCStyle alloc] initWithComponent:kNCContainerPage];
        self.wantsFullScreenLayout = NO;
    }
    return self;
}

- (NSString *)removeFragment:(NSString*)fileName {
    return [[fileName componentsSeparatedByString:@"#"] objectAtIndex:0];
}

#pragma mark - View lifecycle

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [self applyBarUserInterface];
    [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [MFViewManager setCurrentWWWFolderName:self.wwwFolderName];
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    [MFViewManager setCurrentWWWFolderName:self.wwwFolderName];
    [self setBarUserInterface:self.uiDict];

    [self applyUserInterface];
    
    // whether auto link for datatype
    [self processDataTypes];
    
    [self initPlugins]; // 画面を消す手前でdestroyを実行すること
    self.webView.delegate = self;
//    self.webView.scrollView.decelerationRate = UIScrollViewDecelerationRateNormal;
}

- (void)releaseWebView {
    if (self && self.webView) {
        [self.webView loadHTMLString:@"" baseURL:nil];
        self.webView.delegate = nil; // 解放しておかないとTransitを繰り返すとアプリが固まる
        self.webView = nil; // 解放しておかないとWebViewが増え続ける
        [self.webView removeFromSuperview];
        [self resetPlugins];
    }
}

- (void)destroy {
    [NSTimer scheduledTimerWithTimeInterval:0.5f target:self selector:@selector(releaseWebView) userInfo:nil repeats:NO];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)processDataTypes
{
    // dataDetectorTypes from plist
    id types = [MFUtility.getApplicationPlist objectForKey:@"DetectDataTypes"];
    
    if ([types respondsToSelector:@selector(boolValue)]) {
        BOOL res = [types boolValue];
        self.webView.dataDetectorTypes = res ? UIDataDetectorTypeAll : UIDataDetectorTypeNone;
    }
}

- (void)applyBarUserInterface
{
    if (_navigationBar) {
        [_navigationBar applyUserInterface];
    } else {
        [self.navigationController setNavigationBarHidden:YES];
    }
    
    if (_toolbar) {
        [_toolbar applyUserInterface];
    } else {
        [self.navigationController setToolbarHidden:YES];
    }
}

- (void)setBarUserInterface:(NSDictionary *)uidict
{
    NSDictionary *top = [uidict objectForKey:kNCPositionTop];
    NSDictionary *bottom = [uidict objectForKey:kNCPositionBottom];
    NSMutableDictionary *style = [NSMutableDictionary dictionary];
    [style addEntriesFromDictionary:[uidict objectForKey:kNCTypeStyle]];
    [style addEntriesFromDictionary:[uidict objectForKey:kNCTypeIOSStyle]];

    if ([[top objectForKey:kNCTypeContainer] isEqualToString:kNCContainerToolbar]) {
        _navigationBar = [[NCNavigationBar alloc] initWithViewController:self];
        [self.ncManager setComponent:_navigationBar forID:[top objectForKey:kNCTypeID]];
        [(NCNavigationBar *)_navigationBar createNavigationBar:top];
    }
    if ([[bottom objectForKey:kNCTypeContainer] isEqualToString:kNCContainerToolbar]) {
        _toolbar =  [[NCToolbar alloc] initWithViewController:self];
        [self.ncManager setComponent:_toolbar forID:[bottom objectForKey:kNCTypeID]];
        [(NCToolbar *)_toolbar createToolbar:bottom];
    }
    
    // setting for page style
    if ([style isKindOfClass:NSDictionary.class]) {
        [self setUserInterface:style];
    }
}

- (void)removeUserInterface
{
    [_ncStyle resetStyles];
    [_navigationBar removeUserInterface];
    _navigationBar = nil;
    [_toolbar removeUserInterface];
    _toolbar = nil;
    
    [self.ncManager removeAllComponents];
}

#pragma mark - UIStyleProtocol

- (void)setUserInterface:(NSDictionary *)uidict
{
    [_ncStyle setStyles:uidict];
}

- (void)applyUserInterface
{
    for (id key in [_ncStyle styles]) {
        [self updateUIStyle:[[_ncStyle styles] objectForKey:key] forKey:key];
    }
}

- (void)updateUIStyle:(id)value forKey:(NSString *)key
{
    if (![_ncStyle checkStyle:value forKey:key]) {
        return;
    }
    
    if ([key isEqualToString:kNCStyleBackgroundColor]) {
        if ([value isKindOfClass:NSString.class]) {
            UIColor *color = hexToUIColor(removeSharpPrefix(value), 1);
            [self setBackgroundColor:color];
        } else {
            [self setBackgroundColor:UIColor.whiteColor];
        }
    }
    
    [_ncStyle updateStyle:value forKey:key];
}

- (id)retrieveUIStyle:(NSString *)key
{
    return [_ncStyle retrieveStyle:key];
}

#pragma mark - webview delegate

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
//    BOOL hasAnchor = [MFUtility hasAnchor:[request URL]];
    
    NSURL *url = [[request URL] standardizedURL];

    if ([url.scheme isEqual:@"gap"] || [url.scheme isEqual:@"http"] || [url.scheme isEqual:@"https"]) {
        return [super webView:webView shouldStartLoadWithRequest:request navigationType:navigationType];
    }
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *startPagePath = [self.wwwFolderName stringByAppendingPathComponent:self.startPage];
    NSString *errorPath = nil;
    
    if (![fileManager fileExistsAtPath:startPagePath] && !_previousPath) {
        // for push
        errorPath = [self.wwwFolderName stringByAppendingFormat:@"/%@", self.startPage];
    } else if (![fileManager fileExistsAtPath:[url path]]) {
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

        [MFViewManager show404PageWithWebView:webView path:errorPath];
        _previousPath = errorPath;
        return NO;
    }
    
    if ([url.scheme isEqual:@"about"]) {
        return [super webView:webView shouldStartLoadWithRequest:request navigationType:navigationType];
    }
   
    if ([url isFileURL]) {
        self.wwwFolderName = [url.path stringByDeletingLastPathComponent];
        self.previousPath = [url path];

        [MFEvent dispatchEvent:monacaEventOpenPage withInfo:nil];
    }

    return [super webView:webView shouldStartLoadWithRequest:request navigationType:navigationType];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    [super webViewDidFinishLoad:webView];
    [webView stringByEvaluatingJavaScriptFromString:@"document.documentElement.style.webkitTouchCallout = 'none';"];
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    //avoid "Failed to load webpage with error"
    if([error code] != NSURLErrorCancelled){
        [super webView:webView didFailLoadWithError:error];
    }
}

- (void)sendPush
{
    NSString *js = [NSString stringWithFormat:@"monaca.cloud.Push.send(%@);", [[NSUserDefaults standardUserDefaults] objectForKey:@"extraJSON"]];
    [self.webView stringByEvaluatingJavaScriptFromString:js];
    [[NSUserDefaults standardUserDefaults] setObject:nil forKey:@"extraJSON"];
}

#pragma mark - splash screen

- (void)showSplash:(BOOL)show
{
    self.imageView.hidden = !show;
    if (show) {
        [self.activityView startAnimating];
    } else {
        [self.activityView stopAnimating];
    }
}

- (void)receivedOrientationChange
{
    // fix cdvcViewController splash screen frame
    // @see showSplashScreen
    UIImageView *imageView = self.imageView;
    imageView.frame = CGRectMake(0, -20, imageView.frame.size.width, imageView.frame.size.height);
    [imageView removeFromSuperview];
    [self.view addSubview:imageView];
    
    UIView *activityView = self.activityView;
    id showSplashScreenSpinnerValue = [self.settings objectForKey:@"ShowSplashScreenSpinner"];
    if ((showSplashScreenSpinnerValue == nil) || [showSplashScreenSpinnerValue boolValue]) {
        [activityView removeFromSuperview];
        [imageView addSubview:activityView];
    }
}

#pragma mark - Cordova Plugin

- (void)initPlugins {
    for (CDVPlugin *plugin in [self.pluginObjects allValues]) {
        if ([plugin respondsToSelector:@selector(setViewController:)]) {
            [plugin setViewController:self];
        }
        
        if ([plugin respondsToSelector:@selector(setCommandDelegate:)]) {
            [plugin setCommandDelegate:self.commandDelegate];
        }
        
        if ([plugin respondsToSelector:@selector(setWebView:)]) {
            [plugin setWebView:self.webView];
        }
    }
}

- (void)resetPlugins {
    for (CDVPlugin *plugin in [self.pluginObjects allValues]) {
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

#pragma mark - Other methods

- (void)setBackgroundColor:(UIColor *)color
{
    self.webView.backgroundColor = [UIColor clearColor];
    self.webView.opaque = NO;
    
    UIScrollView *scrollView = (UIScrollView *)[self.webView scrollView];
    
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


- (void)applyStyleDict:(NSMutableDictionary*)pageStyle
{
    self.webView.backgroundColor = [UIColor clearColor];
    self.webView.opaque = NO;
    
    UIInterfaceOrientation orientation = [MFUtility currentInterfaceOrientation];
    float navBarHeight = [MFDevice heightOfNavigationBar:orientation];
    if ( self.navigationController.navigationBar.hidden == YES) {
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
    
    MFViewBackground* backgroundImageView = [[MFViewBackground alloc] initWithFrame:CGRectMake( self.view.frame.origin.x,
                                                                                               self.view.frame.origin.y,
                                                                                               self.view.frame.size.width,
                                                                                               self.view.frame.size.height)];
    
    backgroundImageView.tag = kWebViewBackground;
    [backgroundImageView setAutoresizingMask:UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth ];
    [backgroundImageView setBackgroundStyle:pageStyle];
    [self.view insertSubview:backgroundImageView atIndex:0];
    [backgroundImageView sendSubviewToBack:self.view];
    [self.ncManager setComponent:backgroundImageView forID:kNCContainerPage];
    
}

@end
