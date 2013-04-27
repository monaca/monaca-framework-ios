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
        _ncStyle = [[NSMutableDictionary alloc] init];
        [_ncStyle setValue:kNCUndefined forKey:kNCStyleText];
        [_ncStyle setValue:kNCUndefined forKey:kNCStyleImage];
        [_ncStyle setValue:kNCUndefined forKey:kNCStyleBadgeText];
    }

    return self;
}

- (void)applyUserInterface:(NSDictionary *)uidict
{
    for (id key in uidict) {
        [self updateUIStyle:[uidict objectForKey:key] forKey:key];
    }
}

#pragma mark - UIStyleProtocol


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
        UIImage *image = [UIImage imageNamed:imagePath];
        [self setImage:image];
    }
    if ([key isEqualToString:kNCStyleBadgeText]) {
        [self setBadgeValue:value];
    }

    if (value == [NSNull null]) {
        value = nil;
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
