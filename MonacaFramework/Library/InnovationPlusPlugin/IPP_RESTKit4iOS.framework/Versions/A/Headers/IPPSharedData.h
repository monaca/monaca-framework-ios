//
//  IPPSharedData.h
//  IPPDemoApp
//
//  Created by Ken Miyachi on 2012/10/15.
//  Copyright (c) 2012年 Ken Miyachi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "IPPRESTKit.h"
#import "NSError+IPP.h"
#import "DebugLog.h"

@interface IPPSharedData : NSObject

/* Get shared instance */
+ (IPPSharedData*)sharedInstance;

/* Shared data store */
@property (nonatomic,retain) NSMutableDictionary* shared;

@end
