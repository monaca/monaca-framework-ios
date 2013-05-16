//
//  IPPRESTCore.h
//  IPPDemoApp
//
//  Created by Ken Miyachi on 2012/10/30.
//  Copyright (c) 2012年 Ken Miyachi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DebugLog.h"
#import "NSError+IPP.h"
#import "IPPQueryResult.h"
#import "IPPJSONSerialization.h"

#define IPP_REST_KIT_MAJOR_VERSION 1
#define IPP_REST_KIT_MINOR_VERSION 0
#define IPP_REST_KIT_SUBMINOR_VERSION 0
#define IPP_STR(n) IPP_STR_EXP(n)
#define IPP_STR_EXP(n) #n
#define IPP_REST_KIT_VERSION IPP_STR(IPP_REST_KIT_MAJOR_VERSION) "." IPP_STR(IPP_REST_KIT_MINOR_VERSION) "." IPP_STR(IPP_REST_KIT_SUBMINOR_VERSION)

#ifndef IPPRESTKitCore_h
#define IPPRESTKitCore_h
#pragma mark -
#pragma mark IPPRESTKit Delegate Protocol
/* IPPRESTKit Delegate Protocol */
/**
 * IPPRESTDelegate : see NSURLConnectionDelegate
 */
@protocol IPPRESTDelegate <NSURLConnectionDataDelegate>

/**
 * @see connection:didReceiveResponse:
 */
- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse*)response;

/**
 * @see connection:didReceiveData:
 */
- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData*)data;

/**
 * @see connection:didFailWithError:
 */
- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError*)error;

/**
 * @see connectionDidFinishLoading:
 */
- (void)connectionDidFinishLoading:(NSURLConnection *)connection;
@end

#pragma mark -
#pragma mark IPPSharedData Delegate Protocol
/* IPPSharedData Delegate Protocol */
@protocol IPPSharedDataDelegate <NSObject>
@optional
- (void)sharedDataDidFinishLoading:(NSError*) error;
@end
#endif

#pragma mark -
#pragma mark IPPRESTCore Interface
@interface IPPRESTCore : NSObject
/* - (id) initWithResourcePath:(NSString*)path */
/*
 * Initialize with resource path
 * @Params
 * NSString* path                 : resource path of http request
 * @Return
 * id                             : IPPRESTKit instance
 */
- (id) initWithResourcePath:(NSString*)path;

/* - (void) setResourcePath:(NSString*)path */
/*
 * ResourcePath setter
 * @Params
 * NSString* path                 : resource path of http request
 */
- (void) setResourcePath:(NSString*)path;

/* - (void) setAuthKey:(NSString*)authKey */
- (void) setAuthKey:(NSString*)authKey;

/* - (void) setApplicationId:(NSString*)appId */
- (void) setApplicationId:(NSString*)appId;

/* - (void) setValue:(NSString*)value forHTTPHeaderField:(NSString *)field */
/*
 * HTTP header setter
 * @Params
 * NSString* value                 : http header value
 * NSString* field                 : http header field name
 */
- (void) setValue:(NSString*)value forHTTPHeaderField:(NSString *)field;


/* - (void) removeHTTPHeaderField */
/*
 * Remove HTTP header
 */
- (void) removeHTTPHeaderField;

/* - (NSMutableDictionary*) getHTTPHeaderField */
/* Get HTTP header  
 * @Return
 * NSMutableDictionary*  httpHeader
 */
- (NSMutableDictionary*) getHTTPHeaderField;

/* - (NSString*) descriptionHTTPHeader */
/* Description HTTP header  
 * @Return
 * NSString*  httpHeader description
 */
- (NSString*) descriptionHTTPHeader;

/* - (void)setTimeout:(float)time */
/* Set HTTP client timeout interval
 * @Param
 * float                        : timeout interval
 */
- (void)setTimeout:(float)time;

/* - (NSString*)timeoutDescription */
/* Describe current setting HTTP client timeout interval
 * @Return
 * NSString*                        : current timeout interval
 */
- (NSString*)timeoutDescription;


/* - (NSMutableURLRequest*) ippCreateURLRequest:(NSString*)methodType withParams:(NSMutableDictionary*)params */
/* Create HTTP Client
 * @Params
 * (NSString*)methodType                : Method type (POST, GET, PUT, DELETE)
 * (NSMutableDictionary*)params         : HTTP parameters
 * @Return
 * NSMutableURLRequest*  http client
 */
- (NSMutableURLRequest*) ippCreateURLRequest:(NSString*)methodType withParams:(NSMutableDictionary*)params;

/* - (NSError*) ippSyncRequest:(NSMutableURLRequest*)request resultClass:(IPPQueryResult*)queryResult */
/* HTTP synchronize request
 * @Params
 * (NSMutableURLRequest*)request        : HTTP client
 * (IPPQueryResult*)queryResult         : Request result
 * @Return
 * NSError*                             : NSError+IPP
 */
- (NSError*) ippSyncRequest:(NSMutableURLRequest*)request resultClass:(IPPQueryResult*)queryResult;

/* - (NSError*) ippAsyncRequest:(NSMutableURLRequest*)request IPPDelegate:(id<IPPRESTDelegate>)delegate */
/* HTTP asynchronous request
 * @Params
 * (NSMutableURLRequest*)request        : HTTP client
 * (id<IPPRESTDelegate>)delegate        : Delegate
 * @Return
 * NSError*                             : NSError+IPP
 */
- (NSError*) ippAsyncRequest:(NSMutableURLRequest*)request IPPDelegate:(id<IPPRESTDelegate>)delegate;

/* + (NSMutableString*) createQueryParameter:(NSMutableDictionary*)paramDictionary */
/* Create HTTP parameter string
 * @Params
 * (NSMutableDictionary*)paramDictionary : HTTP parameters
 * @Return
 * NSMutableString*                      : HTTP parameter string
 */
+ (NSMutableString*) createQueryParameter:(NSMutableDictionary*)paramDictionary;


@end
