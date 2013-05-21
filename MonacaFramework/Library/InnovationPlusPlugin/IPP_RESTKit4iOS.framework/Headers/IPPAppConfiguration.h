//
//  IPPAppConfiguration.h
//  IPPDemoApp
//
//  Created by Ken Miyachi on 2012/10/30.
//  Copyright (c) 2012年 Ken Miyachi. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface IPPAppConfiguration : NSObject

+ (NSString*) getConfiguration:(NSString*)keyname;

+ (NSString*) getConfigurationClassName:(NSString*)keyname;

+ (void) setConfiguration:(id)value forKeyname:(NSString*)keyname;

+ (void) synchronize;

@end
