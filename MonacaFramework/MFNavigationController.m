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
#import "MFDammyViewController.h"

@interface MFNavigationController ()

@end

@implementation MFNavigationController

- (id)init
{
    self = [super init];

    if (self) {
        popFlag = NO;
    }

    return self;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    return [MFUtility getAllowOrientationFromPlist:toInterfaceOrientation];
}

- (BOOL)shouldAutorotate
{
    return YES;
}

- (void)viewWillAppear:(BOOL)animated
{
    NSMutableArray *viewControllers = [NSMutableArray arrayWithArray:self.viewControllers];
    if ([[viewControllers objectAtIndex:0] isKindOfClass:[MFDammyViewController class]] == NO) {
        [viewControllers insertObject:[MFDammyViewController alloc] atIndex:0];
        [self setViewControllers:viewControllers];
    }
}

- (UIViewController *)popViewControllerAnimated:(BOOL)animated
{
    id viewController;
    NSMutableArray *viewControllers = [NSMutableArray arrayWithArray:self.viewControllers];
    if (![[viewControllers objectAtIndex:[viewControllers count]-2] isKindOfClass:[MFDammyViewController class]]) {
        popFlag = YES;
        viewController = [super popViewControllerAnimated:animated];

        return viewController;
    }
    return nil;
}

- (NSArray *)popToRootViewControllerAnimated:(BOOL)animated
{
    NSMutableArray *viewControllers = [NSMutableArray arrayWithArray:self.viewControllers];
    int index = 0;
    if ([viewControllers count] > 1) {
        index = 1;
    }
    popFlag = YES;
    NSArray *_viewControllers = [self popToViewController:[viewControllers objectAtIndex:index] animated:animated];

    return _viewControllers;
}

- (BOOL)navigationBar:(UINavigationBar *)navigationBar shouldPopItem:(UINavigationItem *)item
{
    if (!popFlag) {
        [[(MFViewController *)self.topViewController backButton] didTap:self forEvent:nil];
    } else {
        popFlag = NO;
        return YES;
    }
    return NO;
}

- (void)destroy
{
    for (MFViewController *view in self.viewControllers) {
        [view destroy];
    }
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
