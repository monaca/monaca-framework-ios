//
//  MFViewBuilder.m
//  MonacaFramework
//
//  Created by Yasuhiro Mitsuno on 2013/04/15.
//  Copyright (c) 2013年 ASIAL CORPORATION. All rights reserved.
//

#import "MFViewBuilder.h"
#import "MFUtility.h"

@implementation MFViewBuilder

static BOOL ignoreBottom_ = NO;
static NSString *_wwwDir;

+ (void)setIgnoreBottom:(BOOL)ignore
{
    ignoreBottom_ = ignore;
}

+ (void)setWwwDir:(NSString *)wwwDir
{
    _wwwDir = wwwDir;
}

+ (NSString *)getWwwDir;
{
    return _wwwDir;
}

+ (id)createViewControllerWithPath:(NSString *)path
{
    NSString *uipath = [_wwwDir stringByAppendingPathComponent:[MFUtility getUIFileName:path]];
    NSMutableDictionary *uidict = [NSMutableDictionary dictionaryWithDictionary:[MFUtility parseJSONFile:uipath]];

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
        NSString *uipath = [[uiPath stringByDeletingLastPathComponent] stringByAppendingPathComponent:[MFUtility getUIFileName:link]];
        NSDictionary *uiDict = [MFUtility parseJSONFile:uipath];
        
        // Setup a view controller in the tab contoller.
        // TODO: make viewControllerProtocol
        id viewController;
        viewController = [MFViewBuilder createViewControllerWithPath:[[path stringByDeletingLastPathComponent] stringByAppendingPathComponent:[item objectForKey:kNCTypeLink]]];
        
        NSDictionary *top = [uiDict objectForKey:kNCPositionTop];
        NSDictionary *topStyle = [top objectForKey:kNCTypeStyle];
        
        MFNavigationController *navi = [[MFNavigationController alloc] initWithRootViewController:viewController];
        [viewControllers addObject:navi];
        
        [MFUtility setCurrentViewController:viewController]; // for tabbarItem image
        NCTabbarItem *tabbarItem = [[NCTabbarItem alloc] init];
        [tabbarItem applyUserInterface:style];
        NSString *cid = [item objectForKey:kNCTypeID];
        [tabbarController.ncManager setComponent:tabbarItem forID:cid];
        
        [navi setTabBarItem:tabbarItem];
        
        if (top != nil) {
            [navi setNavigationBarHidden:NO];
        } else {
            [navi setNavigationBarHidden:YES];
        }
        i++;
    }
    tabbarController.viewControllers  = viewControllers;
    
    [tabbarController applyUserInterface:bottomStyle];
    NSString *cid = [bottom objectForKey:kNCTypeID];
    [tabbarController.ncManager setComponent:tabbarController forID:cid];

    return tabbarController;
}

@end