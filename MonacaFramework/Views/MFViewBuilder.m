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
        ignoreBottom_ = YES; // タブバーは再起的に生成させない。
        NSString *containerType = [item objectForKey:kNCTypeContainer];
        if ([containerType isEqualToString:kNCContainerToolbar]) {
            view = [[MFViewController alloc] initWithFileName:[path lastPathComponent]];
            // TODO: Implement applyBottomToolbar on MFViewController
            // [view applyBottomToolbar:uidict];
        } else if ([containerType isEqualToString:kNCContainerTabbar]) {
            view = [[MFTabBarController alloc] init];
            [view applyBottomTabbar:uidict WwwDir:[[MFUtility getWWWShortPath:uipath] stringByDeletingLastPathComponent]];
            [[view moreNavigationController] setNavigationBarHidden:NO];
        }
    } else {
        view = [[MFViewController alloc] initWithFileName:[path lastPathComponent]];
        [view setWwwFolderName:[[MFUtility getWWWShortPath:uipath] stringByDeletingLastPathComponent]];
        [view applyUserInterface:uidict];
        item = [uidict objectForKey:kNCPositionTop];
        if (item != nil || [[item objectForKey:kNCTypeContainer] isEqualToString:kNCContainerToolbar]) {
            [view setExistTop:YES];
        }
    }
    ignoreBottom_ = NO;

    return view;
}

@end