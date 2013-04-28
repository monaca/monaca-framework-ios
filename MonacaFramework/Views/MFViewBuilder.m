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
    NSString *uipath = [[MFUtility getBaseURL].path stringByAppendingPathComponent:[MFUtility getUIFileName:path]];
    NSMutableDictionary *uidict = [NSMutableDictionary dictionaryWithDictionary:[MFUtility parseJSONFile:uipath]];

    id view;
    if (ignoreBottom_) {
        [uidict removeObjectForKey:kNCPositionBottom];
    }
    id item = [uidict objectForKey:kNCPositionBottom];
    NSString *containerType = [item objectForKey:kNCTypeContainer];
    if ([containerType isEqualToString:kNCContainerTabbar]) {
        ignoreBottom_ = YES; // タブバーは再起的に生成させない。
        if ([containerType isEqualToString:kNCContainerTabbar]) {
            view = [[MFTabBarController alloc] init];
            [view applyBottomTabbar:uidict WwwDir:[[MFUtility getWWWShortPath:uipath] stringByDeletingLastPathComponent]];
        }
        ignoreBottom_ = NO;
    } else {
        view = [[MFViewController alloc] initWithFileName:[path lastPathComponent]];
        [view setWwwFolderName:[[MFUtility getWWWShortPath:uipath] stringByDeletingLastPathComponent]];
        [view setUiDict:uidict];
    }

    return view;
}

@end