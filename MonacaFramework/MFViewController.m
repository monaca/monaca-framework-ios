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

@interface MFViewController ()

@end

@implementation MFViewController

@synthesize previousPath = _previousPath;
@synthesize ncManager = _ncManager;
@synthesize uiDict = _uiDict;
@synthesize backButton = _backButton;

+ (NSDictionary *)defaultStyles
{
    NSMutableDictionary *defaultStyle = [[NSMutableDictionary alloc] init];
    [defaultStyle setValue:kNCTrue forKey:kNCStyleVisibility];
    [defaultStyle setValue:kNCFalse forKey:kNCStyleDisable];
    [defaultStyle setValue:kNCBlack forKey:kNCStyleBackgroundColor];
    [defaultStyle setValue:kNCUndefined forKey:kNCStyleTitle];
    [defaultStyle setValue:kNCUndefined forKey:kNCStyleSubtitle];
    [defaultStyle setValue:kNCWhite forKey:kNCStyleTitleColor];
    [defaultStyle setValue:kNCWhite forKey:kNCStyleSubtitleColor];
    [defaultStyle setValue:[NSNumber numberWithFloat:1.0]  forKey:kNCStyleTitleFontScale];
    [defaultStyle setValue:[NSNumber numberWithFloat:1.0]  forKey:kNCStyleSubtitleFontScale];
    [defaultStyle setValue:kNCBarStyleDefault forKey:kNCStyleIOSBarStyle];
    [defaultStyle setValue:kNCUndefined forKey:kNCStyleTitleImage];
    [defaultStyle setValue:[NSNumber numberWithFloat:0.3] forKey:kNCStyleShadowOpacity];
    
    return defaultStyle;
}

- (id)initWithFileName:(NSString *)fileName
{
    self = [super init];
    
    if (self) {
        self.startPage = [self removeFragment:fileName];
        self.ncManager = [[NCManager alloc] init];
        _ncStyle = [[self.class defaultStyles] mutableCopy];
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
    [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self applyBarUserInterface];
    self.webView.delegate = self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    [self setBarUserInterface:self.uiDict];

    [self applyUserInterface];
    
    // whether auto link for datatype
    [self processDataTypes];
    
    [self initPlugins]; // 画面を消す手前でdestroyを実行すること
//    self.webView.scrollView.decelerationRate = UIScrollViewDecelerationRateNormal;
}

- (void)releaseWebView {
    if (self && self.webView) {
        [self.webView loadHTMLString:@"" baseURL:nil];
        self.webView.delegate = nil; // 解放しておかないとTransitを繰り返すとアプリが固まる
        self.webView = nil; // 解放しておかないとWebViewが増え続ける
        [self.webView removeFromSuperview];
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
        [self.tabBarController.navigationController setToolbarHidden:YES];
    }
}

- (void)setBarUserInterface:(NSDictionary *)uidict
{
    NSDictionary *top = [uidict objectForKey:kNCPositionTop];
    NSDictionary *bottom = [uidict objectForKey:kNCPositionBottom];
    NSDictionary *style = [uidict objectForKey:kNCTypeStyle];

    if (top != nil) {
        _navigationBar = [[NCNavigationBar alloc] initWithViewController:self];
        [self.ncManager setComponent:_navigationBar forID:[top objectForKey:kNCTypeID]];
        [(NCNavigationBar *)_navigationBar createNavigationBar:top];
    }
    if (bottom != nil) {
        _toolbar =  [[NCToolbar alloc] initWithViewController:self];
        [self.ncManager setComponent:_toolbar forID:[bottom objectForKey:kNCTypeID]];
        [(NCToolbar *)_toolbar createToolbar:bottom];
    }
    
    // setting for page style
    if ([style isKindOfClass:NSDictionary.class]) {
        [self setUserInterface:style];
    }
}

#pragma mark - UIStyleProtocol

- (void)setUserInterface:(NSDictionary *)uidict
{
    for (id key in uidict) {
        if ([_ncStyle objectForKey:key] == nil)
            continue;
        [_ncStyle setValue:[uidict valueForKey:key] forKey:key];
    }
}

- (void)applyUserInterface
{
    for (id key in [_ncStyle copy]) {
        [self updateUIStyle:[_ncStyle objectForKey:key] forKey:key];
    }
}

- (void)updateUIStyle:(id)value forKey:(NSString *)key
{
    if ([_ncStyle objectForKey:key] == nil) {
        // 例外処理
        return;
    }
    if (value == [NSNull null]) {
        value = nil;
    }
    if ([NSStringFromClass([value class]) isEqualToString:@"__NSCFBoolean"]) {
        if (isFalse(value)) {
            value = kNCFalse;
        } else {
            value = kNCTrue;
        }
    }
    
    if ([key isEqualToString:kNCStyleBackgroundColor]) {
        if ([value isKindOfClass:NSString.class]) {
            UIColor *color = hexToUIColor(removeSharpPrefix(value), 1);
            [self setBackgroundColor:color];
        } else {
            [self setBackgroundColor:UIColor.whiteColor];
        }
    }
    
    if (value == [NSNull null]) {
        value = kNCUndefined;
    }
    [_ncStyle setValue:value forKey:key];
}

- (id)retrieveUIStyle:(NSString *)key
{
    if ([_ncStyle objectForKey:key] == nil) {
        // 例外処理
        return nil;
    }
    
    return [_ncStyle objectForKey:key];
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

        [MFUtility show404PageWithWebView:webView path:errorPath];
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



@end
