//
//  MFViewBuilder.h
//  MonacaFramework
//
//  Created by Yasuhiro Mitsuno on 2013/04/15.
//  Copyright (c) 2013年 ASIAL CORPORATION. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MFViewBuilder : NSObject
+ (void)setIgnoreBottom:(BOOL)ignore;
+ (void)setWwwDir:(NSString *)wwwDir;
+ (NSString *)getWwwDir;
+ (id)createViewControllerWithPath:(NSString *)path;

@end
