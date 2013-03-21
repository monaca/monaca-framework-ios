//
//  MDUtilityTest.m
//  MonacaDebugger
//
//  Created by Katsuya Saitou on 13/01/08.
//  Copyright (c) 2013年 ASIAL CORPORATION. All rights reserved.
//

#import "MFUtilityTest.h"

@implementation MFUtilityTest

- (void)testEncodeURIComponent
{
    GHAssertEqualStrings([MFUtility urlEncode:@"test@monaca.mobi"], @"test%40monaca.mobi", nil);
    GHAssertEqualStrings([MFUtility urlEncode:@"monaca+mobi"], @"monaca%2Bmobi", nil);
    GHAssertEqualStrings([MFUtility urlEncode:@"?hoge=piyo"], @"%3Fhoge%3Dpiyo", nil);
    GHAssertEqualStrings([MFUtility urlEncode:@"?hoge=piyo&foo=bar"], @"%3Fhoge%3Dpiyo%26foo%3Dbar", nil);
    GHAssertEqualStrings([MFUtility urlEncode:@"!*'();:@&=+$,/?%#[]"], @"%21%2A%27%28%29%3B%3A%40%26%3D%2B%24%2C%2F%3F%25%23%5B%5D", nil);
    GHAssertEqualStrings([MFUtility urlEncode:0], @"", nil);
    GHAssertEqualStrings([MFUtility urlEncode:[NSArray array]], @"", nil);
}

- (void)testInsertMonacaQueryParams
{
    GHAssertEqualStrings([MFUtility insertMonacaQueryParams:@"" query:@"key=hoge"], @"<script>window.monaca = window.monaca || {};window.monaca.queryParams = {\"key\":\"hoge\"};</script>", nil);
    GHAssertEqualStrings([MFUtility insertMonacaQueryParams:@"<html></html>" query:@"key=hoge"], @"<script>window.monaca = window.monaca || {};window.monaca.queryParams = {\"key\":\"hoge\"};</script><html></html>", nil);
    GHAssertEqualStrings([MFUtility insertMonacaQueryParams:@"<html><head></head></html>" query:@"key=hoge"], @"<html><head><script>window.monaca = window.monaca || {};window.monaca.queryParams = {\"key\":\"hoge\"};</script></head></html>", nil);

    GHAssertEqualStrings([MFUtility insertMonacaQueryParams:@"" query:@"key=1"], @"<script>window.monaca = window.monaca || {};window.monaca.queryParams = {\"key\":\"1\"};</script>", nil);
    GHAssertEqualStrings([MFUtility insertMonacaQueryParams:@"" query:@"key="], @"<script>window.monaca = window.monaca || {};window.monaca.queryParams = {\"key\":\"\"};</script>", nil);
    GHAssertEqualStrings([MFUtility insertMonacaQueryParams:@"" query:@"key=hoge&foo=bar"], @"<script>window.monaca = window.monaca || {};window.monaca.queryParams = {\"key\":\"hoge\",\"foo\":\"bar\"};</script>", nil);
    GHAssertEqualStrings([MFUtility insertMonacaQueryParams:@"" query:@"key=&foo=bar"], @"<script>window.monaca = window.monaca || {};window.monaca.queryParams = {\"key\":\"\",\"foo\":\"bar\"};</script>", nil);
}

- (void)testIsFileAccess
{
    // Supporting Filesにファイルが置いてある事が前提
    NSString *bundlePath = [[NSBundle mainBundle] bundlePath] ;
    NSURLRequest *request;
    request = [NSURLRequest requestWithURL:[NSURL fileURLWithPath:[NSString stringWithFormat:@"%@/exist.html", bundlePath]]];
    GHAssertEquals([MonacaQueryParamURLProtocol isFileAccess:request], YES, nil);
    request = [NSURLRequest requestWithURL:[NSURL fileURLWithPath:[NSString stringWithFormat:@"%@/notexist.html", bundlePath]]];
    GHAssertEquals([MonacaQueryParamURLProtocol isFileAccess:request], NO, nil);
    request = [NSURLRequest requestWithURL:[NSURL fileURLWithPath:[NSString stringWithFormat:@"%@/exist.css", bundlePath]]];
    GHAssertEquals([MonacaQueryParamURLProtocol isFileAccess:request], NO, nil);
    request = [NSURLRequest requestWithURL:[NSURL fileURLWithPath:[NSString stringWithFormat:@"%@/notexist.css", bundlePath]]];
    GHAssertEquals([MonacaQueryParamURLProtocol isFileAccess:request], NO, nil);
    request = [NSURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://notexist.html"]]];
    GHAssertEquals([MonacaQueryParamURLProtocol isFileAccess:request], NO, nil);
    
}

- (void)testParseQuery
{
    ^(){
        NSString *path = [NSString stringWithFormat:@"file://www/index.html"];
        NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:path]];
        NSMutableDictionary *dictionary = [NSMutableDictionary dictionary];
        GHAssertEqualObjects([MFUtility parseQuery:request], dictionary, @"no query");
    }();
    ^(){
        NSString *path = [NSString stringWithFormat:@"file://www/index.html?"];
        NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:path]];
        NSMutableDictionary *dictionary = [NSMutableDictionary dictionary];
        GHAssertEqualObjects([MFUtility parseQuery:request], dictionary, @"no query, but has '?'");
    }();
    ^(){
        NSString *path = [NSString stringWithFormat:@"file://www/index.html?monaca"];
        NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:path]];
        NSMutableDictionary *dictionary = [NSMutableDictionary dictionaryWithObjects:[NSArray arrayWithObjects:[NSNull null], nil]
                                                                             forKeys:[NSArray arrayWithObjects:@"monaca", nil]];
        GHAssertEqualObjects([MFUtility parseQuery:request], dictionary, @"only key");
    }();
    ^(){
        NSString *path = [NSString stringWithFormat:@"file://www/index.html?monaca&"];
        NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:path]];
        NSMutableDictionary *dictionary = [NSMutableDictionary dictionaryWithObjects:[NSArray arrayWithObjects:[NSNull null], nil]
                                                                             forKeys:[NSArray arrayWithObjects:@"monaca", nil]];
        GHAssertEqualObjects([MFUtility parseQuery:request], dictionary, @"only key and has '&'");
    }();
    ^(){
        NSString *path = [NSString stringWithFormat:@"file://www/index.html?monaca="];
        NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:path]];
        NSMutableDictionary *dictionary = [NSMutableDictionary dictionaryWithObjects:[NSArray arrayWithObjects:@"", nil]
                                                                             forKeys:[NSArray arrayWithObjects:@"monaca", nil]];
        GHAssertEqualObjects([MFUtility parseQuery:request], dictionary, @"only key and has '='");
    }();
    ^(){
        NSString *path = [NSString stringWithFormat:@"file://www/index.html&"];
        NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:path]];
        NSMutableDictionary *dictionary = [NSMutableDictionary dictionary];
        GHAssertEqualObjects([MFUtility parseQuery:request], dictionary, @"only '&'");
    }();
    ^(){
        NSString *path = [NSString stringWithFormat:@"file://www/index.html?&"];
        NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:path]];
        NSMutableDictionary *dictionary = [NSMutableDictionary dictionary];
        GHAssertEqualObjects([MFUtility parseQuery:request], dictionary, @"has '?' and '&'");
    }();
    ^(){
        NSString *path = [NSString stringWithFormat:@"file://www/index.html?hoge=%@&key=%@",
                          [MFUtility urlEncode:@"piyo"],
                          [MFUtility urlEncode:@"value"]];
        NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:path]];
        NSMutableDictionary *dictionary = [NSMutableDictionary dictionaryWithObjects:[NSArray arrayWithObjects:@"piyo", @"value", nil]
                                                                             forKeys:[NSArray arrayWithObjects:@"hoge", @"key", nil]];
        GHAssertEqualObjects([MFUtility parseQuery:request], dictionary, @"has query");
    }();
}

- (void)testGetWWWShortPath
{
    GHAssertEqualStrings([MFUtility getWWWShortPath:@"/User/hoge/assets/www/hoge.html"], @"www/hoge.html", nil);
    GHAssertEqualStrings([MFUtility getWWWShortPath:@"/User/hoge/assets/www/www/hoge.html"], @"www/www/hoge.html", nil);
    GHAssertEqualStrings([MFUtility getWWWShortPath:@"/User/hoge/assets/www/fuga/www/hoge.html"], @"www/fuga/www/hoge.html", nil);
    GHAssertEqualStrings([MFUtility getWWWShortPath:@"/test/hoge.html"], @"", nil);
}
@end