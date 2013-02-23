//
//  MFUtility.h
//  MonacaFramework
//
//  Created by Yasuhiro Mitsuno on 2013/02/23.
//  Copyright (c) 2013年 ASIAL CORPORATION. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MFUtility : NSObject
{
    
}

+ (NSDictionary *)parseJSONFile:(NSString *)path;
+ (NSURL *)getBaseURL;
+ (NSDictionary *)getApplicationPlist;

@end
