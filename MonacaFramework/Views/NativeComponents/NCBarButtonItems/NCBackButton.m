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
        _ncStyle = [[NSMutableDictionary alloc] init];
        [_ncStyle setValue:kNCTrue forKey:kNCStyleVisibility];
        [_ncStyle setValue:kNCBlack forKey:kNCStyleBackgroundColor];
        [_ncStyle setValue:kNCWhite forKey:kNCStyleActiveTextColor];
        [_ncStyle setValue:kNCWhite forKey:kNCStyleTextColor];
        [_ncStyle setValue:kNCUndefined forKey:kNCStyleInnerImage];
        [_ncStyle setValue:kNCUndefined forKey:kNCStyleText];
    }

    return self;
}

- (void)updateUIStyle:(id)value forKey:(NSString *)key
{
    if ([key isEqualToString:kNCStyleText]) {
        if ([value isEqualToString:kNCUndefined]) {
            [self setTitle:@" "];
        } else {
            [self setTitle:value];

        }
        [_ncStyle setValue:value forKey:key];
        return;
    }
    [super updateUIStyle:value forKey:key];
}

@end
