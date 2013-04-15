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

@synthesize previousPath = previousPath_;
@synthesize existTop = existTop_;

- (id)initWithFileName:(NSString *)fileName
{
    self = [super init];
    
    if (self) {
        self.wwwFolderName = @"www";
        self.startPage = fileName;
        self.existTop = NO;
        
        self.wantsFullScreenLayout = NO;
    }
    return self;
}

#pragma mark - View lifecycle

- (void)viewWillAppear:(BOOL)animated
{
    [MFUtility setCurrentViewController:self];
    if (self.existTop) {
        [self.navigationController setNavigationBarHidden:NO animated:NO];
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    isAppeared_ = YES;
    self.navigationItem.titleView = centerView_;
    [super viewDidAppear:animated];
    if ([MFDevice iOSVersionMajor] < 5) {
        [self.tabBarController viewWillAppear:animated];
    }
    self.webView.delegate = self;
}

- (void)viewDidLoad
{
    // TODO
    [super viewDidLoad];
    [MFUtility fixedLayout:self interfaceOrientation:self.interfaceOrientation];
    [MFUtility setCurrentViewController:self];
    if ([self.navigationController viewControllers].count == 1) {

    }
    
    [self processDataTypes];
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
    if (uidict == nil) {
        return;
    }
    NSDictionary *top = [uidict objectForKey:kNCPositionTop];
    if (top != nil) {
        [self.navigationController setNavigationBarHidden:NO];
    }
    NSDictionary *topStyle = [top objectForKey:kNCTypeStyle];
    NSArray *topRight = [top objectForKey:kNCTypeRight];
    NSArray *topLeft = [top objectForKey:kNCTypeLeft];
    NSArray *topCenter = [top objectForKey:kNCTypeCenter];
    NSDictionary *topCenterStyle = [topCenter objectAtIndex:0];
    
    NSMutableDictionary *style = [NSMutableDictionary dictionary];
    [style addEntriesFromDictionary:[top objectForKey:kNCTypeStyle]];
    [style addEntriesFromDictionary:[top objectForKey:kNCTypeIOSStyle]];
    
    if ([style objectForKey:kNCStyleText] == nil) {
        [style setObject:[topStyle objectForKey:kNCStyleTitle] forKey:kNCStyleText];
    }
    
    self.navigationItem.title = [[top objectForKey:kNCTypeStyle] objectForKey:kNCStyleTitle];

    
    NSMutableArray *containers = [NSMutableArray array];
    for (id component in topRight) {
        NCContainer *container = [NCContainer container:component position:kNCPositionTop];
        [containers addObject:container.component];
    }
    
    self.navigationItem.rightBarButtonItems = containers;
    containers = [NSMutableArray array];
    for (id component in topLeft) {
        NCContainer *container = [NCContainer container:component position:kNCPositionTop];
        [containers addObject:container.component];
    }
    self.navigationItem.leftBarButtonItems = containers;
    
    NSArray *centerContainers = [NSArray arrayWithObject:[NCContainer container:topCenterStyle position:@"top"]];
    centerView_ = [(NCContainer *)[centerContainers objectAtIndex:0] view];
    if (isAppeared_) {
        self.navigationItem.titleView = centerView_;
    }
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    BOOL hasAnchor = [MFUtility hasAnchor:[request URL]];
    
    NSURL *url = [[request URL] standardizedURL];

    if ([url.scheme isEqual:@"gap"] || [url.scheme isEqual:@"http"] || [url.scheme isEqual:@"https"]) {
        return [super webView:webView shouldStartLoadWithRequest:request navigationType:navigationType];
    }
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *startPagePath = [[[NSBundle mainBundle] bundlePath] stringByAppendingFormat:@"/%@/%@", self.wwwFolderName ,self.startPage];
    NSString *errorPath = nil;
    
    if (![fileManager fileExistsAtPath:startPagePath] && !previousPath_) {
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
        previousPath_ = errorPath;
        return NO;
    }
    
    if ([url.scheme isEqual:@"about"]) {
        return [super webView:webView shouldStartLoadWithRequest:request navigationType:navigationType];
    }
   
    if ([url isFileURL]) {
        self.wwwFolderName = [[MFUtility getWWWShortPath:url.path] stringByDeletingLastPathComponent];
        NSMutableDictionary *info = [NSMutableDictionary dictionary];
        [info setObject:[url path] forKey:@"path"];
        [MFEvent dispatchEvent:monacaEventOpenPage withInfo:info];
        
        // Treat anchor parameters.
        if (hasAnchor) {
            if (self.previousPath && [[url path] isEqualToString:self.previousPath]) {
                return YES;
            }
        }
        
        [MFEvent dispatchEvent:monacaEventWillLoadUIFile withInfo:info];
        
        BOOL isDir;
        [fileManager fileExistsAtPath:[url path] isDirectory:&isDir];
        
        NSString *filepath = [url path];
        NSString *uipath;
        
        if (isDir == YES) {
            uipath = [filepath stringByAppendingPathComponent:@"index.ui"];
            filepath = [filepath stringByAppendingPathComponent:@"index.html"];
        } else {
            uipath = [MFUtility getUIFileName:filepath];
        }
        
        @try {
            NSDictionary *uiDict = [MFUtility parseJSONFile:uipath];

            if (![fileManager fileExistsAtPath:uipath]) {
                uiDict = nil;
            }
            if (!previousPath_) {
                [self applyUserInterface:uiDict];
            }

        }
        @catch (NSException *exception) {

        }
        self.previousPath = [url path];
    }

    return [super webView:webView shouldStartLoadWithRequest:request navigationType:navigationType];
}

- (void)destroy {
    [self.webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"about:blank"]]];
}

@end
