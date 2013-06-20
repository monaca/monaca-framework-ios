//
//  MFTransitParameter.h
//  MonacaFramework
//
//  Created by yasuhiro on 13/06/17.
//  Copyright (c) 2013年 ASIAL CORPORATION. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <QuartzCore/QuartzCore.h>

@interface MFTransitParameter : NSObject {
@protected
    NSString *target_;
}

+ (NSString *)parseTargetParameter:(NSString *)targetParam;
+ (NSString *)detectAnimation:(NSString *)direction;

@property (retain, readonly) NSString *target;

@end
