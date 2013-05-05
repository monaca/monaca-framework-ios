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

#pragma mark - test methods

- (void)testCanInitWithRequest
{
    ^(){
        NSString *path = [NSString stringWithFormat:@"monaca://log?level=%@&message=%@",
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
        GHAssertFalse([MFJSInterfaceProtocol requestIsCacheEquivalent:aRequest toRequest:aRequest], @"Return value is NO");
    }();
    ^(){
        NSURLRequest *aRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:@"http://monaca.mobi"]];
        NSURLRequest *bRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:@"http://google.com"]];
        GHAssertFalse([MFJSInterfaceProtocol requestIsCacheEquivalent:aRequest toRequest:bRequest], @"Return value is NO");
    }();
}

- (void)testCanonicalRequestForRequest
{
    ^(){
        NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:@"http://monaca.mobi"]];
        GHAssertEqualObjects([MFJSInterfaceProtocol canonicalRequestForRequest:request], request, @"Should be return same request.");
    }();
    ^(){
        NSURLRequest *aRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:@"http://monaca.mobi"]];
        NSURLRequest *bRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:@"http://google.com"]];
        GHAssertNotEqualObjects([MFJSInterfaceProtocol canonicalRequestForRequest:bRequest], aRequest, @"Should be return same request.");
    }();
}

#pragma mark - Test all of this class

- (void)testStartLoading
{
    ^(){
        latestLog = nil;
        NSString *path = [NSString stringWithFormat:@"monaca://log"];
        NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:path]];
        [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
        GHAssertEqualStrings(latestLog, nil, @"In no level and no message, does nothing.");
    }();
    ^(){
        latestLog = nil;
        NSString *path = [NSString stringWithFormat:@"monaca://log?level=%@",
                          [MFUtility urlEncode:@"log"]];
        NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:path]];
        [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
        GHAssertEqualStrings(latestLog, nil, @"Only 'level' query, no message");
    }();
    ^(){
        latestLog = nil;
        NSString *path = [NSString stringWithFormat:@"monaca://log?message=%@",
                          [MFUtility urlEncode:@"This is just message."]];
        NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:path]];
        [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
        GHAssertEqualStrings(latestLog, @"This is just message.", @"Only 'message' query, just shows message");
    }();
    ^(){
        latestLog = nil;
        NSString *path = [NSString stringWithFormat:@"monaca://log?level=%@&message=",
                          [MFUtility urlEncode:@"log"]];
        NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:path]];
        [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
        GHAssertEqualStrings(latestLog, @"", @"Blank message");
    }();
    ^(){
        latestLog = nil;
        NSString *path = [NSString stringWithFormat:@"monaca://log?level=%@&message=%@",
                          [MFUtility urlEncode:@"foo"],
                          [MFUtility urlEncode:@"This is message."]];
        NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:path]];
        [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
        GHAssertEqualStrings(latestLog, @"This is message.", @"In no support level, shows only message");
    }();
    ^(){
        latestLog = nil;
        NSString *path = [NSString stringWithFormat:@"monaca://log?level=%@&message=%@",
                          [MFUtility urlEncode:@"debug"],
                          [MFUtility urlEncode:@"I'm debug"]];
        NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:path]];
        [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
        GHAssertEqualStrings(latestLog, @"I'm debug", @"Check console debug");
    }();
    ^(){
        latestLog = nil;
        NSString *path = [NSString stringWithFormat:@"monaca://log?level=%@&message=%@",
                          [MFUtility urlEncode:@"info"],
                          [MFUtility urlEncode:@"I'm info"]];
        NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:path]];
        [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
        GHAssertEqualStrings(latestLog, @"I'm info", @"Check console info");
    }();
    ^(){
        latestLog = nil;
        NSString *path = [NSString stringWithFormat:@"monaca://log?level=%@&message=%@",
                          [MFUtility urlEncode:@"log"],
                          [MFUtility urlEncode:@"I'm log"]];
        NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:path]];
        [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
        GHAssertEqualStrings(latestLog, @"I'm log", @"Check console log");
    }();
    ^(){
        latestLog = nil;
        NSString *path = [NSString stringWithFormat:@"monaca://log?level=%@&message=%@",
                          [MFUtility urlEncode:@"warn"],
                          [MFUtility urlEncode:@"I'm warn"]];
        NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:path]];
        [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
        GHAssertEqualStrings(latestLog, @"I'm warn", @"Check console warn");
    }();
    ^(){
        latestLog = nil;
        NSString *path = [NSString stringWithFormat:@"monaca://log?level=%@&message=%@",
                          [MFUtility urlEncode:@"error"],
                          [MFUtility urlEncode:@"I'm error"]];
        NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:path]];
        [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
        GHAssertEqualStrings(latestLog, @"I'm error", @"Check console error");
    }();
}

@end
