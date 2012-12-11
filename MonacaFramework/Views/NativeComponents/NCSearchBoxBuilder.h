//
//  NCSearchBoxBuilder.h
//  MonacaFramework
//
//  Created by Hiroki Nakagawa on 11/11/15.
//  Copyright (c) 2011 ASIAL CORPORATION. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NativeComponentsInternal.h"


@interface NCSearchBoxBuilder : NSObject

+ (UISearchBar *)searchBox:(NSDictionary *)style;
+ (UIBarButtonItem *)update:(UIBarButtonItem *)searchBox with:(NSDictionary *)style;
+ (NSMutableDictionary *)retrieve:(UIBarButtonItem *)searchBox;
+ (void)makeWide:(UISearchBar *)searchBox;

@end
