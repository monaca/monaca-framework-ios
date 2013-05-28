//
//  @File       NSError+IPP.h
//  @Project    IPPDemoApp
//  @brief      IPP Query Error Code
//  @version    1.0.0
//
//  Created by Ken Miyachi on 12/09/18.
//  Copyright (c) 2012 Ken Miyachi. All rights reserved.
//

#import <Foundation/Foundation.h>

/* IPP ERROR CODE DMAIN NAME*/
#define IPP_ERROR_CODE_DMAIN_NAME @"jp.innovationplus.IPPError"

@interface NSError(IPP)
/* errorWithIPPErrorCode */
/*
 * Create IPP Error 
 * @Params
 * int code                : error code of ipp query. 
 *                           if code > 0, the description of NSError is http responce code message,
 *                           else if code < 0, the description of NSError is ipp error message.
 * @Return
 * NSError                 : this NSError has IPP_ERROR_CODE_DMAIN_NAME.
 */
+ (NSError*) errorWithIPPErrorCode:(int)code;
@end
