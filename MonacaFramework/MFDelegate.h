//
//  MFDelegate.h
//  Template
//
//  Created by Hiroki Nakagawa on 11/06/07.
//  Copyright 2011 ASIAL CORPORATION. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MFViewController.h"

@interface MFDelegate : NSObject <UIApplicationDelegate, UIWebViewDelegate> {
 @private
    MFViewController *viewController_;
}

@property (nonatomic, readwrite, retain) MFViewController *viewController;

@property (nonatomic, retain) IBOutlet UIWindow *window;

@end