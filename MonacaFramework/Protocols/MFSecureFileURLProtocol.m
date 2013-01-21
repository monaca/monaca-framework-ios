//
//  MonacaURLProtocol.m
//
//  Created by KUBOTA Mitsunori on 12/06/21.
//  Copyright (c) 2012年 Asial Corporation. All rights reserved.
//

#import "MFSecureFileURLProtocol.h"

@implementation MFSecureFileURLProtocol

+ (void)registerMonacaURLProtocol
{
	static BOOL inited = NO;
    if (!inited) {
        [NSURLProtocol registerClass:[self class]];
        inited = YES;
    }
}

+ (BOOL) requestIsCacheEquivalent: (NSURLRequest*)requestA toRequest: (NSURLRequest*)requestB
{
    return NO;
}

+ (NSURLRequest *)canonicalRequestForRequest:(NSURLRequest *)request
{
    return request;
}


+ (BOOL)canInitWithRequest:(NSURLRequest *)request
{
    NSString *scheme = [[request URL] scheme];
    NSString *path = request.URL.path;
    
    BOOL insecure = NO;
    
    // Restrict local file access except app sandbox files.
    if ([scheme isEqualToString:@"file"] && [path isEqualToString:@"/!gap_exec"] == YES) {
        return NO;
    }
    
    if ([scheme isEqualToString:@"file"] && [path rangeOfString:NSHomeDirectory()].location == NSNotFound){
        NSLog(@"restricted file access: %@", [request URL]);
        insecure = YES;
    }
    
    if ([scheme isEqualToString:@"applewebdata"] || [scheme isEqualToString:@"about"]) {
        insecure = YES;
    }

    return insecure;
}

- (void)startLoading
{
    NSError *error = [[NSError alloc] initWithDomain:@"restricted file access" code:0 userInfo:nil];
    [self.client URLProtocol:self didFailWithError:error];
}

- (void)stopLoading
{
	// do any cleanup here
}

- (void)handleSuccess:(NSURLResponse *)response data:(NSData *)data error:(NSError *)error
{
    [self.client URLProtocol:self didReceiveResponse:response cacheStoragePolicy:NSURLCacheStorageNotAllowed];
    [self.client URLProtocol:self didLoadData:data];
    [self.client URLProtocolDidFinishLoading:self];
}

@end
