//
//  MFTransitParameter.m
//  MonacaFramework
//
//  Created by yasuhiro on 13/06/17.
//  Copyright (c) 2013年 ASIAL CORPORATION. All rights reserved.
//

#import "MFTransitParameter.h"
#import "MFUtility.h"
#import "MFViewManager.h"

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

+ (NSString *)detectAnimation:(NSString *)direction
{
    if ([MFViewManager isTabbarControllerTop])
        return direction;
    
    NSString *animation;
    UIInterfaceOrientation interfaceOrientaion = [MFUtility currentInterfaceOrientation];
    if ([direction isEqualToString:kCATransitionFromTop]) {
        if (interfaceOrientaion == UIInterfaceOrientationPortrait) {
            animation = kCATransitionFromTop;
        } else if (interfaceOrientaion == UIInterfaceOrientationPortraitUpsideDown) {
            animation = kCATransitionFromBottom;
        } else if (interfaceOrientaion == UIInterfaceOrientationLandscapeLeft) {
            animation = kCATransitionFromRight;
        } else if (interfaceOrientaion == UIInterfaceOrientationLandscapeRight) {
            animation = kCATransitionFromLeft;
        }
    } else if ([direction isEqualToString:kCATransitionFromLeft]) {
        if (interfaceOrientaion == UIInterfaceOrientationPortrait) {
            animation = kCATransitionFromLeft;
        } else if (interfaceOrientaion == UIInterfaceOrientationPortraitUpsideDown) {
            animation = kCATransitionFromRight;
        } else if (interfaceOrientaion == UIInterfaceOrientationLandscapeLeft) {
            animation = kCATransitionFromTop;
        } else if (interfaceOrientaion == UIInterfaceOrientationLandscapeRight) {
            animation = kCATransitionFromBottom;
        }
    } else if ([direction isEqualToString:kCATransitionFromRight]) {
        if (interfaceOrientaion == UIInterfaceOrientationPortrait) {
            animation = kCATransitionFromRight;
        } else if (interfaceOrientaion == UIInterfaceOrientationPortraitUpsideDown) {
            animation = kCATransitionFromLeft;
        } else if (interfaceOrientaion == UIInterfaceOrientationLandscapeLeft) {
            animation = kCATransitionFromBottom;
        } else if (interfaceOrientaion == UIInterfaceOrientationLandscapeRight) {
            animation = kCATransitionFromTop;
        }
    }
    
    return animation;
}

+ (NSString *)parseTargetParameter:(NSString *)targetParam
{
    NSString *target = nil;
    
    // "target" parameter parsing
    {
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
    
    return target;
}
@end
