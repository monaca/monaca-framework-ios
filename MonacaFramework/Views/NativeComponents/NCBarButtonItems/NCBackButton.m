//
//  NCBackButton.m
//  MonacaFramework
//
//  Created by Yasuhiro Mitsuno on 2013/04/27.
//  Copyright (c) 2013年 ASIAL CORPORATION. All rights reserved.
//

#import "NCBackButton.h"
#import "NativeComponentsInternal.h"
#import "MFUtility.h"

@implementation NCBackButton

- (id)init {
    self = [super init];

    if (self) {
        _backButton = [UIButton buttonWithType:101];
        self.customView = _backButton;
        _ncStyle = [[NSMutableDictionary alloc] init];
        [_ncStyle setValue:kNCTrue forKey:kNCStyleVisibility];
        [_ncStyle setValue:kNCFalse forKey:kNCStyleDisable];
        [_ncStyle setValue:kNCBlue forKey:kNCStyleActiveTextColor];
        [_ncStyle setValue:kNCWhite forKey:kNCStyleTextColor];
        [_ncStyle setValue:kNCUndefined forKey:kNCStyleText];
        [_ncStyle setValue:kNCUndefined forKey:kNCStyleInnerImage];
    }

    return self;
}

- (void)addTarget:(id)target action:(SEL)action forControlEvents:(UIControlEvents)controlEvents
{
    [_backButton addTarget:target action:action forControlEvents:controlEvents];
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

    if ([key isEqualToString:kNCStyleVisibility]) {
        // TODO: Implement
    }
    if ([key isEqualToString:kNCStyleDisable]) {
        if (isFalse(value)) {
            [_backButton setEnabled:YES];
        } else {
            [_backButton setEnabled:NO];
        }
    }
    if ([key isEqualToString:kNCStyleActiveTextColor]) {
        UIColor *color = hexToUIColor(removeSharpPrefix(value), 1);
        [_backButton setTitleColor:color forState:UIControlStateSelected];
    }
    if ([key isEqualToString:kNCStyleTextColor]) {
        UIColor *color = hexToUIColor(removeSharpPrefix(value), 1);
        [_backButton setTitleColor:color forState:UIControlStateNormal];
    }
    if ([key isEqualToString:kNCStyleText]) {
        [_backButton setTitle:value forState:UIControlStateNormal];
    }
    if ([key isEqualToString:kNCStyleInnerImage]) {
        NSString *imagePath = [[MFUtility currentViewController].wwwFolderName stringByAppendingPathComponent:value];
        UIImage *image = [UIImage imageNamed:imagePath];
        [_backButton setImage:image forState:UIControlStateNormal];
    }

    if (value == nil) {
        value = kNCUndefined;
    }
    [_ncStyle setValue:value forKey:key];
}

@end
