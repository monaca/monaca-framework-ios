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

+ (NSURL *)getBaseURL
{
    NSString *basePath = [NSString stringWithFormat:@"%@/www", [[NSBundle mainBundle] bundlePath]];
    return [NSURL fileURLWithPath:basePath];
}

+ (NSDictionary *)getApplicationPlist
{
    return [[NSBundle mainBundle] infoDictionary];
}

@end
