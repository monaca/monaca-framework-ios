//
//  @File       IPPQueryResult.h
//  @Project    IPPDemoApp
//  @brief      Result of IPP Query 
//  @version    1.0.0
//
//  Created by Ken Miyachi on 12/10/09.
//  Copyright (c) 2012 Ken Miyachi. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 * IPPQueryResult : IPP Request Result Core Data Type *Internal Data class
 *
 * @author InnovationPlus Inc.
 * @version 0.8.0a
 */
@interface IPPQueryResult : NSObject

/**
 * result object
 */
@property (strong) id result;                   // query result

/**
 * result code
 */
@property (assign) int resultCode;              // result code

/**
 * result message
 */
@property (strong) NSString* resultMessage;     // result message

/**
 * result count
 */
@property (assign) int resultCount;             // result count

/* initWithResultClass */
/**
 * Initialize IPPQueryResult with result data class
 * @param  klass result data class.
 *               IPP query will return the result as KVC.
 *               so, this input class has every property as keyname.
 * @return IPPQueryResult instance created with input result class.
 *         you can access to result class from IPPQueryResult.result.
 */
- (id)initWithResultClass:(id)klass;

/**
 * description
 *
 * @return description
 */
- (NSString*)description;

@end
