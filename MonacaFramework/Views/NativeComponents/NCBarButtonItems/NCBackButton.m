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
        _ncStyle = [[NCStyle alloc] initWithComponent:kNCComponentBackButton];
        _type = kNCComponentBackButton;
    }

    return self;
}

- (void)updateUIStyle:(id)value forKey:(NSString *)key
{
    if ([key isEqualToString:kNCStyleText]) {
        if (![_ncStyle checkStyle:value forKey:key]) {
            value = [_ncStyle retrieveStyle:key];
        }
        [self setEnabled:NO];
        if ([value isEqualToString:kNCUndefined]) {
            [self setTitle:@" "];
        } else {
            [self setTitle:value];

        }
        [_ncStyle updateStyle:value forKey:key];
        return;
    }
    [super updateUIStyle:value forKey:key];
}

@end
