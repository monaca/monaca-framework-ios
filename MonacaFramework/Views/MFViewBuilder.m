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
    NSString *uipath = [_wwwDir stringByAppendingPathComponent:[MFUtility getUIFileName:path]];
    NSMutableDictionary *uidict = [NSMutableDictionary dictionaryWithDictionary:[MFUtility parseJSONFile:uipath]];
    
    [MFUIChecker checkUI:uidict];
    
    id view;
    if (ignoreBottom_) {
        [uidict removeObjectForKey:kNCPositionBottom];
    }
    id item = [uidict objectForKey:kNCPositionBottom];
    NSString *containerType = [item objectForKey:kNCTypeContainer];
    if ([containerType isEqualToString:kNCContainerTabbar]) {
        ignoreBottom_ = YES; // タブバーは再起的に生成させない。
        view = [self createTabbarControllerWithPath:path];
        // moreViewControllerの編集ボタン非表示
        [view setCustomizableViewControllers:nil];
        ignoreBottom_ = NO;
    } else {
        view = [[MFViewController alloc] initWithFileName:[path lastPathComponent]];
        [view setWwwFolderName:[uipath stringByDeletingLastPathComponent]];
        [view setUiDict:uidict];
//               [view setUserInterface:uidict];
    }

    return view;
}

+ (MFTabBarController *)createTabbarControllerWithPath:(NSString *)path
{
    NSString *uiPath = [_wwwDir stringByAppendingPathComponent:[MFUtility getUIFileName:path]];
    NSDictionary *uidict = [NSDictionary dictionaryWithDictionary:[MFUtility parseJSONFile:uiPath]];

    MFTabBarController *tabbarController = [[MFTabBarController alloc] init];
    
    NSMutableArray *viewControllers = [NSMutableArray array];
    NSDictionary *bottom = [uidict objectForKey:kNCPositionBottom];
    NSDictionary *bottomStyle = [bottom objectForKey:kNCTypeStyle];
    NSArray *items = [bottom objectForKey:kNCTypeItems];
    
    int i = 0;
    for (NSDictionary *item in items) {
        NSMutableDictionary *style = [NSMutableDictionary dictionary];
        [style addEntriesFromDictionary:[item objectForKey:kNCTypeStyle]];
        [style addEntriesFromDictionary:[item objectForKey:kNCTypeIOSStyle]];
        
        NSString *link = [item objectForKey:kNCTypeLink];
        
        // Setup a view controller in the tab contoller.
        // TODO: make viewControllerProtocol
        MFViewController *viewController = [MFViewBuilder createViewControllerWithPath:[[path stringByDeletingLastPathComponent] stringByAppendingPathComponent:link]];
        
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
    tabbarController.viewControllers  = viewControllers;
    
    [tabbarController setUserInterface:bottomStyle];
    [tabbarController applyUserInterface];
    NSString *cid = [bottom objectForKey:kNCTypeID];
    [tabbarController.ncManager setComponent:tabbarController forID:cid];

    return tabbarController;
}

@end
