//
//  MFJSInterfaceProtocolTest.m
//  MonacaFramework
//
//  Created by Katsuya Saitou on 13/01/21.
//  Copyright (c) 2013年 ASIAL CORPORATION. All rights reserved.
//

#import "MFJSInterfaceProtocolTest.h"

@implementation MFJSInterfaceProtocolTest

- (void)testCanInitWithRequest
{
    ^(){
        NSString *path = [NSString stringWithFormat:@"monaca://action?type=%@&message=%@",
                                                    [MFUtility urlEncode:@"console.log"],
                                                    [MFUtility urlEncode:@"I'm log"]];
        NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:path]];
        GHAssertTrue([MFJSInterfaceProtocol canInitWithRequest:request], @"Pass only monca scheme");
    }();
    ^(){
        NSString *path = @"http://monaca.mobi";
        NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:path]];
        GHAssertFalse([MFJSInterfaceProtocol canInitWithRequest:request], @"Doesn't pass http scheme");
    }();
}

- (void)testRequestIsCacheEquivalent
{
    ^(){
        NSURLRequest *aRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:@"http://monaca.mobi"]];
        GHAssertFalse([MFJSInterfaceProtocol requestIsCacheEquivalent:aRequest toRequest:aRequest], @"return value is NO");
    }();
    ^(){
        NSURLRequest *aRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:@"http://monaca.mobi"]];
        NSURLRequest *bRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:@"http://google.com"]];
        GHAssertFalse([MFJSInterfaceProtocol requestIsCacheEquivalent:aRequest toRequest:bRequest], @"return value is NO");
    }();
}

- (void)testCanonicalRequestForRequest
{
    ^(){
        NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:@"http://monaca.mobi"]];
        GHAssertEqualObjects(request, [MFJSInterfaceProtocol canonicalRequestForRequest:request], @"should be return same request.");
    }();
    ^(){
        NSURLRequest *aRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:@"http://monaca.mobi"]];
        NSURLRequest *bRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:@"http://google.com"]];
        GHAssertNotEqualObjects(aRequest, [MFJSInterfaceProtocol canonicalRequestForRequest:bRequest], @"should be return same request.");
    }();
}

# pragma mark - original methods

- (void)testBuildLog
{
    ^(){
        NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:@"monaca://action"]];
        GHAssertEqualStrings([MFJSInterfaceProtocol buildLog:request], @"", @"No query, no log");
    }();
    ^(){
        NSString *path = [NSString stringWithFormat:@"monaca://action?type=%@&message=%@",
                          [MFUtility urlEncode:@"console.log"],
                          [MFUtility urlEncode:@"I'm log"]];
        NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:path]];
        GHAssertEqualStrings([MFJSInterfaceProtocol buildLog:request], @"[log] I'm log", @"monaca.console.log");
    }();
}
@end
