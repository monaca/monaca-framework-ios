//
//  IPPProfileClient.h
//  IPP_RESTKit4iOS
//
//  Created by takazawa on 13/04/22.
//  Copyright (c) 2013年 INNOVATIONPLUS. Inc,. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "IPPDefaultClient.h"

/**
 * IPPProfileClient : REST Client for Profile
 *
 * @author InnovationPlus Inc.
 * @version 0.8.0a
 */
@interface IPPProfileClient : IPPDefaultClient

/**
 * Constructor
 * 
 * @return HTTP Client for access to 'profile' API
 */
- (id) init;

/**
 * retrieve self profile.
 *
 * @param delegate callback when HTTP response
 */
- (void) get:(id<IPPQueryCallback>)delegate;

/**
 * retrieve self profile.
 *
 * @param fields needed fields
 * @param delegate callback when HTTP response
 */
- (void) get:(NSMutableArray*)fields
    callback:(id<IPPQueryCallback>)delegate;

/**
 * retrieve all permitted profiles using application.
 *
 * @param delegate callback when HTTP response
 */
- (void) query:(id<IPPQueryCallback>)delegate;

/**
 * retrieve all permitted profiles using application.
 *
 * @param fields needed fields
 * @param delegate callback when HTTP response
 */
- (void) query:(NSMutableArray*)fields
      callback:(id<IPPQueryCallback>)delegate;

@end
