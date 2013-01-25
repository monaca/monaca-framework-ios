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

- (void)startLoading
{
    NSMutableDictionary *keyValues = [MFUtility parseQuery:self.request];
    NSString *type = [keyValues objectForKey:@"type"];
    
    // If type is console, simulate console api.
    if ([type isEqualToString:@"console"] == YES) {
        NSString *method = [keyValues objectForKey:@"method"];
        if ([method isEqualToString:@"debug"] == YES ||
            [method isEqualToString:@"info"] == YES ||
            [method isEqualToString:@"log"] == YES ||
            [method isEqualToString:@"debug"] == YES ||
            [method isEqualToString:@"error"] == YES
            ) {
            // No message api does nothing.
            if ([keyValues objectForKey:@"message"] == nil) {
                [self.client URLProtocolDidFinishLoading:self];
                return;
            }
            NSString *log = [[self class] buildLog:keyValues];
            NSLog(@"%@", log);
        }
    }
    // In the future, another types are supported.
    
    [self.client URLProtocolDidFinishLoading:self];
}

- (void)stopLoading
{
	// do any cleanup here
}

#pragma mark - original method

+ (NSString *)buildLog:(NSMutableDictionary *)keyValues
{
    NSString *method = [keyValues objectForKey:@"method"];
    if (method != nil) {
        return [[NSString stringWithFormat:@"[%@] ", method] stringByAppendingString:[keyValues objectForKey:@"message"]];
    }
    return @"";
}

@end
