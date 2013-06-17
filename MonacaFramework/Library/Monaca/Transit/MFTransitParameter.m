//
//  MFTransitParameter.m
//  MonacaFramework
//
//  Created by yasuhiro on 13/06/17.
//  Copyright (c) 2013年 ASIAL CORPORATION. All rights reserved.
//

#import "MFTransitParameter.h"

@implementation MFTransitParameter

@synthesize target = target_;

- (id)init
{
    self = [super init];
    
    if (self != nil) {
        
    }
    
    return self;
}

#pragma mark - private method

- (void)setTarget:(NSString *)target
{
    target_ = target;
}

#pragma mark private method end -

+ (MFTransitParameter*)parseOptionsDict:(NSDictionary*)options
{
    NSString *target = nil;
    
    // "target" parameter parsing
    {
        id targetParam = [options objectForKey:@"target"];
        if ([targetParam isKindOfClass:NSString.class]) {
            if ([targetParam isEqualToString:@"_parent"] || [targetParam isEqualToString:@"_self"]) {
                target = targetParam;
            }
        } else if (targetParam == nil) {
            target = @"_self";
        }
        if (target == nil) {
            NSLog(@"unkonwn target type: %@", targetParam);
            target = @"_self";
        }
    }
    
    MFTransitParameter *parameter = [[MFTransitParameter alloc] init];
    parameter.target = target;
    
    return parameter;
}
@end
