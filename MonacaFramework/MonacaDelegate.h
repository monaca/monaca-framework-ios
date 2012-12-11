//
//  MonacaDelegate.h
//  Template
//
//  Created by Hiroki Nakagawa on 11/06/07.
//  Copyright 2011 ASIAL CORPORATION. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MonacaViewController.h"
#import "MonacaNavigationController.h"

@interface MonacaDelegate : NSObject <UIApplicationDelegate, UIWebViewDelegate> {
 @private
    MonacaViewController *viewController_;
    MonacaNavigationController *monacaNavigationController_;
}

- (NSURL *)getBaseURL;
- (UIInterfaceOrientation)currentInterfaceOrientation;
- (NSDictionary *)getApplicationPlist;

// Actually, |viewController| has MonavaViewController object.
@property (nonatomic, readwrite, retain) IBOutlet MonacaViewController *viewController;

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property(nonatomic, retain) MonacaNavigationController *monacaNavigationController;

@end