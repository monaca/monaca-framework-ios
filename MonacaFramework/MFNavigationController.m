//
//  MonacaNavigationController.m
//  MonacaFramework
//
//  Created by air on 12/06/28.
//  Copyright (c) 2012年 ASIAL CORPORATION. All rights reserved.
//

#import "MFNavigationController.h"
#import "MFViewController.h"
#import "MFTransitPlugin.h"
#import "MFUtility.h"

#import <QuartzCore/QuartzCore.h>


@interface MFNavigationController ()

@end

@implementation MFNavigationController

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)aInterfaceOrientation
{
    return [MFUtility getAllowOrientationFromPlist:aInterfaceOrientation];
}

- (MFViewController *)currentMonacaViewControllerOrNil {
    UIViewController *controller = self.viewControllers.lastObject;
    
    if ([controller isKindOfClass:[MFViewController class]]) {
        return (MFViewController *)controller;
    }
    
    return nil;
}

- (MFViewController *)lastMonacaViewController {
    for (UIViewController *controller in self.viewControllers.reverseObjectEnumerator) {
        if ([controller isKindOfClass:MFViewController.class]) {
            return (MFViewController*)controller;
        }
    }
    
    [NSException raise:@"MFViewControllerNotFound" format:@"MFViewController is not found."];
    return nil;
}

- (MFTabBarController *)lastMonacaTabBarController
{
    return self.lastMonacaViewController.tabBarController;
}

- (void)loadView {
    [super loadView];
    self.delegate = self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationBarHidden = YES;
    CGRect viewBounds = [[UIScreen mainScreen] applicationFrame];
    self.view.frame = viewBounds;
}

#pragma mark - UINavigationControllerDelegate

- (void)navigationController:(UINavigationController *)navigationController didShowViewController:(UIViewController *)viewController animated:(BOOL)animated
{

}


@end