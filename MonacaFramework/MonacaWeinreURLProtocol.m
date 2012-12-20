//
//  MonacaWeinreURLProtocol.m
//  MonacaDebugger
//
//  Created by yasuhiro on 12/12/20.
//  Copyright (c) 2012年 ASIAL CORPORATION. All rights reserved.
//

#import "MonacaWeinreURLProtocol.h"
#import "MDUtility.h"

@implementation MonacaWeinreURLProtocol

static BOOL isWork = YES;

+ (BOOL)canInitWithRequest:(NSURLRequest *)request
{
    // targets are html file with file protocol.
    if (isWork && request.URL.port==nil && [request.URL.scheme isEqualToString:@"file"] &&
        [request.URL.pathExtension isEqualToString:@"html"]) {
        return YES;
    }
    return NO;
}

- (void)startLoading
{
    NSString *html = [self InsertMonacaQueryParams:self.request];

    MonacaDebuggerViewDelegate *viewDelegate = [MDUtility getViewDelegate];
    // write html
    [viewDelegate writeHtml:html];

    NSString *weinreTag = [NSString stringWithFormat:@"<script>document.addEventListener('deviceready', function(){var weinreScript = document.createElement('script');weinreScript.type='text/javascript';weinreScript.src='%@';document.body.appendChild(weinreScript);}, false);</script>", viewDelegate.projectInfo.inspector_js_file];
    html = [html stringByAppendingString:weinreTag];
    NSData *data = [html dataUsingEncoding:NSUTF8StringEncoding];

    // create header for no-cache, because of UIWebView has cache on file protocol.
    NSHTTPURLResponse *response = [self responseWithNonCacheHeader:self.request Data:data];

    [self.client URLProtocol:self didReceiveResponse:response cacheStoragePolicy:NSURLCacheStorageAllowedInMemoryOnly];

    // Display Contents
    [self.client URLProtocol:self didLoadData:data];
    [self.client URLProtocolDidFinishLoading:self];
}

- (void)stopLoading
{
	// do any cleanup here
}

@end
