//
//  Utility.m
//  Template
//
//  Created by Hiroki Nakagawa on 11/06/07.
//  Copyright 2011 ASIAL CORPORATION. All rights reserved.
//

#import "MFUtility.h"

@implementation MFUtility

static NSString *base_url = @"https://api.monaca.mobi";

+ (NSURLResponse *)fetchFrom:(NSString *)url method:(NSString *)method parameter:(NSString *)parameter {
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url]];
    [request setHTTPMethod:method];
    [request setCachePolicy:NSURLRequestReloadIgnoringCacheData];

    NSData *requestBody = [parameter dataUsingEncoding:NSUTF8StringEncoding];
    [request setHTTPBody:requestBody];
    [request setHTTPShouldHandleCookies:YES];
    [request setValue:[[self class] getUserAgent]  forHTTPHeaderField:@"User-Agent"];

    // Fetch from the given URL.
    NSURLResponse *response = nil;
    NSError *error = nil;
    [NSURLConnection sendSynchronousRequest:request
                                         returningResponse:&response error:&error];
    if (error != nil) {
        return nil;
        //        @throw error;
    }

    return response;
}

+ (NSString *)getUserAgent
{
    return [NSString stringWithFormat:@"%@/%@" ,[[NSBundle mainBundle] objectForInfoDictionaryKey: @"CFBundleDisplayName"],
            [[NSBundle mainBundle] objectForInfoDictionaryKey: @"CFBundleVersion"]];
}


+ (NSDictionary *)parseJSON:(NSString *)json {
    return [json cdvjk_objectFromJSONString];
}

+ (NSDictionary *)getAppJSON
{
    NSString *base_path = [[[[MFUtility getAppDelegate] getBaseURL] path] stringByReplacingOccurrencesOfString:@"www" withString:@""];
    NSURL *json_url = [NSURL fileURLWithPath:[NSString stringWithFormat:@"%@app.json", base_path]];
    NSURLRequest *request = [[NSURLRequest alloc] initWithURL:json_url];
    NSURLResponse *response = nil;
    NSError *error = nil;
    NSData *data = [NSURLConnection sendSynchronousRequest:request
                                         returningResponse:&response error:&error];
    NSString *json = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    return [[self class] parseJSON:json];
}

+ (MFTabBarController *)currentTabBarController {
    return (MFTabBarController *)((MFDelegate *)[UIApplication sharedApplication].delegate).viewController.tabBarController;
}

+ (UIInterfaceOrientation)currentInterfaceOrientation {
    MFDelegate *delegate = ((MFDelegate *)[UIApplication sharedApplication].delegate);
    return [delegate currentInterfaceOrientation];
}

+ (BOOL)getAllowOrientationFromPlist:(UIInterfaceOrientation)interfaceOrientation {
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

/*
 * 4.3と5.1の互換性を保ちつつ、MonacaViewControllerをセットアップする
 */
+ (void) setupMonacaViewController:(MFViewController *)monacaViewController{
    if ([MFDevice iOSVersionMajor] < 5) {
    }else{
        BOOL forceStartupRotation = YES;
        UIDeviceOrientation curDevOrientation = [[UIDevice currentDevice] orientation];
        if (UIDeviceOrientationUnknown == curDevOrientation) {
            curDevOrientation = (UIDeviceOrientation)[[UIApplication sharedApplication] statusBarOrientation];
        }
        if (UIDeviceOrientationIsValidInterfaceOrientation(curDevOrientation)) {
            for (NSNumber *orient in monacaViewController.cdvViewController.supportedOrientations) {
                if ([orient intValue] == curDevOrientation) {
                    forceStartupRotation = NO;
                    break;
                }
            }
        }
        if (forceStartupRotation) {
            UIInterfaceOrientation newOrient = [[monacaViewController.cdvViewController.supportedOrientations objectAtIndex:0] intValue];
            [[UIApplication sharedApplication] setStatusBarOrientation:newOrient];
        }
    }
}

/*
 * 表示される時のレイアウトを修正する
 */
+ (void) fixedLayout:(MFViewController *)monacaViewController interfaceOrientation:(UIInterfaceOrientation)aInterfaceOrientation{
    if (aInterfaceOrientation == UIInterfaceOrientationPortrait || aInterfaceOrientation == UIInterfaceOrientationPortraitUpsideDown){
        monacaViewController.view.frame = [[UIScreen mainScreen] bounds];
        UIViewController *vc = [monacaViewController.tabBarController.viewControllers objectAtIndex:0];
        [vc setWantsFullScreenLayout:YES];
    }
}

/*
 * 404 page
 */
+ (void) show404PageWithWebView:(UIWebView *)webView path:(NSString *)aPath {
    NSLog(@"Page not found (as warning):%@", [MFUtility getWWWShortPath:aPath]);
    NSString *pathFor404 = [[NSBundle mainBundle] pathForResource:@"404/index" ofType:@"html"];
    NSString *html = [NSString stringWithContentsOfFile:pathFor404 encoding:NSUTF8StringEncoding error:nil];

    html = [html stringByReplacingOccurrencesOfString:@"%%%urlPlaceHolder%%%" withString:[MFUtility getWWWShortPath:aPath]];
    [webView loadHTMLString:html baseURL:[NSURL fileURLWithPath:pathFor404]];
    [[MFUtility currentTabBarController] applyUserInterface:nil];
}

/*
 *  convert path (ex 1234/xxxx/www/yyy.html -> www/yyy.html)
 */
+ (NSString *)getWWWShortPath:(NSString *)path{
    if (path == nil || [path rangeOfString:@"assets/"].location == NSNotFound) {
        return @"";
    } else {
        return [path substringFromIndex:[path rangeOfString:@"assets/"].location + [@"assets/" length]];
    }
}

/*
 * build url Moaca query params
 */
+ (NSString *)insertMonacaQueryParams:(NSString *)html query:(NSString *)aQuery {
    if (aQuery){
        NSArray *pairs = [aQuery componentsSeparatedByString:@"&"];
        NSMutableArray *keyValues = [NSMutableArray array];

        for (NSString *pair in pairs) {
            NSArray *elements = [pair componentsSeparatedByString:@"="];
            NSString *key = [[elements objectAtIndex:0] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
            key = [key stringByReplacingOccurrencesOfString:@"\\" withString:@"\\\\"];
            key = [key stringByReplacingOccurrencesOfString:@"\"" withString:@"\\\""];
            NSString *value;
            if (elements.count>1){
                value = [[elements objectAtIndex:1] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
                value = [value stringByReplacingOccurrencesOfString:@"\\" withString:@"\\\\"];
                value = [value stringByReplacingOccurrencesOfString:@"\"" withString:@"\\\""];
                [keyValues addObject:[NSString stringWithFormat:@"\"%@\":\"%@\"", key, value]];
            }else {
                [keyValues addObject:[NSString stringWithFormat:@"\"%@\":null", key]];
            }
        }
        NSString *keyValuesString = [keyValues componentsJoinedByString:@","];
        NSString *queryScriptTag = [NSString stringWithFormat:@"<script>window.monaca = window.monaca || {};window.monaca.queryParams = {%@};</script>", keyValuesString];
        NSRange replaceRange = [html rangeOfString:@"<head>"];
        if(replaceRange.location == NSNotFound){
            html = [queryScriptTag stringByAppendingString:html];
        }else {
            html = [html stringByReplacingCharactersInRange:replaceRange withString:[NSString stringWithFormat:@"<head>%@", queryScriptTag]];
        }
    }
    return html;
}

+ (NSString *)urlEncode:(NSString *)text{
    if ([text isKindOfClass:[NSString class]] == NO) {
        NSLog(@"[error] parameter should be string type, but parameter is:%@", text);
        return @"";
    }
    CFStringRef cfString = CFURLCreateStringByAddingPercentEscapes(NULL,
                                                                   (CFStringRef)text,
                                                                   NULL,
                                                                   (CFStringRef)@"!*'();:@&=+$,/?%#[]",
                                                                   kCFStringEncodingUTF8);
    NSString *string = [NSString stringWithString:(__bridge NSString *)cfString];
    CFRelease(cfString);
    return string;
}

+ (NSString *)urlDecode:(NSString *)text{
    CFStringRef cfString = CFURLCreateStringByReplacingPercentEscapesUsingEncoding(NULL,
                                                                                   (CFStringRef)text,
                                                                                   CFSTR(""),
                                                                                   kCFStringEncodingUTF8);
    NSString *string = [NSString stringWithString:(__bridge NSString *)cfString];
    CFRelease(cfString);
    return string;
}

+ (MFDelegate *)getAppDelegate
{
    return ((MFDelegate *)[[UIApplication sharedApplication] delegate]);
}

+ (NSMutableDictionary *)parseQuery:(NSURLRequest *)request
{
    NSString *query = request.URL.query;
    NSArray *pairs = [query componentsSeparatedByString:@"&"];
    NSMutableDictionary *keyValues = [NSMutableDictionary dictionary];

    for (NSString *pair in pairs) {
        NSArray *elements = [pair componentsSeparatedByString:@"="];
        NSString *key = [[elements objectAtIndex:0] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        if ([key isEqualToString:@""] == YES) {
            continue;
        }
        NSString *value;
        if (elements.count>1) {
            value = [[elements objectAtIndex:1] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
            NSDictionary *dictionary = [NSDictionary dictionaryWithObject:value forKey:key];
            [keyValues addEntriesFromDictionary:dictionary];
        }else {
            NSDictionary *dictionary = [NSDictionary dictionaryWithObject:[NSNull null] forKey:key];
            [keyValues addEntriesFromDictionary:dictionary];
        }
    }
    return keyValues;
}

+ (NSURLResponse *)register_push:(NSString *)deviceToken
{
    NSString *push_projectId = [[[[self class] getAppJSON] objectForKey:@"pushNotification"] objectForKey:@"pushProjectId"];

    if ([[NSBundle mainBundle] objectForInfoDictionaryKey:@"MonacaDomain"] != nil) {
        base_url = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"MonacaDomain"];
    }

    NSString *url = [NSString stringWithFormat:@"%@/v1/push/register/%@", base_url, [MFUtility urlEncode:push_projectId]];
    NSString *os = @"ios";
    NSString *deviceId = [[NSUserDefaults standardUserDefaults] objectForKey:@"UUID"];
    NSString *env = @"prod";
    NSString *buildType;

    if ([[NSBundle mainBundle] objectForInfoDictionaryKey:@"MonacaEnv"] != nil) {
        env = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"MonacaEnv"];
    }

#ifdef DEBUG
    buildType = @"debug";
#else
    buildType = @"release";
#endif

    NSString *version = [[[NSBundle mainBundle] infoDictionary] objectForKey:(NSString*)kCFBundleVersionKey];

    NSString *parameter = [NSString stringWithFormat:@"platform=%@&deviceId=%@&env=%@&buildType=%@&version=%@&deviceToken=%@",
                           [MFUtility urlEncode:os],
                           [MFUtility urlEncode:deviceId],
                           [MFUtility urlEncode:env],
                           [MFUtility urlEncode:buildType],
                           [MFUtility urlEncode:version],
                           [MFUtility urlEncode:deviceToken]];

    return [[self class] fetchFrom:url method:@"POST" parameter:parameter];
}

+ (void)setMonacaCloudCookie
{
    NSDictionary *appJSON = [MFUtility getAppJSON];
    NSURL *endPoint = [NSURL URLWithString:[[appJSON objectForKey:@"monacaCloud"] objectForKey:@"endPoint"]];
    NSString *domain = [endPoint host];
    NSString *path = [endPoint path];
    NSString *name = @"MONACA_CLOUD_DEVICE_ID";
    NSString *device_id = [[NSUserDefaults standardUserDefaults] objectForKey:@"UUID"];

    NSDictionary *properties = [[NSMutableDictionary alloc] init];
    [properties setValue:domain forKey:NSHTTPCookieDomain];
    [properties setValue:path forKey:NSHTTPCookiePath];
    [properties setValue:name forKey:NSHTTPCookieName];
    [properties setValue:device_id forKey:NSHTTPCookieValue];
    [properties setValue:@"TURE" forKey:NSHTTPCookieSecure];
    [properties setValue:nil forKey:NSHTTPCookieExpires];
    NSHTTPCookie *cookie = [NSHTTPCookie cookieWithProperties:properties];
    NSHTTPCookieStorage *storage = [NSHTTPCookieStorage sharedHTTPCookieStorage];
    [storage setCookie:cookie];
}

+ (void)clearMonacaCloudCookie
{
    NSHTTPCookieStorage *storage = [NSHTTPCookieStorage sharedHTTPCookieStorage];
    for (NSHTTPCookie *cookie in [storage cookies]) {
        NSDictionary *properties = [cookie properties];
        NSString *name = [properties objectForKey:NSHTTPCookieName];
        if ([name isEqualToString:@"MONACA_CLOUD_DEVICE_ID"]) {
            [properties setValue:[NSDate dateWithTimeIntervalSinceNow:-3600] forKey:NSHTTPCookieExpires];
            NSHTTPCookie *newCookie = [NSHTTPCookie cookieWithProperties:properties];
            [storage deleteCookie:cookie];
            [storage setCookie:newCookie];
        }
    }
}

@end
