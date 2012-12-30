//
//  URLProtocolAbstruct.h
//  MonacaDebugger
//
//  Created by yasuhiro on 12/12/20.
//  Copyright (c) 2012年 ASIAL CORPORATION. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MonacaNoCacheURLProtocol : NSURLProtocol
- (NSHTTPURLResponse *)responseWithNonCacheHeader:(NSURLRequest *)request Data:(NSData *)data;

@end
