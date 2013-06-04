//
//  MFViewBuilder.m
//  MonacaFramework
//
//  Created by Yasuhiro Mitsuno on 2013/04/15.
//  Copyright (c) 2013年 ASIAL CORPORATION. All rights reserved.
//

#import "MFViewBuilder.h"
#import "MFUtility.h"
#import "MFDammyViewController.h"
#import "MFUIChecker.h"
#import "MFViewManager.h"

@implementation MFViewBuilder

static BOOL ignoreBottom_ = NO;
static NSString *_wwwDir;

+ (void)setIgnoreBottom:(BOOL)ignore
{
    ignoreBottom_ = ignore;
}

+ (MFNavigationController *)createMonacaNavigationControllerWithWwwDir:(NSString *)wwwDir withPath:(NSString *)path
{
    _wwwDir = wwwDir;
    MFNavigationController *navigationController = [[MFNavigationController alloc] init];
    [navigationController setViewControllers:[NSArray arrayWithObjects:[[MFDammyViewController alloc] init], [MFViewBuilder createViewControllerWithPath:path], nil]];
    
    return navigationController;
}

+ (id)createViewControllerWithPath:(NSString *)path
{
    NSString *fullPath = [_wwwDir stringByAppendingPathComponent:path];
    NSMutableDictionary *uidict = [[MFUtility parseJSONFile:[MFUtility getUIFileName:fullPath]] mutableCopy];
    
    id view;
    id item = [uidict objectForKey:kNCPositionBottom];
    if (!ignoreBottom_ && [[item objectForKey:kNCTypeContainer] isEqualToString:kNCContainerTabbar]) {
        view = [self createTabbarControllerWithPath:fullPath withDict:uidict];
        // moreViewControllerの編集ボタン非表示
        [view setCustomizableViewControllers:nil];
    } else {
        view = [self createMFViewControllerWithPath:fullPath withDict:uidict];
    }

    return view;
}

+ (MFViewController *)createMFViewControllerWithPath:(NSString *)path withDict:(NSMutableDictionary *)uidict
{
    [MFUIChecker checkUI:uidict];
    
    MFViewController *viewController = [[MFViewController alloc] initWithFileName:[path lastPathComponent]];
    [viewController setWwwFolderName:[path stringByDeletingLastPathComponent]];
    [MFViewManager setCurrentWWWFolderName:viewController.wwwFolderName];
    if (ignoreBottom_) {
        [uidict removeObjectForKey:kNCPositionBottom];
    }
    [viewController setUiDict:uidict];
    
    return viewController;
}

+ (MFTabBarController *)createTabbarControllerWithPath:(NSString *)path withDict:(NSDictionary *)uidict
{
    [MFUIChecker checkUI:uidict];
    
    MFTabBarController *tabbarController = [[MFTabBarController alloc] init];
    [MFViewManager setCurrentWWWFolderName:[path stringByDeletingLastPathComponent]];

    NSMutableArray *viewControllers = [NSMutableArray array];
    NSDictionary *bottom = [uidict objectForKey:kNCPositionBottom];
    NSMutableDictionary *bottomStyle = [NSMutableDictionary dictionary];
    [bottomStyle addEntriesFromDictionary:[bottom objectForKey:kNCTypeStyle]];
    [bottomStyle addEntriesFromDictionary:[bottom objectForKey:kNCTypeIOSStyle]];
    NSArray *items = [bottom objectForKey:kNCTypeItems];
    
    int i = 0;
    ignoreBottom_ = YES;
    for (NSDictionary *item in items) {
        NSMutableDictionary *style = [NSMutableDictionary dictionary];
        [style addEntriesFromDictionary:[item objectForKey:kNCTypeStyle]];
        [style addEntriesFromDictionary:[item objectForKey:kNCTypeIOSStyle]];
        
        NSString *link = [item objectForKey:kNCTypeLink];
        
        // Setup a view controller in the tab contoller.
        // TODO: make viewControllerProtocol
        NSString *Path = [[path stringByDeletingLastPathComponent] stringByAppendingPathComponent:link];
        NSMutableDictionary *uiDict = [[MFUtility parseJSONFile:[MFUtility getUIFileName:Path]] mutableCopy];
        MFViewController *viewController = [MFViewBuilder createMFViewControllerWithPath:Path withDict:uiDict];
        
        MFNavigationController *navi = [[MFNavigationController alloc] init];
        [navi setViewControllers:[NSArray arrayWithObjects:[[MFDammyViewController alloc] init], viewController, nil]];
        [viewControllers addObject:navi];

        NCTabbarItem *tabbarItem = [[NCTabbarItem alloc] init];

        [tabbarItem setUserInterface:style];
        [tabbarItem applyUserInterface];
        
        NSString *cid = [item objectForKey:kNCTypeID];
        [tabbarController.ncManager setComponent:tabbarItem forID:cid];
        
        [navi setTabBarItem:tabbarItem];

        i++;
    }
    ignoreBottom_ = NO;
    tabbarController.viewControllers  = viewControllers;
    
    [tabbarController setUserInterface:bottomStyle];
    [tabbarController applyUserInterface];
    NSString *cid = [bottom objectForKey:kNCTypeID];
    [tabbarController.ncManager setComponent:tabbarController forID:cid];

    return tabbarController;
}

@end
