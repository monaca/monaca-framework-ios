//
//  MFNavigationController.m
//  MonacaFramework
//
//  Created by Yasuhiro Mitsuno on 2013/02/23.
//  Copyright (c) 2013年 ASIAL CORPORATION. All rights reserved.
//

#import "MFNavigationController.h"
#import "MFUtility.h"
#import "NativeComponents.h"

@interface MFNavigationController ()

@end

@implementation MFNavigationController

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    return [MFUtility getAllowOrientationFromPlist:toInterfaceOrientation];
}

- (BOOL)shouldAutorotate
{
    return YES;
}

- (NSUInteger)supportedInterfaceOrientations
{
    UIInterfaceOrientationMask mask = nil;
    if ([MFUtility getAllowOrientationFromPlist:UIInterfaceOrientationPortrait]) {
        mask |= UIInterfaceOrientationMaskPortrait;
    }
    if ([MFUtility getAllowOrientationFromPlist:UIInterfaceOrientationPortraitUpsideDown]){
        mask |= UIInterfaceOrientationMaskPortraitUpsideDown;
    }
    if ([MFUtility getAllowOrientationFromPlist:UIInterfaceOrientationLandscapeRight]){
        mask |= UIInterfaceOrientationMaskLandscapeRight;
    }
    if ([MFUtility getAllowOrientationFromPlist:UIInterfaceOrientationLandscapeLeft]){
        mask |= UIInterfaceOrientationMaskLandscapeLeft;
    }
    return mask;
}

@end
