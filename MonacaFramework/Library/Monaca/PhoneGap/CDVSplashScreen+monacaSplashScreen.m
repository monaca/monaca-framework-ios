//
//  CDVSplashScreen+monacaSplashScreen.m
//  MonacaFramework
//
//  Created by Katsuya Saitou on 12/11/26.
//  Copyright (c) 2012年 ASIAL CORPORATION. All rights reserved.
//

#import "CDVSplashScreen+monacaSplashScreen.h"
#import "MFDelegate.h"
#import "MFViewController.h"
#import "MFUtility.h"

@implementation CDVSplashScreen (monacaSplashScreen)

- (void) __showMonacaSplashScreen:(BOOL)show
{
    // Legacy support - once deprecated classes removed, clean this up
    MFDelegate *delegate = [MFUtility getAppDelegate];
    if ([delegate respondsToSelector:@selector(viewController)]) {
        id vc = [delegate performSelector:@selector(viewController)];
        if ([vc isKindOfClass:[MFViewController class]]) {
            [((MFViewController*)vc) showSplash:show];
        }
    }
}

@end
