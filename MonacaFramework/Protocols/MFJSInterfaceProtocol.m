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
    NSString *type = self.request.URL.host;
    
    // If type is console, simulate console api.
    if ([type isEqualToString:@"log"] == YES) {
        // No message api does nothing.
        if ([keyValues objectForKey:@"message"] == nil) {
            [self.client URLProtocolDidFinishLoading:self];
            return;
        }
        NSString *log = [keyValues objectForKey:@"message"];
        [self logging:log withType:type];
    }
    // In the future, another types are supported.
    
    [self.client URLProtocol:self didFailWithError:[NSError errorWithDomain:@"dummy" code:0 userInfo:nil]];
}

- (void)stopLoading
{
	// do any cleanup here
}

- (void)logging:(NSString *)log withType:(NSString *)type
{
    NSLog(@"%@", log);
}

@end
