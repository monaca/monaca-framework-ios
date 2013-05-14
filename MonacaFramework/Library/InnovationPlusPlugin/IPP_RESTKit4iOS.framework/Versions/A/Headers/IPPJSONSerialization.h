//
//  IPPJSONSerialization.h
//  IPPDemoApp
//
//  Created by Ken Miyachi on 2012/10/30.
//  Copyright (c) 2012年 Ken Miyachi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DebugLog.h"
#import "NSError+IPP.h"
#import "IPPQueryResult.h"

@interface IPPJSONSerialization : NSObject

/* IPPResult JSON Serialization */
/* (NSError*) ippResultJSONSerialization:(NSData*)jsonData toSerialize:(IPPQueryResult*) resultClass */
/*
 * @Params
 * NSData* jsonData                 : JSON data
 * IPPQueryResult* resultClass      : Result of IPP POST query
 * @Return
 * NSError                          : NSError+IPP
 */
+ (NSError*) ippResultJSONSerialization:(NSData*)jsonData toSerialize:(IPPQueryResult*) resultClass;

@end
