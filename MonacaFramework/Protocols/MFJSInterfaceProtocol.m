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
    if ([type isEqualToString:@"console"]) {
        NSString *log = [[self class] buildLog:keyValues];
        NSLog(@"%@", log);
    }
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
    if ([method isEqual:nil] == NO) {
        return [[NSString stringWithFormat:@"[%@] ", method] stringByAppendingString:[keyValues objectForKey:@"message"]];
    }

    return @"";
}

@end
