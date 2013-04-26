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
#import "MFJSInterfaceProtocol.h"

@interface MFDelegate : NSObject <UIApplicationDelegate, UIWebViewDelegate> {
 @private
    MFViewController *viewController_;
    MFNavigationController *monacaNavigationController_;
}

- (NSURL *)getBaseURL;
- (UIInterfaceOrientation)currentInterfaceOrientation;
- (NSDictionary *)getApplicationPlist;
- (MFViewController *)lastMonacaViewController;
- (MFViewController *)currentMonacaViewControllerOrNil;

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property(nonatomic, retain) MFNavigationController *monacaNavigationController;

@end