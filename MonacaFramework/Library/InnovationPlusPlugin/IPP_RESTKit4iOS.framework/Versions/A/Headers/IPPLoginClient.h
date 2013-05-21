//
//  IPPLoginClient.h
//  IPP_RESTKit4iOS
//
//  Created by takazawa on 13/04/17.
//  Copyright (c) 2013年 INNOVATIONPLUS. Inc,. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "IPPDefaultClient.h"

/**
 * IPPLoginClient : Login Client
 *
 * @author InnovationPlus Inc.
 * @version 0.8.0a
 */
@interface IPPLoginClient : IPPDefaultClient

/**
 * Constructor
 *
 * @return HTTP Client for access to 'user' API
 */
- (id) init;

/**
 * Login
 *
 * @param username usename
 * @param password password
 * @param delegate callback when HTTP response
 */
- (void) login:(NSString*)username
  withPassword:(NSString*)password
      callback:(id<IPPQueryCallback>)delegate;

@end
