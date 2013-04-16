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
    if (self.existTop) {
        [self.navigationController setNavigationBarHidden:NO animated:NO];
    }
    
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [MFUtility setCurrentViewController:self];
    self.navigationItem.titleView = centerView_;
    self.webView.delegate = self;

    [super viewDidAppear:animated];
}

- (void)viewDidLoad
{
    // TODO: 
    [MFUtility setCurrentViewController:self];
    if ([self.navigationController viewControllers].count == 1) {

    }
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
    if (uidict == nil) {
        return;
    }
    NSDictionary *top = [uidict objectForKey:kNCPositionTop];

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
