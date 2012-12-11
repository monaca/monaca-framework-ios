//
//  CDVSplashScreen+monacaSplashScreen.m
//  MonacaFramework
//
//  Created by Katsuya Saitou on 12/11/26.
//  Copyright (c) 2012年 ASIAL CORPORATION. All rights reserved.
//

#import "CDVSplashScreen+monacaSplashScreen.h"
#import "MonacaDelegate.h"
#import "MonacaViewController.h"
#import "Utility.h"

@implementation CDVSplashScreen (monacaSplashScreen)

- (void) __showMonacaSplashScreen:(BOOL)show
{
    // Legacy support - once deprecated classes removed, clean this up
    MonacaDelegate *delegate = [Utility getAppDelegate];
    if ([delegate respondsToSelector:@selector(viewController)]) {
        id vc = [delegate performSelector:@selector(viewController)];
        if ([vc isKindOfClass:[MonacaViewController class]]) {
            [((MonacaViewController*)vc) showSplash:show];
        }
    }
}

@end
