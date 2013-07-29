//
//  MFDelegate.h
//  Template
//
//  Created by Hiroki Nakagawa on 11/06/07.
//  Copyright 2011 ASIAL CORPORATION. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MFViewController.h"
#import "MFNavigationController.h"

@interface MFDelegate : NSObject <UIApplicationDelegate, UIWebViewDelegate> {
 @private
    MFNavigationController *monacaNavigationController_;
}

- (UIInterfaceOrientation)currentInterfaceOrientation;

@property (nonatomic, retain) UIWindow *window;
@property (nonatomic, retain) MFNavigationController *monacaNavigationController;

@end