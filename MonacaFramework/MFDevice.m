//
//  Device.m
//  MonacaFramework
//
//  Created by Nakagawa Hiroki on 12/01/10.
//  Copyright (c) 2012年 ASIAL CORPORATION. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MFDevice.h"



@implementation MFDevice



static const float kHeightOfStatusBar              = 20;

static const float kHeightOfPortraitNavigationBar  = 44;
static const float kHeightOfLandscapeNavigationBar = 32;
static const float kHeightOfNavigationBar_iPad     = 44;

static const float kHeightOfPortraitToolBar        = 44;
static const float kHeightOfLandscapeToolBar       = 32;
static const float kHeightOfToolBar_iPad           = 44;

static const float kHeightOfTabBar                 = 49;



+ (BOOL)isiPhone {
    NSString *model = [[UIDevice currentDevice] model];
    return [model isEqualToString:@"iPhone"] || [model isEqualToString:@"iPhone Simulator"];
}

+ (BOOL)isiPodTouch {
    NSString *model = [[UIDevice currentDevice] model];
    return [model isEqualToString:@"iPod touch"];
}

+ (BOOL)isiPad {
    NSString *model = [[UIDevice currentDevice] model];
    return [model isEqualToString:@"iPad"] || [model isEqualToString:@"iPad Simulator"];
}

+ (float)heightOfWindow:(UIInterfaceOrientation)orientation {
    if (UIInterfaceOrientationIsPortrait(orientation)) {
        return CGRectGetHeight([[UIScreen mainScreen] bounds]);
    }
    return CGRectGetWidth([[UIScreen mainScreen] bounds]);
}

+ (float)heightOfStatusBar {
    return kHeightOfStatusBar;
}

+ (float)widthOfWindow:(UIInterfaceOrientation)orientation {
    if (UIInterfaceOrientationIsPortrait(orientation)) {
        return CGRectGetWidth([[UIScreen mainScreen] bounds]);
    }
    return CGRectGetHeight([[UIScreen mainScreen] bounds]);
}

+ (float)heightOfNavigationBar:(UIInterfaceOrientation)orientation {
    if ([MFDevice isiPhone] || [MFDevice isiPodTouch]) {
        if (UIInterfaceOrientationIsPortrait(orientation)) {
            return kHeightOfPortraitNavigationBar;
        }
        return kHeightOfLandscapeNavigationBar;
    } else if ([MFDevice isiPad]) {
        return kHeightOfNavigationBar_iPad;
    }
    return 0;
}

+ (float)heightOfToolBar:(UIInterfaceOrientation)orientation {
    if ([MFDevice isiPhone] || [MFDevice isiPodTouch]) {
        if (UIInterfaceOrientationIsPortrait(orientation)) {
            return kHeightOfPortraitToolBar;
        }
        return kHeightOfLandscapeToolBar;
    } else if ([MFDevice isiPad]) {
        return kHeightOfToolBar_iPad;
    }
    return 0;
}

+ (float)heightOfTabBar {
    return kHeightOfTabBar;
}



+ (NSInteger)iOSVersionMajor {
    NSArray *versions = [[[UIDevice currentDevice] systemVersion] componentsSeparatedByString:@"."];
    return [[versions objectAtIndex:0] intValue];
}

@end
