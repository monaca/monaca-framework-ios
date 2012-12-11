//
//  NCTabbarItemBuilder.h
//  MonacaFramework
//
//  Created by Nakagawa Hiroki on 12/01/10.
//  Copyright (c) 2012年 ASIAL CORPORATION. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NativeComponentsInternal.h"

@interface NCTabbarItemBuilder : NSObject

+ (UITabBarItem *)tabbarItem:(NSDictionary *)style;
+ (UITabBarItem *)update:(UITabBarItem *)item with:(NSDictionary *)style;

@end
