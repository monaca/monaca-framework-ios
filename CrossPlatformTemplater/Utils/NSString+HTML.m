//
//  NSString+HTML.m
//  ForteTemplateEngine
//
//  Created by Hiroki Nakagawa on 11/08/11.
//  Copyright 2011 ASIAL CORPORATION. All rights reserved.
//

#import "NSString+HTML.h"


@implementation NSString (HTML)

+ (NSString *)stringByEncodingHTMLEntities: (NSString *)string {
    string = [string stringByReplacingOccurrencesOfString:@"<" withString:@"&lt;"];
    string = [string stringByReplacingOccurrencesOfString:@">" withString:@"&gt;"];
    string = [string stringByReplacingOccurrencesOfString:@"\"" withString:@"&quot;"];
    string = [string stringByReplacingOccurrencesOfString:@"'" withString:@"&rsquo;"];
    return string;
}

@end