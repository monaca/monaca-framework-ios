//
//  NCLabel.m
//  MonacaFramework
//
//  Created by Yasuhiro Mitsuno on 2013/04/26.
//  Copyright (c) 2013年 ASIAL CORPORATION. All rights reserved.
//

#import "NCLabel.h"
#import "NativeComponentsInternal.h"

@implementation NCLabel

- (id)init {
    self = [super init];
    
    if (self) {
        _label = [[UILabel alloc] init];
        [_label setBackgroundColor:[UIColor clearColor]];
        self.customView = _label;
        _ncStyle = [[NSMutableDictionary alloc] init];
        [_ncStyle setValue:kNCTrue forKey:kNCStyleVisibility];
        [_ncStyle setValue:[NSNumber numberWithFloat:1.0] forKey:kNCStyleOpacity];
        [_ncStyle setValue:kNCWhite forKey:kNCStyleTextColor];
        [_ncStyle setValue:[NSArray array] forKey:kNCStyleText];
    }
    
    return self;
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
        _hidden = isFalse(value);
        [_toolbar applyVisibility];
    }
    if ([key isEqualToString:kNCStyleOpacity]) {
        [_label setAlpha:[value floatValue]];
    }
    if ([key isEqualToString:kNCStyleTextColor]) {
        float alpha = [[self retrieveUIStyle:kNCStyleOpacity] floatValue];
        [_label setTextColor:hexToUIColor(removeSharpPrefix(value), alpha)];
    }
    if ([key isEqualToString:kNCStyleText]) {
        [_label setText:value];
        [_label sizeToFit];
    }
    
    if (value == [NSNull null]) {
        value = kNCUndefined;
    }
    [_ncStyle setValue:value forKey:key];
}

@end
