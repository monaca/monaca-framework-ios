//
//  NSString+HTML.h
//  ForteTemplateEngine
//
//  Created by Hiroki Nakagawa on 11/08/11.
//  Copyright 2011 ASIAL CORPORATION. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface NSString (HTML)
+ (NSString *)stringByEncodingHTMLEntities: (NSString *)string;
@end