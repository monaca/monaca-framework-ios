//
//  MonacaQueryParamURLProtocol.h
//  MonacaDebugger
//
//  Created by yasuhiro on 12/12/20.
//  Copyright (c) 2012年 ASIAL CORPORATION. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MFUtility.h"
#import "MonacaNoCacheURLProtocol.h"

@interface MonacaQueryParamURLProtocol : MonacaNoCacheURLProtocol

+ (BOOL)isFileAccess:(NSURLRequest *)request;

- (NSString *)InsertMonacaQueryParams:(NSURLRequest *)request;

@end
