//
//  NSDictionary+IPP.h
//  IPP_RESTKit4iOS
//
//  Created by takazawa on 13/04/22.
//  Copyright (c) 2013年 INNOVATIONPLUS. Inc,. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NSError+IPP.h"

/**
 * NSDictionary (IPP) : extension for each resource accessor
 *
 */
@interface NSDictionary (IPP)

//----------------------------------------------
// USER API
//----------------------------------------------

/**
 * user.login result - retrieve AuthKey
 */
- (NSString*) login_authKey;


//----------------------------------------------
// PROFILE API
//----------------------------------------------

/**
 * profile.retrieve - retrieve screen name
 */
- (NSString*) profile_screenName;

/**
 * profile.retrieve - retrieve first name
 */
- (NSString*) profile_firstName;

/**
 * profile.retrieve - retrieve last name
 */
- (NSString*) profile_lastName;

/**
 * profile.retrieve - retrieve gender
 */
- (int) profile_gender;

/**
 * profile.retrieve - retrieve birthday(epoch millisec)
 */
- (long long) profile_birth;

/**
 * profile.retrieve - retrieve phone number
 */
- (NSString*) profile_phoneNumber;

//- (IPPAddress*) profile_address;

/**
 * profile.retrieve - retrieve address.zipcode
 */
- (NSString*) profile_address_zipcode;

/**
 * profile.retrieve - retrieve address.state
 */
- (NSString*) profile_address_state;

/**
 * profile.retrieve - retrieve address.city
 */
- (NSString*) profile_address_city;

/**
 * profile.retrieve - retrieve address.street
 */
- (NSString*) profile_address_streetAddress;


//----------------------------------------------
// GEOLOCATION API
//----------------------------------------------

/**
 * geolocation.create - create minimum geolocation instance
 *
 * @param latitude  latitude
 * @param longitude longitude
 */
+ (NSMutableDictionary*) geolocationLatitude:(double)latitude
                            longitude:(double)longitude;

/**
 * geolocation.create - create geolocation instance
 *
 * @param latitude  latitude
 * @param longitude longitude
 * @param altitude  altitude
 * @param accuracy  accuracy
 * @param provider  provider
 * @param timestamp timestamp(epoch millisec)
 */
+ (NSMutableDictionary*) geolocationLatitude:(double)latitude
                            longitude:(double)longitude
                             altitude:(double)altitude
                             accuracy:(double)accuracy
                             provider:(NSString*)provider
                            timestamp:(long long)timestamp;

/**
 * geolocation.query - set condition parameter 'since'
 *
 * @param since compare with resource timestamp
 */
- (void) geolocationQuery_since:(long long)since;

/**
 * geolocation.query - set condition parameter 'until'
 *
 * @param until compare with resource timestamp
 */
- (void) geolocationQuery_until:(long long)until;

/**
 * geolocation.query - set condition parameter 'bound'
 *
 * @param top       left-top latitude
 * @param bottom    right-bottom latitude
 * @param left      left-top longitude
 * @param right     right-bottom longitude
 */
- (void) geolocationQuery_boundTop:(double)top
                            bottom:(double)bottom
                              left:(double)left
                             right:(double)right;

/**
 * geolocation.query - set condition parameter 'radiusSquare' and 'latlon'
 *
 * @param radius    radius of square
 * @param latitude  geopoint of square center
 * @param longitude geopoint of square center
 */
- (void) geolocationQuery_radiusSquare:(int)radius
                        centerLatitude:(double)latitude
                       centerLongitude:(double)longitude;

/**
 * geolocation.query - set condition parameter 'count'
 *
 * @param count number of maximum resources. 0 is unlimited.
 */
- (void) geolocationQuery_count:(int)count;

/**
 * geolocation.query - set condition parameter 'self'. restrict retrieve own resources.
 */
- (void) geolocationQuery_self;

/**
 * geolocation.retrieve/query - retrieve resourceId
 */
- (NSString*) geolocation_resource_id;

/**
 * geolocation.retrieve/query - retrieve latitude
 */
- (double) geolocation_latitude;

/**
 * geolocation.retrieve/query - retrieve longitude
 */
- (double) geolocation_longitude;

/**
 * geolocation.retrieve/query - retrieve altitude
 */
- (double) geolocation_altitude;

/**
 * geolocation.retrieve/query - retrieve accuracy
 */
- (double) geolocation_accuracy;

/**
 * geolocation.retrieve/query - retrieve provider
 */
- (NSString*) geolocation_provider;

/**
 * geolocation.retrieve/query - retrieve timestamp (epoch millisec)
 */
- (long long) geolocation_timestamp;


//----------------------------------------------
// APPLICATION RESOURCE API
//----------------------------------------------

/**
 * application resource.query - set condition parameter 'since'
 *
 * @param since compare with resource timestamp
 */
- (void) applicationresourceQuery_since:(long long)since;

/**
 * application resource.query - set condition parameter 'until'
 *
 * @param until compare with resource timestamp
 */
- (void) applicationresourceQuery_until:(long long)until;

/**
 * application resource.query - set condition parameter 'count'
 *
 * @param count number of maximum resources. 0 is unlimited.
 */
- (void) applicationresourceQuery_count:(int)count;

/**
 * application resource.query - set condition parameter 'self'. restrict retrieve own resources.
 */
- (void) applicationresourceQuery_self;

/**
 * application resource.query - add "EQUALS" expression to query parameter "query".
 *
 * @param fieldName user defined field name
 * @param value     compared value
 */
- (void) applicationresourceQuery_eqField:(NSString*)fieldName
                                withValue:(id)value;

/**
 * application resource.query - add "AND" operator to "query" parameter.
 */
- (void) applicationresourceQuery_and;

/**
 * application resource.retrieve/query - retrieve resourceId
 */
- (NSString*) applicationresource_resource_id;

/**
 * application resource.retrieve/query - retrieve timestamp (epoch millisec)
 */
- (long long) applicationresource_timestamp;

@end
