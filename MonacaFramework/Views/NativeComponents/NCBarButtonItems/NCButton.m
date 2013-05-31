//
//  NCButton.m
//  8Card
//
//  Created by KUBOTA Mitsunori on 12/05/30.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "NCButton.h"
#import "NativeComponentsInternal.h"
#import "MFUtility.h"

@implementation NCButton

- (id)init {
    self = [super init];
    
    if (self) {
        [self setTitle:@""];
        _ncStyle = [[NCStyle alloc] initWithComponent:kNCComponentButton];
    }
    
    return self;
}

#pragma mark - UIStyleProtocol

- (void)updateUIStyle:(id)value forKey:(NSString *)key
{
    if (![_ncStyle checkStyle:value forKey:key]) {
        return;
    }

    if ([key isEqualToString:kNCStyleVisibility]) {
        _hidden = isFalse(value);
        [_toolbar applyVisibility];
    }
    if ([key isEqualToString:kNCStyleDisable]) {
        if (isFalse(value)) {
            [self setEnabled:YES];
        } else {
            [self setEnabled:NO];
        }
    }
    if ([key isEqualToString:kNCStyleBackgroundColor]) {
        [self setTintColor:hexToUIColor(removeSharpPrefix(value), 1)];
    }
    if ([key isEqualToString:kNCStyleActiveTextColor]) {
        UIColor *color = hexToUIColor(removeSharpPrefix(value), 1);
        NSDictionary *attributes = [NSDictionary dictionaryWithObjectsAndKeys:color, UITextAttributeTextColor, nil];
        [self setTitleTextAttributes:attributes forState:UIControlStateHighlighted];
    }
    if ([key isEqualToString:kNCStyleTextColor]) {
        UIColor *color = hexToUIColor(removeSharpPrefix(value), 1);
        NSDictionary *attributes = [NSDictionary dictionaryWithObjectsAndKeys:color, UITextAttributeTextColor, nil];
        [self setTitleTextAttributes:attributes forState:UIControlStateNormal];
    }
    if ([key isEqualToString:kNCStyleImage]) {
        // TODO: check
    }
    if ([key isEqualToString:kNCStyleInnerImage]) {
        NSString *imagePath = [[MFUtility currentViewController].wwwFolderName stringByAppendingPathComponent:value];
        UIImage *image = [UIImage imageWithContentsOfFile:imagePath];
        [self setImage:image];
        if (image) {
            // innerImageを設定するさいにはtitleをnilにしないとサイズがおかしくなる．
            [self setTitle:nil];
        }
    }
    if ([key isEqualToString:kNCStyleText]) {
        [self setTitle:value];
    }

    [_ncStyle updateStyle:value forKey:key];
}

@end
