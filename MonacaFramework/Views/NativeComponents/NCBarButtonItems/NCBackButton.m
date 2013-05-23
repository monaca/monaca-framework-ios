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

+ (NSDictionary *)defaultStyles
{
    NSMutableDictionary *defaultStyle = [[NSMutableDictionary alloc] init];
    [defaultStyle setValue:kNCTrue forKey:kNCStyleVisibility];
    [defaultStyle setValue:kNCBlack forKey:kNCStyleBackgroundColor];
    [defaultStyle setValue:kNCWhite forKey:kNCStyleActiveTextColor];
    [defaultStyle setValue:kNCWhite forKey:kNCStyleTextColor];
    [defaultStyle setValue:kNCUndefined forKey:kNCStyleInnerImage];
    [defaultStyle setValue:kNCUndefined forKey:kNCStyleText];
    return defaultStyle;
}

- (id)init {
    self = [super init];

    if (self) {
        _ncStyle = [[NSMutableDictionary alloc] initWithDictionary:[self.class defaultStyles]];
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
