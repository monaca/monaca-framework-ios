//
//  NCTabbarItem.m
//  MonacaFramework
//
//  Created by Yasuhiro Mitsuno on 2013/04/27.
//  Copyright (c) 2013年 ASIAL CORPORATION. All rights reserved.
//

#import "NCTabbarItem.h"
#import "NativeComponentsInternal.h"
#import "MFUtility.h"

@implementation NCTabbarItem

- (id)init
{
    self = [super init];

    if (self) {
        _ncStyle = [[NCStyle alloc] initWithComponent:kNCComponentTabbarItem];
    }

    return self;
}

#pragma mark - UIStyleProtocol

- (void)setUserInterface:(NSDictionary *)uidict
{
    [_ncStyle setStyles:uidict];
}

- (void)applyUserInterface
{
    for (id key in [_ncStyle styles]) {
        [self updateUIStyle:[[_ncStyle styles] objectForKey:key] forKey:key];
    }
}

- (void)updateUIStyle:(id)value forKey:(NSString *)key
{
    if (![_ncStyle checkStyle:value forKey:key]) {
        return;
    }

    if ([key isEqualToString:kNCStyleText]) {
        [self setTitle:value];
    }
    if ([key isEqualToString:kNCStyleImage]) {
        NSString *imagePath = [[MFUtility currentViewController].wwwFolderName stringByAppendingPathComponent:value];
        UIImage *image = [UIImage imageWithContentsOfFile:imagePath];
        [self setImage:image];
    }
    if ([key isEqualToString:kNCStyleBadgeText]) {
        if ([value isEqualToString:kNCUndefined]) {
            [self setBadgeValue:nil];
        } else {
            [self setBadgeValue:value];
        }
    }

    [_ncStyle updateStyle:value forKey:key];
}


- (id)retrieveUIStyle:(NSString *)key
{
    return [_ncStyle retrieveStyle:key];
}

@end
