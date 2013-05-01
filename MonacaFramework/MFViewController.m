//
//  MFViewController.m
//  MonacaFramework
//
//  Created by Yasuhiro Mitsuno on 2013/02/23.
//  Copyright (c) 2013年 ASIAL CORPORATION. All rights reserved.
//

#import "MFViewController.h"
#import "MFDevice.h"
#import "MFUtility.h"
#import "MFEvent.h"

@interface MFViewController ()

@end

@implementation MFViewController

@synthesize previousPath = _previousPath;
@synthesize ncManager = _ncManager;
@synthesize uiDict = _uiDict;

- (id)initWithFileName:(NSString *)fileName
{
    self = [super init];
    
    if (self) {
        self.wwwFolderName = @"www";
        self.startPage = fileName;
        self.ncManager = [[NCManager alloc] init];
        _deallocFlag = NO;
        
        self.wantsFullScreenLayout = NO;
    }
    return self;
}

#pragma mark - View lifecycle

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [MFUtility setCurrentViewController:self];

    [super viewDidAppear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
    if (_deallocFlag) {
        [self releaseWebView];
    }
}

- (void)viewDidLoad
{
    [MFUtility setCurrentViewController:self];

    // NavigationBarの背景色などを適応させるため、self.navigationControllerがnilでなくなった後に行う。
    [self applyUserInterface:self.uiDict];

    [self processDataTypes];
    
    [super viewDidLoad];
}

- (void)processDataTypes
{
    id types = [[MFUtility getApplicationPlist] objectForKey:@"DetectDataTypes"];
    if ([types respondsToSelector:@selector(boolValue)]) {
        BOOL res = [types boolValue];
        self.webView.dataDetectorTypes = res ? UIDataDetectorTypeAll :
            UIDataDetectorTypeNone;
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)applyUserInterface:(NSDictionary *)uidict
{
    NSDictionary *top = [uidict objectForKey:kNCPositionTop];
    NSDictionary *bottom = [uidict objectForKey:kNCPositionBottom];
    
    if (top != nil) {
        NCNavigationBar *navigationBar = [[NCNavigationBar alloc] initWithViewController:self];
        [self.ncManager setComponent:navigationBar forID:[top objectForKey:kNCTypeID]];
        [navigationBar createNavigationBar:top];
    } else {
        [self.navigationController setNavigationBarHidden:YES];
    }

    if (bottom != nil) {
        NCToolbar *toolbar =  [[NCToolbar alloc] initWithViewController:self];
        [self.ncManager setComponent:toolbar forID:[bottom objectForKey:kNCTypeID]];
        [toolbar createToolbar:bottom];
    } else {
        [self.navigationController setToolbarHidden:YES];
    }

}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
//    BOOL hasAnchor = [MFUtility hasAnchor:[request URL]];
    
    NSURL *url = [[request URL] standardizedURL];

    if ([url.scheme isEqual:@"gap"] || [url.scheme isEqual:@"http"] || [url.scheme isEqual:@"https"]) {
        return [super webView:webView shouldStartLoadWithRequest:request navigationType:navigationType];
    }
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *startPagePath = [[[NSBundle mainBundle] bundlePath] stringByAppendingFormat:@"/%@/%@", self.wwwFolderName ,self.startPage];
    NSString *errorPath = nil;
    
    if (![fileManager fileExistsAtPath:startPagePath] && !_previousPath) {
        errorPath = [self.wwwFolderName stringByAppendingFormat:@"/%@", self.startPage];
    } else if (![fileManager fileExistsAtPath:[url path]]) {
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
        self.wwwFolderName = [[MFUtility getWWWShortPath:url.path] stringByDeletingLastPathComponent];
        self.previousPath = [url path];

        [MFEvent dispatchEvent:monacaEventOpenPage withInfo:nil];
    }

    return [super webView:webView shouldStartLoadWithRequest:request navigationType:navigationType];
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
    _deallocFlag = YES;
}

@end
