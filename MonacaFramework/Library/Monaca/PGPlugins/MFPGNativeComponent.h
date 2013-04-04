//
//  MFPGNativeComponent.h
//  MonacaFramework
//
//  Created by Nakagawa Hiroki on 11/12/09.
//  Copyright (c) 2011年 ASIAL CORPORATION. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "CDVPlugin.h"

//
// Interface of Monaca native component for PhoneGap plugin.
//
@interface MFPGNativeComponent : CDVPlugin

+ (void)initDefaultList;
+ (NSString *)searchDefaultValue:(NSString *)key;

//- (void)badge:(NSMutableArray *)arguments withDict:(NSDictionary *)options;
- (void)update:(NSMutableArray *)arguments withDict:(NSDictionary *)options;
- (void)retrieve:(NSMutableArray *)arguments withDict:(NSDictionary *)options;

@end
