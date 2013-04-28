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

- (id)init {
    self = [super init];

    if (self) {
        _segment = [[UISegmentedControl alloc] initWithItems:nil];
        [_segment setSegmentedControlStyle:UISegmentedControlStyleBar];
        self.customView = _segment;
        _ncStyle = [[NSMutableDictionary alloc] init];
        [_ncStyle setValue:kNCTrue forKey:kNCStyleVisibility];
        [_ncStyle setValue:kNCFalse forKey:kNCStyleDisable];
        [_ncStyle setValue:[NSNumber numberWithFloat:1.0] forKey:kNCStyleOpacity];
        [_ncStyle setValue:kNCBlack forKey:kNCStyleBackgroundColor];
        [_ncStyle setValue:kNCBlue forKey:kNCStyleActiveTextColor];
        [_ncStyle setValue:kNCWhite forKey:kNCStyleTextColor];
        [_ncStyle setValue:[NSArray array] forKey:kNCStyleTexts];
        [_ncStyle setValue:[NSNumber numberWithInt:0] forKey:kNCStyleActiveIndex];
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
        // TODO:
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
