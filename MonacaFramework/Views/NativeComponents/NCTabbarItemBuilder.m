//
//  NCTabbarItemBuilder.m
//  MonacaFramework
//
//  Created by Nakagawa Hiroki on 12/01/10.
//  Copyright (c) 2012年 ASIAL CORPORATION. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NCTabbarItemBuilder.h"

@implementation NCTabbarItemBuilder

static UITabBarItem *
updateTabberItem(UITabBarItem *item, NSDictionary *style) {
    NSString *title = [style objectForKey:kNCStyleText];
    if (title) {
        item.title = title;
    }

    NSString *imageName = [style objectForKey:kNCStyleImage];
    UIImage *image = nil;
    if (imageName) {
        NSURL *appWWWURL = [((MFDelegate *)[[UIApplication sharedApplication] delegate]) getBaseURL];
        NSString *imagePath = [[appWWWURL path] stringByAppendingPathComponent:imageName];
        image = [UIImage imageWithContentsOfFile:imagePath];
        if (image) {
            item.image = image;
        }
    }
    id badgeValue = [style objectForKey:kNCStyleBadgeText];
    if ([badgeValue isKindOfClass:[NSString class]]) {
        if ([badgeValue isEqualToString:@""]) {
            item.badgeValue = nil;
        } else if (badgeValue) {
            item.badgeValue = badgeValue;
        }
    } else if ([badgeValue isKindOfClass:[NSNumber class]]) {
        item.badgeValue = [badgeValue stringValue];
    }
    
    return item;
}

+ (UITabBarItem *)tabbarItem:(NSDictionary *)style {
    UITabBarItem *item = [[UITabBarItem alloc] initWithTitle:nil image:nil tag:0];
    return updateTabberItem(item, style);
}

+ (UITabBarItem *)update:(UITabBarItem *)item with:(NSDictionary *)style {
    return updateTabberItem(item, style);
}

@end
