//
//  Utility.h
//  Template
//
//  Created by Hiroki Nakagawa on 11/06/07.
//  Copyright 2011 ASIAL CORPORATION. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NativeComponents.h"

@interface MFUtility : NSObject
{

}

+ (NSDictionary *)queryParams;
+ (void)setQueryParams:(NSDictionary *)params;
+ (UIInterfaceOrientation) currentInterfaceOrientation;
+ (BOOL) getAllowOrientationFromPlist:(UIInterfaceOrientation)interfaceOrientation;
+ (BOOL)getAllowOrientationFromPlistAndMonacaSkeletonInfo:(NSArray*)orientations;
+ (NSDictionary *)parseJSONFile:(NSString *)path;
+ (NSString *)correctJSON:(NSString *)data;
+ (NSMutableDictionary *)parseQuery:(NSURLRequest *)request;
+ (NSString *)urlEncode:(NSString *)text;
+ (BOOL)isPhoneGapScheme:(NSURL *)url;
+ (BOOL)isExternalPage:(NSURL *)url;
+ (BOOL)hasAnchor:(NSURL *)url;
+ (NSURL *)standardizedURL:(NSURL *)url;
+ (NSURL *)getBaseURL;
+ (NSString *)getWWWShortPath:(NSString *)path;
+ (NSString *)insertMonacaQueryParams:(NSString *)html query:(NSString *)aQuery;
+ (NSString *)getUIFileName:(NSString *)filename;
+ (NSDictionary *)getApplicationPlist;
+ (void)fixedLayout:(MFViewController *)monacaViewController interfaceOrientation:
    (UIInterfaceOrientation)aInterfaceOrientation;
+ (MFDelegate *)getAppDelegate;
+ (NSURLResponse *)register_push:(NSString *)deviceToken;
+ (void)setMonacaCloudCookie;
+ (void)clearMonacaCloudCookie;
+ (void)checkWithInfo:(NSDictionary *)info;

@end
