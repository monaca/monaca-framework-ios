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

@interface MFViewController ()

@end

@implementation MFViewController

@synthesize previousPath = _previousPath;
@synthesize ncManager = _ncManager;
@synthesize uiDict = _uiDict;
@synthesize backButton = _backButton;
@synthesize transitAnimated = _transitAnimated;
@synthesize screenOrientations = _screenOrientations;

- (id)initWithFileName:(NSString *)fileName
{
    self = [super init];
    
    if (self) {
        self.startPage = [self removeFragment:fileName];
        self.ncManager = [[NCManager alloc] init];
        self.wantsFullScreenLayout = NO;
        self.transitAnimated = YES;
        self.screenOrientations = UIInterfaceOrientationMaskAll;
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
    
    [self applyBarVisibility:_transitAnimated];
    
    [MFViewManager setCurrentViewController:self];
    [MFViewManager setCurrentWWWFolderName:self.wwwFolderName];
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    [self setBarUserInterface:self.uiDict];
    
    // whether auto link for datatype
    [self processDataTypes];
    
    [self initPlugins]; // 画面を消す手前でdestroyを実行すること
    self.webView.delegate = self;
    
    // viewBackground用のキー値監視
    [self addObserver:self forKeyPath:@"view.frame" options:NSKeyValueObservingOptionOld context:NULL];
    
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

- (void)applyBarVisibility:(BOOL)animated
{
    if (_navigationBar) {
        [self.navigationController setNavigationBarHidden:NO animated:animated];
    } else {
        [self.navigationController setNavigationBarHidden:YES animated:animated];
    }
    if (_toolbar) {
        [self.navigationController setToolbarHidden:NO animated:animated];
    } else {
        [self.navigationController setToolbarHidden:YES animated:animated];
    }
}

- (void)applyBarUserInterface
{
    if (_navigationBar) {
        [_navigationBar applyUserInterface];
    }
    if (_toolbar) {
        [_toolbar applyUserInterface];
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
        _bgView = [[MFViewBackground alloc] initWithViewController:self];
        [self.ncManager setComponent:_bgView forID:[uidict objectForKey:kNCTypeID]];
        [(MFViewBackground *)_bgView createBackgroundView:style];
    }
}

- (void)removeUserInterface
{
    [_navigationBar removeUserInterface];
    _navigationBar = nil;
    [_toolbar removeUserInterface];
    _toolbar = nil;
    [_bgView removeUserInterface];
    
    [self.ncManager removeAllComponents];
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
        [MFViewManager setCurrentWWWFolderName:self.wwwFolderName];
        self.previousPath = [url path];

        [MFEvent dispatchEvent:monacaEventOpenPage withInfo:nil];
    }

    return [super webView:webView shouldStartLoadWithRequest:request navigationType:navigationType];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    [super webViewDidFinishLoad:webView];
    NSURL *url = [[webView.request URL] standardizedURL];
    if ([url isFileURL]) {
        self.wwwFolderName = [url.path stringByDeletingLastPathComponent];
        [MFViewManager setCurrentWWWFolderName:self.wwwFolderName];
        self.previousPath = [url path];
    }
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

#pragma mark - key observer

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if([keyPath isEqualToString:@"view.frame"]) {
        [(MFViewBackground *)_bgView updateFrame];
    }
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

@end
