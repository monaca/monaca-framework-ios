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

- (id)initWithWwwDir:(NSString *)wwwDir
{
    NSString *uipath = [wwwDir stringByAppendingPathComponent:@"index.ui"];
    NSDictionary *uiDict = [MFUtility parseJSONFile:uipath];
    
    id item;
    item = [uiDict objectForKey:kNCPositionBottom];
    if (item != nil) {
        NSString *containerType = [item objectForKey:kNCTypeContainer];
        if ([containerType isEqualToString:kNCContainerToolbar]) {
            
        } else if ([containerType isEqualToString:kNCContainerTabbar]) {
            MFTabBarController *tabBarController = [[MFTabBarController alloc] init];
            [tabBarController applyBottomTabbar:uiDict WwwDir:@"www"];
            [MFUtility setCurrentTabBarController:tabBarController];
            self = [self initWithRootViewController:tabBarController];
            [self setNavigationBarHidden:YES];
            [tabBarController.moreNavigationController setNavigationBarHidden:NO];
        }
    } else {
        item = [uiDict objectForKey:kNCPositionTop];
        if (item != nil) {
            if ([[item objectForKey:kNCTypeContainer] isEqualToString:kNCContainerToolbar]) {
                MFViewController *viewController = [[MFViewController alloc] initWithFileName:@"index.html"];
                viewController.wwwFolderName = @"www";
                self = [self initWithRootViewController:viewController];
            }
            [self setNavigationBarHidden:NO animated:NO];
        } else {
            [self setNavigationBarHidden:YES animated:NO];
            [MFViewController setWantsFullScreenLayout:NO];
        }
        [self setToolbarHidden:YES animated:NO];
        [self setToolbarItems:nil];
    }
    return self;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    return YES;
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

- (void)pushViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    [super pushViewController:viewController animated:animated];
}

- (UIViewController *)popViewControllerAnimated:(BOOL)animated
{
    return [super popViewControllerAnimated:animated];
}

- (void)navigationController:(UINavigationController *)navigationController
       didShowViewController:(UIViewController *)viewController animated:(BOOL)animated
{

}

@end
