//
//  NCSegment.m
//  MonacaFramework
//
//  Created by Yasuhiro Mitsuno on 2013/04/26.
//  Copyright (c) 2013年 ASIAL CORPORATION. All rights reserved.
//

#import "NCSegment.h"
#import "NativeComponentsInternal.h"

@implementation NCSegment

+ (NSDictionary *)defaultStyles
{
    NSMutableDictionary *defaultStyle = [[NSMutableDictionary alloc] init];
    [defaultStyle setValue:kNCTrue forKey:kNCStyleVisibility];
    [defaultStyle setValue:kNCFalse forKey:kNCStyleDisable];
    [defaultStyle setValue:[NSNumber numberWithFloat:1.0] forKey:kNCStyleOpacity];
    [defaultStyle setValue:kNCBlack forKey:kNCStyleBackgroundColor];
    [defaultStyle setValue:kNCWhite forKey:kNCStyleActiveTextColor];
    [defaultStyle setValue:kNCWhite forKey:kNCStyleTextColor];
    [defaultStyle setValue:[NSArray array] forKey:kNCStyleTexts];
    [defaultStyle setValue:[NSNumber numberWithInt:0] forKey:kNCStyleActiveIndex];
    return defaultStyle;
}

- (id)init {
    self = [super init];

    if (self) {
        _segment = [[UISegmentedControl alloc] initWithItems:nil];
        [_segment setSegmentedControlStyle:UISegmentedControlStyleBar];
        self.customView = _segment;
        _ncStyle = [[NSMutableDictionary alloc] initWithDictionary:[self.class defaultStyles]];
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
        float alpha = [[self retrieveUIStyle:kNCStyleOpacity] floatValue];
        [_segment setTintColor:hexToUIColor(removeSharpPrefix(value), alpha)];
    }
    if ([key isEqualToString:kNCStyleActiveTextColor]) {
        UIColor *color = hexToUIColor(removeSharpPrefix(value), 1);
        NSDictionary *attributes = [NSDictionary dictionaryWithObjectsAndKeys:color, UITextAttributeTextColor, nil];
        [_segment setTitleTextAttributes:attributes forState:UIControlStateHighlighted];
    }
    if ([key isEqualToString:kNCStyleTextColor]) {
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
    }
    if ([key isEqualToString:kNCStyleActiveIndex]) {
        [_segment setSelectedSegmentIndex:[value intValue]];
    }

    if (value == [NSNull null]) {
        value = kNCUndefined;
    }
    [_ncStyle setValue:value forKey:key];
}

@end
