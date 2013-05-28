//
//  NCSegmentBuilder.h
//  MonacaFramework
//
//  Created by Nakagawa Hiroki on 11/11/22.
//  Copyright (c) 2011年 ASIAL CORPORATION. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NativeComponents.h"

@interface NCSegmentBuilder : NSObject

+ (UISegmentedControl *)segment:(NSDictionary *)dict;
+ (UIBarButtonItem *)update:(UIBarButtonItem *)segment with:(NSDictionary *)style;

@end
