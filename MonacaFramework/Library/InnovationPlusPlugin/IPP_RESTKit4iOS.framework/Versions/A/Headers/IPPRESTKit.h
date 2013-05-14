//
//  @File       IPPRESTKit.h
//  @Project    IPPDemoApp
//  @brief      IPPQuery Class method
//  @version    1.0.0
//
//  Created by Ken Miyachi on 12/10/10.
//  Copyright (c) 2012 Ken Miyachi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "IPPRESTCore.h"
#import "DebugLog.h"
#import "NSError+IPP.h"
#import "IPPQueryResult.h"
#import "IPPSharedData.h"

#ifndef IPPRESTKitCore_h
#pragma mark -
#pragma mark IPPRESTKit Delegate Protocol 
/* IPPRESTKit Delegate Protocol */
@protocol IPPRESTDelegate <NSObject>
- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse*)response;
- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData*)data;
- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError*)error;
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
#pragma mark Interface IPPRESTKit
/* IPPRESTKit */
@interface IPPRESTKit : IPPRESTCore

/* -(id) initWithResourcePath:(NSString*)path */
/*
 * Initialize with resource path
 * @Params
 * NSString* path                 : resource path of http request
 * @Return
 * id                             : IPPRESTKit instance
 */
- (id) initWithResourcePath:(NSString*)path;

/* -(void) setResourcePath:(NSString*)path */
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

/* -(void) setValue:(NSString*)value forHTTPHeaderField:(NSString *)field */
/*
 * HTTP header setter
 * @Params
 * NSString* value                 : http header value
 * NSString* field                 : http header field name
 */
- (void) setValue:(NSString*)value forHTTPHeaderField:(NSString *)field;

/* - (void) removeHTTPHeaderField  */
/*
 * Remove HTTP header
 */
- (void) removeHTTPHeaderField;

/* - (NSMutableDictionary*) getHTTPHeaderField  */
/* Get HTTP header
 * @Return
 * NSMutableDictionary*  httpHeader
 */
- (NSMutableDictionary*) getHTTPHeaderField;

/* - (NSString*) descriptionHTTPHeader  */
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

#pragma mark -
#pragma mark REST Method (POST)
/* HTTP POST Request (Synchronize method)*/
/* - (NSError*) postRequest:(NSMutableDictionary*)postData resultClass:(IPPQueryResult*)queryResult */
/*
 * HTTP Request : ( POST )
 * @Params
 * NSMutableDictionary* postData    : POST data
 * IPPQueryResult* queryResult      : Result of IPP query
 * @Return
 * NSError                          : NSError+IPP
 */
- (NSError*) postRequest:(NSMutableDictionary*)postData resultClass:(IPPQueryResult*)queryResult;

/* HTTP POST Request (Synchronize method)*/
/* - (NSError*) postRequest:(NSMutableDictionary*)postData withParam:(NSMutableDictionary*)params resultClass:(IPPQueryResult*)queryResult */
/*
 * HTTP Request : ( POST )
 * @Params
 * NSMutableDictionary* postData    : POST data
 * NSMutableDictionary* params      : POST parameters
 * IPPQueryResult* queryResult      : Result of IPP query
 * @Return
 * NSError                          : NSError+IPP
 */
- (NSError*) postRequest:(NSMutableDictionary*)postData withParam:(NSMutableDictionary*)params resultClass:(IPPQueryResult*)queryResult;

/* HTTP POST Request (Asynchronous method)*/
/* - (NSError*) postAsyncRequest:(NSMutableDictionary*)postData IPPDelegate:(id<IPPQueryDelegate>)delegate */
/*
 * HTTP Request : ( POST )
 * @Params
 * NSMutableDictionary* postData    : POST data
 * id<IPPRESTDelegate> delegate     : IPPRESTDelegate
 * @Return
 * NSError                          : NSError+IPP
 */
- (NSError*) postAsyncRequest:(NSMutableDictionary*)postData IPPRESTDelegate:(id<IPPRESTDelegate>)delegate;

/* HTTP POST Request (Asynchronous method)*/
/* - (NSError*) postAsyncRequest:(NSMutableDictionary*)postData IPPDelegate:(id<IPPQueryDelegate>)delegate */
/*
 * HTTP Request : ( POST )
 * @Params
 * NSMutableDictionary* postData    : POST data
 * NSMutableDictionary* params      : POST parameters
 * id<IPPRESTDelegate> delegate     : IPPRESTDelegate
 * @Return
 * NSError                          : NSError+IPP
*/
- (NSError*) postAsyncRequest:(NSMutableDictionary*)postData withParam:(NSMutableDictionary*)params IPPRESTDelegate:(id<IPPRESTDelegate>)delegate;

/* TODO comment this */
- (NSError*) postAsyncArrayRequest:(NSArray*)postData IPPRESTDelegate:(id<IPPRESTDelegate>)delegate;
/* TODO comment this */
- (NSError*) postAsyncArrayRequest:(NSArray*)postData withParam:(NSMutableDictionary*)params IPPRESTDelegate:(id<IPPRESTDelegate>)delegate;

#pragma mark -
#pragma mark REST Method (GET)
/* HTTP GET Request (Synchronize method)*/
/* - (NSError*) getRequest:(NSMutableDictionary*)params resultClass:(IPPQueryResult*)queryResult */
/*
 * HTTP Request : ( GET )
 * @Params
 * NSMutableDictionary* params      : GET parameters
 * IPPQueryResult* queryResult      : Result of IPP query
 * @Return
 * NSError                          : NSError+IPP
 */
- (NSError*) getRequest:(NSMutableDictionary*)params resultClass:(IPPQueryResult*)queryResult;

/* HTTP GET Request (Asynchronous method)*/
/* - getRequest:(NSMutableDictionary*)params resultClass:(IPPQueryResult*)queryResult */
/*
 * HTTP Request : ( GET )
 * @Params
 * NSMutableDictionary* params      : GET parameters
 * id<IPPRESTDelegate> delegate     : IPPRESTDelegate
 */
- (NSError*) getAsyncRequest:(NSMutableDictionary*)params IPPRESTDelegate:(id<IPPRESTDelegate>)delegate;


#pragma mark -
#pragma mark REST Method (PUT)
/* HTTP PUT Request (Synchronize method)*/
/* - (NSError*) putRequest:(NSMutableDictionary*)params resultClass:(IPPQueryResult*)queryResult */
/*
 * HTTP Request : ( PUT )
 * @Params
 * NSMutableDictionary* putData     : PUT data
 * NSMutableDictionary* params      : PUT parameters
 * IPPQueryResult* queryResult      : Result of IPP query
 * @Return
 * NSError                          : NSError+IPP
 */
- (NSError*) putRequest:(NSMutableDictionary*)putData withParam:(NSMutableDictionary*)params resultClass:(IPPQueryResult*)queryResult;

/* HTTP PUT Request (Synchronize method)*/
/* - (NSError*) putAsyncRequest:(NSMutableDictionary*)putData withParam:(NSMutableDictionary*)params IPPRESTDelegate:(id<IPPRESTDelegate>)delegate */
/*
 * HTTP Request : ( PUT )
 * @Params
 * NSMutableDictionary* putData     : PUT data
 * NSMutableDictionary* params      : PUT parameters
 * IPPQueryResult* queryResult      : Result of IPP query
 * id<IPPRESTDelegate> delegate    : IPPRESTDelegate
 * @Return
 * NSError                          : NSError+IPP
 */
- (NSError*) putAsyncRequest:(NSMutableDictionary*)putData withParam:(NSMutableDictionary*)params IPPRESTDelegate:(id<IPPRESTDelegate>)delegate;

#pragma mark -
#pragma mark REST Method (DELETE)
/* HTTP DELETE Request (Synchronize method)*/
/* - (NSError*) deleteRequest:(NSMutableDictionary*)params resultClass:(IPPQueryResult*)queryResult */
/*
 * HTTP Request : ( DELETE )
 * @Params
 * NSMutableDictionary* params      : DELETE parameters
 * IPPQueryResult* queryResult      : Result of IPP query
 * @Return
 * NSError                          : NSError+IPP
 */
- (NSError*) deleteRequest:(NSMutableDictionary*)params resultClass:(IPPQueryResult*)queryResult;

/* HTTP DELETE Request (Asynchronous method)*/
/* - deleteRequest:(NSMutableDictionary*)params resultClass:(IPPQueryResult*)queryResult */
/*
 * HTTP Request : ( DELETE )
 * @Params
 * NSMutableDictionary* params      : DELETE parameters
 * id<IPPRESTDelegate> delegate     : IPPRESTDelegate
 */
- (NSError*) deleteAsyncRequest:(NSMutableDictionary*)params IPPRESTDelegate:(id<IPPRESTDelegate>)delegate;


#pragma mark -
#pragma mark GET Result store to IPPSharedData
/* HTTP GET Request (Synchronize method) , and result store to IPPSharedData */
/* (NSError*) getSharedData:(NSMutableDictionary*)params storeKeyName:(NSString*)keyName */
/*
 * HTTP Request : ( GET )
 * @Params
 * NSMutableDictionary* params      : GET parameters
 * NSString* keyName                : store keyname for IPPSharedData
 * @Return
 * NSError                          : NSError+IPP
 */
- (NSError*) getSharedData:(NSMutableDictionary*)params storeKeyName:(NSString*)keyName;

/* HTTP GET Request (Synchronize method) , and result store to IPPSharedData */
/* (NSError*) getSharedData:(NSMutableDictionary*)params storeKeyName:(NSString*)keyName IPPSharedDataDelegate:(id<IPPSharedDataDelegate>)delegate*/
/*
 * HTTP Request : ( GET )
 * @Params
 * NSMutableDictionary* params        : GET parameters
 * NSString* keyName                  : store keyname for IPPSharedData
 * id<IPPSharedDataDelegate> delegate : IPPSharedDataDelegate
 */
- (void) getSharedData:(NSMutableDictionary*)params storeKeyName:(NSString*)keyName IPPSharedDataDelegate:(id<IPPSharedDataDelegate>)delegate;

#pragma mark -
#pragma mark GET Result store to IPPSharedData (Class Method)
/* HTTP GET Request (Synchronize method) , and result store to IPPSharedData */
/* (NSError*) getSharedData:(NSMutableDictionary*)params storeKeyName:(NSString*)keyName */
/*
 * HTTP Request : ( GET )
 * @Params
 * NSString* resourcePath           : resource path of http request 
 * NSMutableDictionary* params      : GET parameters
 * NSMutableDictionary* headers     : http header 
 * NSString* keyName                : store keyname for IPPSharedData
 * @Return
 * NSError                          : NSError+IPP
 */
+ (NSError*) getSharedData:(NSString*)resourcePath withQueryParams:(NSMutableDictionary*)params httpHeader:(NSMutableDictionary*)headers storeKeyName:(NSString*)keyName;

/* HTTP GET Request (Synchronize method) , and result store to IPPSharedData */
/* (NSError*) getSharedData:(NSMutableDictionary*)params storeKeyName:(NSString*)keyName */
/*
 * HTTP Request : ( GET )
 * @Params
 * NSString* resourcePath           : resource path of http request
 * NSMutableDictionary* params      : GET parameters
 * NSMutableDictionary* headers     : http header
 * NSString* keyName                : store keyname for IPPSharedData
 * id<IPPSharedDataDelegate> delegate : IPPSharedDataDelegate
 */
+ (void) getSharedData:(NSString*)resourcePath withQueryParams:(NSMutableDictionary*)params httpHeader:(NSMutableDictionary*)headers storeKeyName:(NSString*)keyName IPPSharedDataDelegate:(id<IPPSharedDataDelegate>)delegate;

#pragma mark -
#pragma mart RESTKit version
+ (NSString*) versionNoDescription;

@end
