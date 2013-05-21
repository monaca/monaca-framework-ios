//
//  IPPDefaultClient.h
//  IPP_RESTKit4iOS
//
//  Created by takazawa on 13/04/17.
//  Copyright (c) 2013年 INNOVATIONPLUS. Inc,. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "IPPRESTKit.h"
#import "NSDictionary+IPP.h"

/**
 * IPPQueryCallback : XXXXClient method callback protocol
 *
 * @author InnovationPlus Inc.
 * @version 0.8.0a
 */
@protocol IPPQueryCallback <NSObject>

/**
 * request success
 *
 * @param result Each request result
 */
- (void)ippDidFinishLoading:(id)result;

/**
 * request failure
 *
 * @param code IPPConstants.IPP_ERROR_CODE
 */
- (void)ippDidError:(int)code;

@end


/**
 * IPPDefaultClient : common HTTP/REST interface for XXXXClient
 *
 * @author InnovationPlus Inc.
 * @version 0.8.0a
 */
@interface IPPDefaultClient : IPPRESTKit <IPPRESTDelegate>
{
    /**
     * expected class of result
     */
    Class resourceClass;
    
    /**
     * received raw data
     */
    NSMutableData* recieveData;
    
    /**
     * delegate of HTTP connection completed or failed
     */
    id<IPPQueryCallback> ippCallback;
}
@end
