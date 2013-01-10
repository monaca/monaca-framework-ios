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
    GHAssertEqualStrings([MFUtility insertMonacaQueryParams:@"<html></html>" query:@"key=hoge"], @"<script>window.monaca = window.monaca || {};window.monaca.queryParams = {\"key\":\"hoge\"};</script><html></html>", nil);
}

@end