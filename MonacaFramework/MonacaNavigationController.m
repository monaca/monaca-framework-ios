//
//  MonacaNavigationController.m
//  MonacaFramework
//
//  Created by air on 12/06/28.
//  Copyright (c) 2012年 ASIAL CORPORATION. All rights reserved.
//

#import "MonacaNavigationController.h"
#import "MonacaTransitPlugin.h"
#import "Utility.h"

@interface MonacaNavigationController ()

@end

@implementation MonacaNavigationController

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)aInterfaceOrientation
{
    return [Utility getAllowOrientationFromPlist:aInterfaceOrientation];
}

- (void)loadView
{
    [super loadView];
    self.delegate = self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.navigationBarHidden = YES;
    CGRect viewBounds = [[UIScreen mainScreen] applicationFrame];
    self.view.frame = viewBounds;
}

#pragma mark - UINavigationControllerDelegate

- (void)navigationController:(UINavigationController *)navigationController didShowViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    [MonacaTransitPlugin changeDelegate:viewController];
}

@end