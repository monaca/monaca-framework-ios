//
//  MFJSInterfaceProtocolTest.m
//  MonacaFramework
//
//  Created by Katsuya Saitou on 13/01/21.
//  Copyright (c) 2013年 ASIAL CORPORATION. All rights reserved.
//

#import "MFJSInterfaceProtocolTest.h"
#import "MFSecureFileURLProtocol.h"

@implementation MFJSInterfaceProtocolTest

- (void)setUp
{
    [NSURLProtocol registerClass:[MFJSInterfaceProtocol class]];
}

- (void)tearDown
{
    latestLog = nil;
    [NSURLProtocol unregisterClass:[MFJSInterfaceProtocol class]];
}

- (void)testCanInitWithRequest
{
    ^(){
        NSString *path = [NSString stringWithFormat:@"monaca://action?type=%@&method=%@&message=%@",
                                                    [MFUtility urlEncode:@"console"],
                                                    [MFUtility urlEncode:@"log"],
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

- (void)testStartLoading
{
    ^(){
        latestLog = nil;
        NSString *path = [NSString stringWithFormat:@"monaca://action?type=%@",
                          [MFUtility urlEncode:@"console"]];
        NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:path]];
        [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
        GHAssertEqualStrings(nil, latestLog, @"only 'type' query");
    }();
    ^(){
        latestLog = nil;
        NSString *path = [NSString stringWithFormat:@"monaca://action?type=%@&method=%@",
                          [MFUtility urlEncode:@"console"],
                          [MFUtility urlEncode:@"log"]];
        NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:path]];
        [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
        GHAssertEqualStrings(nil, latestLog, @"No message");
    }();
    ^(){
        latestLog = nil;
        NSString *path = [NSString stringWithFormat:@"monaca://action?type=%@&method=%@&message=",
                          [MFUtility urlEncode:@"console"],
                          [MFUtility urlEncode:@"log"]];
        NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:path]];
        [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
        GHAssertEqualStrings(latestLog, @"[log] ", @"Blank message");
    }();
    ^(){
        latestLog = nil;
        NSString *path = [NSString stringWithFormat:@"monaca://action?type=%@&method=%@&message=",
                          [MFUtility urlEncode:@"console"],
                          [MFUtility urlEncode:@"foo"]];
        NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:path]];
        [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
        GHAssertEqualStrings(latestLog, nil, @"No support method");
    }();
    ^(){
        latestLog = nil;
        NSString *path = [NSString stringWithFormat:@"monaca://action?type=%@&method=%@&message=%@",
                          [MFUtility urlEncode:@"console"],
                          [MFUtility urlEncode:@"debug"],
                          [MFUtility urlEncode:@"I'm debug"]];
        NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:path]];
        [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
        GHAssertEqualStrings(@"[debug] I'm debug", latestLog, @"check console debug");
    }();
    ^(){
        latestLog = nil;
        NSString *path = [NSString stringWithFormat:@"monaca://action?type=%@&method=%@&message=%@",
                          [MFUtility urlEncode:@"console"],
                          [MFUtility urlEncode:@"info"],
                          [MFUtility urlEncode:@"I'm info"]];
        NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:path]];
        [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
        GHAssertEqualStrings(@"[info] I'm info", latestLog, @"check console info");
    }();
    ^(){
        latestLog = nil;
        NSString *path = [NSString stringWithFormat:@"monaca://action?type=%@&method=%@&message=%@",
                          [MFUtility urlEncode:@"console"],
                          [MFUtility urlEncode:@"log"],
                          [MFUtility urlEncode:@"I'm log"]];
        NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:path]];
        [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
        GHAssertEqualStrings(@"[log] I'm log", latestLog, @"check console log");
    }();
    ^(){
        latestLog = nil;
        NSString *path = [NSString stringWithFormat:@"monaca://action?type=%@&method=%@&message=%@",
                          [MFUtility urlEncode:@"console"],
                          [MFUtility urlEncode:@"warn"],
                          [MFUtility urlEncode:@"I'm warn"]];
        NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:path]];
        [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
        GHAssertEqualStrings(latestLog, @"[warn] I'm warn", @"check console warn");
    }();
    ^(){
        latestLog = nil;
        NSString *path = [NSString stringWithFormat:@"monaca://action?type=%@&method=%@&message=%@",
                          [MFUtility urlEncode:@"console"],
                          [MFUtility urlEncode:@"error"],
                          [MFUtility urlEncode:@"I'm error"]];
        NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:path]];
        [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
        GHAssertEqualStrings(@"[error] I'm error", latestLog, @"check console error");
    }();
}

- (void)testBuildLog
{
    ^(){
        NSString *path = [NSString stringWithFormat:@"monaca://action?type=%@&method=%@&message=%@",
                                                    [MFUtility urlEncode:@"console"],
                                                    [MFUtility urlEncode:@"info"],
                                                    [MFUtility urlEncode:@"I'm info"]];
        NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:path]];
        GHAssertEqualStrings([MFJSInterfaceProtocol buildLog:[MFUtility parseQuery:request]], @"[info] I'm info", @"monaca.console.info");
    }();
    ^(){
        NSString *path = [NSString stringWithFormat:@"monaca://action?type=%@&method=%@&message=%@",
                                                    [MFUtility urlEncode:@"console"],
                                                    [MFUtility urlEncode:@"log"],
                                                    [MFUtility urlEncode:@"I'm log"]];
        NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:path]];
        GHAssertEqualStrings([MFJSInterfaceProtocol buildLog:[MFUtility parseQuery:request]], @"[log] I'm log", @"monaca.console.log");
    }();
}
@end
