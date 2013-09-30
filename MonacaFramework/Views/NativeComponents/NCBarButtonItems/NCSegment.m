//
//  NCSegment.m
//  MonacaFramework
//
//  Created by Yasuhiro Mitsuno on 2013/04/26.
//  Copyright (c) 2013年 ASIAL CORPORATION. All rights reserved.
//

#import "NCSegment.h"
#import "NativeComponentsInternal.h"
#import "MFDevice.h"

@implementation NCSegment

- (id)init {
    self = [super init];

    if (self) {
        _segment = [[UISegmentedControl alloc] initWithItems:nil];
        [_segment setSegmentedControlStyle:UISegmentedControlStyleBar];
        _type = kNCComponentSegment;
        self.customView = _segment;

        _ncStyle = [[NCStyle alloc] initWithComponent:kNCComponentSegment];
    }

    return self;
}

- (void)addTarget:(id)target action:(SEL)action forControlEvents:(UIControlEvents)controlEvents
{
    [_segment addTarget:target action:action forControlEvents:controlEvents];
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
            [_segment setUserInteractionEnabled:YES];
        } else {
            [_segment setUserInteractionEnabled:NO];
        }
    }
    if ([key isEqualToString:kNCStyleOpacity]) {
        [_segment setAlpha:[value floatValue]];
    }
    if ([key isEqualToString:kNCStyleBackgroundColor]) {
        if ([value  isEqual: kNCUndefined]) {
            return;
        }
        float alpha = [[self retrieveUIStyle:kNCStyleOpacity] floatValue];
        [_segment setTintColor:hexToUIColor(removeSharpPrefix(value), alpha)];
    }
    if ([key isEqualToString:kNCStyleActiveTextColor] && [MFDevice iOSVersionMajor] <= 6) {
        UIColor *color = hexToUIColor(removeSharpPrefix(value), 1);
        NSDictionary *attributes = [NSDictionary dictionaryWithObjectsAndKeys:color, UITextAttributeTextColor, nil];
        [_segment setTitleTextAttributes:attributes forState:UIControlStateHighlighted];
    }
    if ([key isEqualToString:kNCStyleTextColor] && [MFDevice iOSVersionMajor] <= 6) {
        UIColor *color = hexToUIColor(removeSharpPrefix(value), 1);
        NSDictionary *attributes = [NSDictionary dictionaryWithObjectsAndKeys:color, UITextAttributeTextColor, nil];
        [_segment setTitleTextAttributes:attributes forState:UIControlStateNormal];
    }
    if ([key isEqualToString:kNCStyleTexts]) {
        [_segment removeAllSegments];
        int index = 0;
        for (id text in value) {
            [_segment insertSegmentWithTitle:text atIndex:index++ animated:NO];
        }
        [_segment sizeToFit];
        // activeIndexはtextsが設定されるまで反映されないので再度実行
        [self updateUIStyle:[[_ncStyle styles] objectForKey:kNCStyleActiveIndex] forKey:kNCStyleActiveIndex];
        
    }
    if ([key isEqualToString:kNCStyleActiveIndex]) {
        [_segment setSelectedSegmentIndex:[value intValue]];
    }
    
    [_ncStyle updateStyle:value forKey:key];
}

@end
