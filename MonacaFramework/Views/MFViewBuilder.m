//
//  MFViewBuilder.m
//  MonacaFramework
//
//  Created by Yasuhiro Mitsuno on 2013/04/15.
//  Copyright (c) 2013年 ASIAL CORPORATION. All rights reserved.
//

#import "MFViewBuilder.h"
#import "MFUtility.h"
#import "MFDummyViewController.h"
#import "MFUIChecker.h"
#import "MFViewManager.h"

@implementation MFViewBuilder

static NSString *_wwwDir;

+ (MFNavigationController *)createMonacaNavigationControllerWithWwwDir:(NSString *)wwwDir withPath:(NSString *)path
{
    _wwwDir = wwwDir;
    MFNavigationController *navigationController = [[MFNavigationController alloc] init];
    [navigationController setViewControllers:[NSArray arrayWithObjects:[[MFDummyViewController alloc] init], [MFViewBuilder createViewControllerWithPath:path], nil]];
    [navigationController setNavigationBarHidden:YES];
    
    return navigationController;
}

+ (id)createViewControllerWithPath:(NSString *)path
{
    NSString *fullPath = [_wwwDir stringByAppendingPathComponent:path];
    NSMutableDictionary *uidict = [[MFUtility parseJSONFile:[MFUtility getUIFileName:fullPath]] mutableCopy];
    
    id view;
    id item = [uidict objectForKey:kNCPositionBottom];
    if ([[item objectForKey:kNCTypeContainer] isEqualToString:kNCContainerTabbar]) {
        view = [self createTabbarControllerWithPath:fullPath withDict:uidict];
        // moreViewControllerの編集ボタン非表示
        [[view moreNavigationController] setNavigationBarHidden:YES];
        [view setCustomizableViewControllers:nil];
    } else {
        view = [self createMFViewControllerWithPath:fullPath withDict:uidict];
        [MFViewManager setCurrentWWWFolderName:[view wwwFolderName]];
    }

    return view;
}

+ (MFViewController *)createMFViewControllerWithPath:(NSString *)path withDict:(NSMutableDictionary *)uidict
{
    [MFUIChecker checkUI:uidict];
    
    MFViewController *viewController = [[MFViewController alloc] initWithFileName:[path lastPathComponent]];
    [viewController setWwwFolderName:[path stringByDeletingLastPathComponent]];
    [viewController setStartWwwFolder:[path stringByDeletingLastPathComponent]];
    [viewController setUiDict:uidict];
    
    return viewController;
}

+ (MFTabBarController *)createTabbarControllerWithPath:(NSString *)path withDict:(NSDictionary *)uidict
{
    [MFUIChecker checkUI:uidict];
    
    MFTabBarController *tabbarController = [[MFTabBarController alloc] init];
    [tabbarController setUidict:uidict];
    [MFViewManager setCurrentWWWFolderName:[path stringByDeletingLastPathComponent]];


    NSMutableArray *viewControllers = [NSMutableArray array];
    NSDictionary *top = [uidict objectForKey:kNCPositionTop];
    NSDictionary *bottom = [uidict objectForKey:kNCPositionBottom];
    NSMutableDictionary *topStyle = [NSMutableDictionary dictionary];
    NSMutableDictionary *bottomStyle = [NSMutableDictionary dictionary];
    [topStyle addEntriesFromDictionary:[top objectForKey:kNCTypeStyle]];
    [topStyle addEntriesFromDictionary:[top objectForKey:kNCTypeIOSStyle]];
    [bottomStyle addEntriesFromDictionary:[bottom objectForKey:kNCTypeStyle]];
    [bottomStyle addEntriesFromDictionary:[bottom objectForKey:kNCTypeIOSStyle]];
    NSArray *items = [bottom objectForKey:kNCTypeItems];
    
    int i = 0;
    for (NSDictionary *item in items) {
        NSMutableDictionary *style = [NSMutableDictionary dictionary];
        [style addEntriesFromDictionary:[item objectForKey:kNCTypeStyle]];
        [style addEntriesFromDictionary:[item objectForKey:kNCTypeIOSStyle]];
        
        NSString *link = [item objectForKey:kNCTypeLink];
        
        // Setup a view controller in the tab contoller.
        // TODO: make viewControllerProtocol
        NSString *Path = [[path stringByDeletingLastPathComponent] stringByAppendingPathComponent:link];
        MFViewController *viewController = [MFViewBuilder createMFViewControllerWithPath:Path withDict:[uidict mutableCopy]];

//        [viewController setWantsFullScreenLayout:YES];
        [viewControllers addObject:viewController];

        NCTabbarItem *tabbarItem = [[NCTabbarItem alloc] init];

        [tabbarItem setUserInterface:style];
        [tabbarItem applyUserInterface];
        
        NSString *cid = [item objectForKey:kNCTypeID];
        [tabbarController.ncManager setComponent:tabbarItem forID:cid];
        
        [viewController setTabBarItem:tabbarItem];

        i++;
    }
    tabbarController.viewControllers  = viewControllers;
    
    [tabbarController setUserInterface:bottomStyle];
    [tabbarController applyUserInterface];
    NSString *cid = [bottom objectForKey:kNCTypeID];
    [tabbarController.ncManager setComponent:tabbarController forID:cid];

    return tabbarController;
}

@end
