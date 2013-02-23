//
//  MFUtility.m
//  MonacaFramework
//
//  Created by Yasuhiro Mitsuno on 2013/02/23.
//  Copyright (c) 2013年 ASIAL CORPORATION. All rights reserved.
//

#import "MFUtility.h"
#import "JSONKit.h"
#import "MFEvent.h"

@implementation MFUtility

+ (NSDictionary *)parseJSONFile:(NSString *)path {
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
        [MFEvent dispatchEvent:monacaEventNCParseError withInfo:info];
    } else {
        NSMutableDictionary *info = [NSMutableDictionary dictionary];
        [info setObject:path forKey:@"path"];
        [MFEvent dispatchEvent:monacaEventNCParseSuccess withInfo:info];
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

+ (UIInterfaceOrientation)currentInterfaceOrientation {
    MFDelegate *delegate = [[self class] getAppDelegate];
    return [delegate currentInterfaceOrientation];
}

+ (BOOL)getAllowOrientationFromPlist:(UIInterfaceOrientation)interfaceOrientation
{
    NSDictionary *orientationkv = [NSDictionary dictionaryWithObjectsAndKeys:
                                   [NSNumber numberWithInt:UIInterfaceOrientationPortrait],@"UIInterfaceOrientationPortrait",
                                   [NSNumber numberWithInt:UIInterfaceOrientationPortraitUpsideDown],@"UIInterfaceOrientationPortraitUpsideDown",
                                   [NSNumber numberWithInt:UIInterfaceOrientationLandscapeRight],@"UIInterfaceOrientationLandscapeRight",
                                   [NSNumber numberWithInt:UIInterfaceOrientationLandscapeLeft],@"UIInterfaceOrientationLandscapeLeft",nil];
    NSString *key = @"UISupportedInterfaceOrientations";
    NSArray *values = [[[NSBundle mainBundle] infoDictionary] objectForKey:key];
    for (NSString *value in values){
        NSNumber *num = (NSNumber *)[orientationkv objectForKey:value];
        if(interfaceOrientation == (UIInterfaceOrientation)[num intValue]){
            return YES;
        }
    }
    return NO;
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

+ (NSURL *)getBaseURL
{
    NSString *basePath = [NSString stringWithFormat:@"%@/www", [[NSBundle mainBundle] bundlePath]];
    return [NSURL fileURLWithPath:basePath];
}

+ (NSDictionary *)getApplicationPlist
{
    return [[NSBundle mainBundle] infoDictionary];
}


+ (void) fixedLayout:(MFViewController *)monacaViewController interfaceOrientation:(UIInterfaceOrientation)aInterfaceOrientation{
    if (aInterfaceOrientation == UIInterfaceOrientationPortrait || aInterfaceOrientation == UIInterfaceOrientationPortraitUpsideDown){
        monacaViewController.view.frame = [[UIScreen mainScreen] bounds];
        UIViewController *vc = [monacaViewController.tabBarController.viewControllers objectAtIndex:0];
        [vc setWantsFullScreenLayout:YES];
    }
}

+ (MFDelegate *)getAppDelegate
{
    return ((MFDelegate *)[[UIApplication sharedApplication] delegate]);
}

+ (MFTabBarController *)currentTabBarController
{
    return (MFTabBarController *)[[self class] getAppDelegate].viewController.tabBarController;
}

@end
