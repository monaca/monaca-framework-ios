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

static MFViewController *currentViewController;
static MFTabBarController *currentTabBarController;

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
        data = [[self class] correctJSON:data];
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
//        [MFEvent dispatchEvent:monacaEventNCParseSuccess withInfo:info];
        NSLog(@"%@",[NSLocalizedString(@"Load UI File", nil) stringByAppendingString:[MFUtility getWWWShortPath:path]]);
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

+ (NSString *)correctJSON:(NSString *)data
{
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
    return data;
}
+ (NSDictionary *)parseJSON:(NSString *)json {
    return [json cdvjk_objectFromJSONString];
}

+ (NSDictionary *)getAppJSON
{
    NSString *base_path = [[[self class] currentViewController].wwwFolderName stringByReplacingOccurrencesOfString:@"www" withString:@""];
    NSURL *json_url = [NSURL fileURLWithPath:[base_path stringByAppendingPathComponent:@"app.json"]];
    NSURLRequest *request = [[NSURLRequest alloc] initWithURL:json_url];
    NSURLResponse *response = nil;
    NSError *error = nil;
    NSData *data = [NSURLConnection sendSynchronousRequest:request
                                         returningResponse:&response error:&error];
    NSString *json = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    return [[self class] parseJSON:json];
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

+ (NSString *)urlEncode:(NSString *)text
{
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
    NSString *basePath = [[[NSBundle mainBundle] bundlePath] stringByAppendingPathComponent:@"www"];
    return [NSURL fileURLWithPath:basePath];
}

+ (NSDictionary *)getApplicationPlist
{
    return [[NSBundle mainBundle] infoDictionary];
}

/*
 *  convert path (ex 1234/xxxx/www/yyy.html -> www/yyy.html)
 */
+ (NSString *)getWWWShortPath:(NSString *)path
{
    if ([path rangeOfString:@"www"].location != NSNotFound) {
        return [path substringFromIndex:[path rangeOfString:@"www"].location];
    }
    if ([path rangeOfString:@"assets"].location != NSNotFound) {
        return [path substringFromIndex:[path rangeOfString:@"assets/"].location + [@"assets/" length]];
    }
    return path;
}


+ (NSString *)getUIFileName:(NSString *)filename
{
    return [[filename stringByDeletingPathExtension] stringByAppendingFormat:@".ui"];
}

/*
 * build url Moaca query params
 */
+ (NSString *)insertMonacaQueryParams:(NSString *)html query:(NSString *)aQuery
{
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


+ (void) fixedLayout:(MFViewController *)monacaViewController interfaceOrientation:(UIInterfaceOrientation)aInterfaceOrientation{
    if (aInterfaceOrientation == UIInterfaceOrientationPortrait || aInterfaceOrientation == UIInterfaceOrientationPortraitUpsideDown){
        monacaViewController.view.frame = [[UIScreen mainScreen] bounds];
        UIViewController *vc = [monacaViewController.tabBarController.viewControllers objectAtIndex:0];
        [vc setWantsFullScreenLayout:YES];
    }
}

+ (void) show404PageWithWebView:(UIWebView *)webView path:(NSString *)aPath {
    NSLog(@"Page not found (as warning):%@", [MFUtility getWWWShortPath:aPath]);
    NSString *pathFor404 = [[NSBundle mainBundle] pathForResource:@"404/index" ofType:@"html"];
    NSString *html = [NSString stringWithContentsOfFile:pathFor404 encoding:NSUTF8StringEncoding error:nil];
    
    html = [html stringByReplacingOccurrencesOfString:@"%%%urlPlaceHolder%%%" withString:[MFUtility getWWWShortPath:aPath]];
    [webView loadHTMLString:html baseURL:[NSURL fileURLWithPath:pathFor404]];
}

+ (MFDelegate *)getAppDelegate
{
    return ((MFDelegate *)[[UIApplication sharedApplication] delegate]);
}

+ (void)setCurrentTabBarController:(MFTabBarController *)tabBarController
{
    currentTabBarController = tabBarController;
}

+ (MFTabBarController *)currentTabBarController
{
    return currentTabBarController;
}

+ (void)setCurrentViewController:(MFViewController *)viewController
{
    currentViewController = viewController;
}

+ (MFViewController *)currentViewController
{
    return currentViewController;
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
    [properties setValue:@"TRUE" forKey:NSHTTPCookieSecure];
    [properties setValue:nil forKey:NSHTTPCookieExpires];
    NSHTTPCookie *cookie = [NSHTTPCookie cookieWithProperties:properties];
    NSHTTPCookieStorage *storage = [NSHTTPCookieStorage sharedHTTPCookieStorage];
    storage.cookieAcceptPolicy = NSHTTPCookieAcceptPolicyAlways;
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

+ (void)checkWithInfo:(NSDictionary *)info
{
    NSString *component = [info objectForKey:@"component"];
    NSMutableDictionary *uidict = [info objectForKey:@"uidict"];
    NSDictionary *validDict = [info objectForKey:@"validDict"];
    NSArray *requiredKeys = [info objectForKey:@"requiredKeys"];
    NSEnumerator* enumerator = [[uidict copy] keyEnumerator];
    id key;

    while (key = [enumerator nextObject]) {
        if ([validDict objectForKey:key] == nil) {
            NSEnumerator* enumerator = [validDict keyEnumerator];
            NSString *ss = @"[";
            id string = [enumerator nextObject];
            while (string) {
                ss = [ss stringByAppendingString:[NSString stringWithFormat:@"\"%@\"", string]];
                string = [enumerator nextObject];
                if (string)
                    ss = [ss stringByAppendingString:@", "];
            }
            ss = [ss stringByAppendingString:@"]"];
            NSLog(@"Error: %@ key \"%@\" is not one of %@", component, key, ss);
            continue;
        }
        if (![[uidict objectForKey:key] isKindOfClass:[validDict valueForKey:key]]) {
            NSLog(@"Error: %@ \"%@\" value must be of type %@. You specified \"%@\"", component ,
                  key,[[validDict objectForKey:key] class], [uidict valueForKey:key]);
            [uidict removeObjectForKey:key];
            continue;
        }
    }
    for (id key in requiredKeys) {
        if ([uidict objectForKey:key] == nil) {
            NSLog(@"Error: missing required key \"%@\" in %@", key ,component);
        }
    }
}

@end
