//
//  MyTabBarController.m
//  MonacaFramework
//
//  Created by Yasuhiro Mitsuno on 2012/12/31.
//  Copyright (c) 2012年 ASIAL CORPORATION. All rights reserved.
//


#import "MyTabBarController.h"
#import "MFViewController.h"
#import "MFUtility.h"

@interface MyTabBarController ()

@end

@implementation MyTabBarController

static void
setBackgroundColor(NSArray *components, NCToolbar *toolbar) {
    for (int i = 0; i < [components count]; i++) {
        NSDictionary *style_def = [(NSDictionary *)[components objectAtIndex:i] objectForKey:kNCTypeStyle];
        UIView *view = [[toolbar subviews] objectAtIndex:i];
        
        // Register component's view.
        NSString *cid = [(NSDictionary *)[components objectAtIndex:i] objectForKey:kNCTypeID];
        if (cid) {
            [[MFUtility currentTabBarController].viewDict setObject:view forKey:cid];
        }
        [NCButtonBuilder setUpdatedTag:view];
        
        NSString *bgColor = [style_def objectForKey:kNCStyleBackgroundColor];
        if (bgColor) {
            UIColor *color = hexToUIColor(removeSharpPrefix(bgColor), 1);
            if([view respondsToSelector:@selector(setTintColor:)]){
                [view performSelector:@selector(setTintColor:) withObject:color];
            }
        }
        [view setHidden:isFalse([style_def objectForKey:kNCStyleVisibility])];
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)applyBottomTabbar:(NSDictionary *)uidict WwwDir:(NSString *)wwwDir
{
    NSMutableArray *viewControllers = [NSMutableArray array];
//    NSDictionary *top = [uidict objectForKey:kNCPositionTop];
    NSDictionary *bottom = [uidict objectForKey:kNCPositionBottom];
    NSArray *items = [bottom objectForKey:kNCTypeItems];

    int i = 0;
    for (NSDictionary *item in items) {
        NSMutableDictionary *style = [NSMutableDictionary dictionary];
        [style addEntriesFromDictionary:[item objectForKey:kNCTypeStyle]];
        [style addEntriesFromDictionary:[item objectForKey:kNCTypeIOSStyle]];
        
        // Setup a view controller in the tab contoller.
        MFViewController *viewController = [[MFViewController alloc] initWithFileName:[item objectForKey:kNCTypeLink]];
        viewController.wwwFolderName = wwwDir;
        
        // Setup tabbar item.
        viewController.tabBarItem = [NCTabbarItemBuilder tabbarItem:style];
        viewController.tabBarItem.tag = i;
        
        UINavigationController *navi = [[UINavigationController alloc] initWithRootViewController:viewController];

        [navi setNavigationBarHidden:YES];
        [viewControllers addObject:navi];
        
        // Store a reference to the object representing the native component.
        //        NSString *cid = [item objectForKey:kNCTypeID];
        //        [self.ncManager setComponent:viewController.tabBarItem forID:cid];
        i++;
    }
    self.viewControllers  = viewControllers;
}

@end
