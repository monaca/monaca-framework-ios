//
//  MFJSInterfaceProtocol.m
//  MonacaFramework
//
//  Created by Katsuya Saitou on 13/01/21.
//  Copyright (c) 2013年 ASIAL CORPORATION. All rights reserved.
//

#import "MFJSInterfaceProtocol.h"

@implementation MFJSInterfaceProtocol

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

@end
