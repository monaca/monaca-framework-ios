//
//  MFJSInterfaceProtocol.m
//  MonacaFramework
//
//  Created by Katsuya Saitou on 13/01/21.
//  Copyright (c) 2013年 ASIAL CORPORATION. All rights reserved.
//

#import "MFJSInterfaceProtocol.h"

@implementation MFJSInterfaceProtocol

# pragma mark - protocol life cycle

+ (BOOL)canInitWithRequest:(NSURLRequest *)request
{
    if ([request.URL.scheme isEqualToString:@"monaca"]) {
        return YES;
    }
    return NO;
}

+ (BOOL)requestIsCacheEquivalent: (NSURLRequest*)requestA toRequest: (NSURLRequest*)requestB
{
    return NO;
}

+ (NSURLRequest *)canonicalRequestForRequest:(NSURLRequest *)request
{
    return request;
}

#pragma mark - original method

+ (NSString *)buildLog:(NSURLRequest *)request
{
    // parse query
    NSString *query = request.URL.query;
    NSArray *pairs = [query componentsSeparatedByString:@"&"];
    NSMutableDictionary *keyValues = [NSMutableDictionary dictionary];
    
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
            NSDictionary *dictionary = [NSDictionary dictionaryWithObject:value forKey:key];
            [keyValues addEntriesFromDictionary:dictionary];
        }else {
            NSDictionary *dictionary = [NSDictionary dictionaryWithObject:nil forKey:key];
            [keyValues addEntriesFromDictionary:dictionary];
        }
    }
    
    NSString *type = [keyValues objectForKey:@"type"];
    if ([type isEqualToString:@"console.log"]) {
        return [@"[log] " stringByAppendingString:[keyValues objectForKey:@"message"]];
    }
    
    return @"";
}

@end
