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
- (void)processDataTypes;
@end

@implementation MFViewController

@synthesize previousPath = previousPath_;

- (id)init
{
    self = [super init];
    
    if (self) {
        
    }
    return self;
}

#pragma mark - View lifecycle

- (void)viewDidAppear:(BOOL)animated
{
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

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    BOOL hasAnchor = [MFUtility hasAnchor:[request URL]];
    
    NSURL *url = [[request URL] standardizedURL];
    
    if ([url.scheme isEqual:@"gap"] || [url.scheme isEqual:@"http"] || [url.scheme isEqual:@"https"] ||
        [url.scheme isEqual:@"about"]) {
        return [super webView:webView shouldStartLoadWithRequest:request navigationType:navigationType];
    }
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *startPagePath = [[MFUtility getBaseURL].path stringByAppendingFormat:@"/%@", self.startPage];
    NSString *errorPath = nil;
    
    if (![fileManager fileExistsAtPath:startPagePath]) {
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
     
        return NO;
    }
    
    if ([url isFileURL]) {
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
        self.previousPath = [url path];
        
        BOOL isDir;
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
            //TODO
            NSDictionary *uiDict = [MFUtility parseJSONFile:uipath];
            
            if (![fileManager fileExistsAtPath:uipath]) {
                uiDict = nil;
            }
        
        }
        @catch (NSException *exception) {

        }
    }

    return [super webView:webView shouldStartLoadWithRequest:request navigationType:navigationType];
}

@end
