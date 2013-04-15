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

+ (void)setIgnoreBottom:(BOOL)ignore
{
    ignoreBottom_ = ignore;
}

+ (id)createViewControllerWithPath:(NSString *)path
{
    NSString *www = [[MFUtility getBaseURL].path stringByAppendingPathComponent:@"www"];
    NSString *uipath = [www stringByAppendingPathComponent:[MFUtility getUIFileName:path]];
    NSDictionary *uidict = [MFUtility parseJSONFile:uipath];

    id view;
    id item = [uidict objectForKey:kNCPositionBottom];
    if (item != nil && !ignoreBottom_) {
        NSString *containerType = [item objectForKey:kNCTypeContainer];
        if ([containerType isEqualToString:kNCContainerToolbar]) {
            view = [[MFTabBarController alloc] init];
            [view applyBottomToolbar:uidict];
        } else if ([containerType isEqualToString:kNCContainerTabbar]) {
            view = [[MFTabBarController alloc] init];
            [view applyBottomTabbar:uidict WwwDir:[[MFUtility getWWWShortPath:uipath] stringByDeletingLastPathComponent]];
            [((MFTabBarController *)view).moreNavigationController setNavigationBarHidden:NO];
        }
    } else {
        item = [uidict objectForKey:kNCPositionTop];
        if (item != nil) {
            if ([[item objectForKey:kNCTypeContainer] isEqualToString:kNCContainerToolbar]) {
                view = [[MFViewController alloc] initWithFileName:[path lastPathComponent]];
                ((MFViewController *)view).wwwFolderName = [[MFUtility getWWWShortPath:uipath] stringByDeletingLastPathComponent];
                ((MFViewController *)view).existTop = YES;
            }
        } else {
            view = [[MFViewController alloc] initWithFileName:[path lastPathComponent]];
            ((MFViewController *)view).wwwFolderName = [[MFUtility getWWWShortPath:uipath] stringByDeletingLastPathComponent];
        }
    }
    ignoreBottom_ = NO;

    return view;
}

@end
