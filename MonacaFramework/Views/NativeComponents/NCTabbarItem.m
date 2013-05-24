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

+ (NSDictionary *)defaultStyles
{
    NSMutableDictionary *defaultStyle = [[NSMutableDictionary alloc] init];
    [defaultStyle setValue:kNCUndefined forKey:kNCStyleText];
    [defaultStyle setValue:kNCUndefined forKey:kNCStyleImage];
    [defaultStyle setValue:kNCUndefined forKey:kNCStyleBadgeText];
    return defaultStyle;
}

- (id)init
{
    self = [super init];

    if (self) {
        _ncStyle = [[self.class defaultStyles] mutableCopy];
    }

    return self;
}

#pragma mark - UIStyleProtocol

- (void)setUserInterface:(NSDictionary *)uidict
{
    for (id key in uidict) { 
        if ([_ncStyle objectForKey:key] == nil)
            continue;
        [_ncStyle setValue:[uidict valueForKey:key] forKey:key];
    }
}

- (void)applyUserInterface
{
    for (id key in [_ncStyle copy]) {
        [self updateUIStyle:[_ncStyle objectForKey:key] forKey:key];
    }
}

- (void)updateUIStyle:(id)value forKey:(NSString *)key
{
    if ([_ncStyle objectForKey:key] == nil) {
        // 例外処理
        return;
    }
    if (value == [NSNull null]) {
        value = nil;
    }
    if ([NSStringFromClass([value class]) isEqualToString:@"__NSCFBoolean"]) {
        if (isFalse(value)) {
            value = kNCFalse;
        } else {
            value = kNCTrue;
        }
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

    if (value == [NSNull null]) {
        value = kNCUndefined;
    }
    [_ncStyle setValue:value forKey:key];
}


- (id)retrieveUIStyle:(NSString *)key
{
    if ([_ncStyle objectForKey:key] == nil) {
        // 例外処理
        return nil;
    }

    return [_ncStyle objectForKey:key];
}

@end
