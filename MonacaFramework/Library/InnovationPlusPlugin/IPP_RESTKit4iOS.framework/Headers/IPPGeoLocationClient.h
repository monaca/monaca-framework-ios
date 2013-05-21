//
//  IPPGeoLocationClient.h
//  IPP_RESTKit4iOS
//
//  Created by takazawa on 13/04/22.
//  Copyright (c) 2013年 INNOVATIONPLUS. Inc,. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "IPPDefaultClient.h"

/**
 * IPPGeoLocationClient : REST Client for GeoLocation
 *
 * @author InnovationPlus Inc.
 * @version 0.8.0a
 */
@interface IPPGeoLocationClient : IPPDefaultClient

/**
 * Constructor
 *
 * @return HTTP Client for access to 'geolocation' API
 */
- (id) init;

/**
 * create new resource.
 *
 * @param geolocation geolocation resource
 * @param delegate callback when HTTP response
 */
- (void) create:(NSMutableDictionary*)geolocation
       callback:(id<IPPQueryCallback>)delegate;

/**
 * create new resources.
 *
 * @param geolocations geolocation resource array
 * @param delegate callback when HTTP response
 */
- (void) createAll:(NSMutableArray*)geolocations
          callback:(id<IPPQueryCallback>)delegate;

/**
 * retrieve last created resource.
 *
 * @param delegate callback when HTTP
 */
- (void) get:(id<IPPQueryCallback>)delegate;

/**
 * retrieve resource specified Resource ID.
 *
 * @param resourceId resource ID
 * @param delegate callback when HTTP response
 */
- (void) get:(NSString*)resourceId
    callback:(id<IPPQueryCallback>)delegate;

/**
 * query any resources.
 *
 * @param condition query condition
 * @param delegate callback when HTTP response
 */
- (void) query:(NSMutableDictionary*)condition
      callback:(id<IPPQueryCallback>)delegate;

/**
 * delete resource specified Resource ID.
 *
 * @param resourceId Resource ID
 * @param delegate callback when HTTP response
 */
- (void) delete:(NSString*)resourceId
       callback:(id<IPPQueryCallback>)delegate;

@end
