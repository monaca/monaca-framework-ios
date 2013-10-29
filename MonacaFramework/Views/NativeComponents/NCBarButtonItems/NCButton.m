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
#import "MFViewManager.h"

@implementation NCButton

- (id)init {
    self = [super init];
    
    if (self) {
        [self setTitle:@""];
        _ncStyle = [[NCStyle alloc] initWithComponent:kNCComponentButton];
        _type = kNCComponentButton;
    }
    
    return self;
}

#pragma mark - UIStyleProtocol

- (void)updateUIStyle:(id)value forKey:(NSString *)key
{
    if (![_ncStyle checkStyle:value forKey:key]) {
        return;
    }
    
    if (value == [NSNull null]) {
        value = kNCUndefined;
    }
    if ([NSStringFromClass([[_ncStyle.styles valueForKey:key] class]) isEqualToString:@"__NSCFBoolean"]) {
        if (isFalse(value)) {
            value = kNCFalse;
        } else {
            value = kNCTrue;
        }
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

    if ([key isEqualToString:kNCStyleBackgroundColor] && [MFDevice iOSVersionMajor] <= 6) {
        [self setTintColor:hexToUIColor(removeSharpPrefix(value), 1)];
    }
    if ([key isEqualToString:kNCStyleActiveTextColor] && [MFDevice iOSVersionMajor] <= 6) {
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
        NSString *imagePath = [[MFViewManager currentWWWFolderName] stringByAppendingPathComponent:value];
        UIImage *image = [UIImage imageWithContentsOfFile:imagePath];
        if (image) {
            UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
            [btn setFrame:CGRectMake(0, 0, 20, 20)];
            [btn setBackgroundImage:image forState:UIControlStateNormal];
            [btn addTarget:self.target action:self.action forControlEvents:UIControlEventTouchUpInside];
            [btn sizeToFit];
            self.customView = btn;
        } else {
            self.customView = nil;
        }
    }
    if ([key isEqualToString:kNCStyleInnerImage] && [MFDevice iOSVersionMajor] <= 6) {
        NSString *imagePath = [[MFViewManager currentWWWFolderName] stringByAppendingPathComponent:value];
        UIImage *image = [UIImage imageWithContentsOfFile:imagePath];
        [self setImage:image];
        if (image) {
            // innerImageを設定するさいにはtitleをnilにしないとサイズがおかしくなる．
            [self setTitle:nil];
        }
    }
    if ([key isEqualToString:kNCStyleText]) {
        [self setTitle:[NSString stringWithFormat:@"%@", value]];
    }
    
    [_ncStyle updateStyle:value forKey:key];
}

@end
