//
//  IPPApplicationResourceClient.h
//  IPP_RESTKit4iOS
//
//  Created by takazawa on 13/04/23.
//  Copyright (c) 2013年 INNOVATIONPLUS. Inc,. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "IPPDefaultClient.h"

/**
 * IPPApplicationResourceClient : REST Client for ApplicationResource
 *
 * @author InnovationPlus Inc.
 * @version 0.8.0a
 */
@interface IPPApplicationResourceClient : IPPDefaultClient

/**
 * Constructor
 *
 * @return HTTP Client for access to 'application resource' API
 */
- (id) init;

/**
 * create new resource.
 *
 * @param resourceName resource name
 * @param resource resource object
 * @param delegate callback when HTTP response
 */
- (void) create:(NSString*)resourceName
       resource:(NSMutableDictionary*)resource
       callback:(id<IPPQueryCallback>)delegate;

/**
 * create new resources.
 *
 * @param resourceName resource name
 * @param resources resource array object
 * @param delegate callback when HTTP response
 */
- (void) createAll:(NSString*)resourceName
         resources:(NSMutableArray*)resources
          callback:(id<IPPQueryCallback>)delegate;

/**
 * retrieve resource specified Resource ID.
 *
 * @param resourceName resource name
 * @param resourceId resource ID
 * @param delegate callback when HTTP response
 */
- (void) get:(NSString*)resourceName
  resourceId:(NSString*)resourceId
    callback:(id<IPPQueryCallback>)delegate;

/**
 * query any resources.
 *
 * @param resourceName resource name
 * @param condition query condition
 * @param delegate callback when HTTP response
 */
- (void) query:(NSString*)resourceName
     condition:(NSMutableDictionary*)condition
      callback:(id<IPPQueryCallback>)delegate;

/**
 * delete resource specified Resource ID.
 *
 * @param resourceName resource name
 * @param resourceId Resource ID
 * @param delegate callback when HTTP response
 */
- (void) delete:(NSString*)resourceName
     resourceId:(NSString*)resourceId
       callback:(id<IPPQueryCallback>)delegate;

@end
