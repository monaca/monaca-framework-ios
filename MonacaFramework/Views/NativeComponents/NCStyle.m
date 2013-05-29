//
//  NCStyle.m
//  MonacaFramework
//
//  Created by Yasuhiro Mitsuno on 2013/05/30.
//  Copyright (c) 2013年 ASIAL CORPORATION. All rights reserved.
//

#import "NCStyle.h"
#import "MFUIChecker.h"
#import "NativeComponentsInternal.h"

@implementation NCStyle

+ (NSDictionary *)defaultStyleForComponent:(NSString *)component
{
    NSMutableDictionary *defaultStyle = [[NSMutableDictionary alloc] init];

    if ([component isEqualToString:kNCContainerToolbar]) {
        [defaultStyle setValue:kNCTrue forKey:kNCStyleVisibility];
        [defaultStyle setValue:kNCFalse forKey:kNCStyleDisable];
        [defaultStyle setValue:kNCBlack forKey:kNCStyleBackgroundColor];
        [defaultStyle setValue:kNCUndefined forKey:kNCStyleTitle];
        [defaultStyle setValue:kNCUndefined forKey:kNCStyleSubtitle];
        [defaultStyle setValue:kNCWhite forKey:kNCStyleTitleColor];
        [defaultStyle setValue:kNCWhite forKey:kNCStyleSubtitleColor];
        [defaultStyle setValue:[NSNumber numberWithFloat:1.0]  forKey:kNCStyleTitleFontScale];
        [defaultStyle setValue:[NSNumber numberWithFloat:1.0]  forKey:kNCStyleSubtitleFontScale];
        [defaultStyle setValue:kNCBarStyleDefault forKey:kNCStyleIOSBarStyle];
        [defaultStyle setValue:kNCUndefined forKey:kNCStyleTitleImage];
        [defaultStyle setValue:[NSNumber numberWithFloat:0.3] forKey:kNCStyleShadowOpacity];
    }
    if ([component isEqualToString:kNCContainerTabbar]) {
        [defaultStyle setValue:kNCTrue forKey:kNCStyleVisibility];
        [defaultStyle setValue:kNCBlack forKey:kNCStyleBackgroundColor];
        [defaultStyle setValue:[NSNumber numberWithInt:0] forKey:kNCStyleActiveIndex];
    }
    if ([component isEqualToString:kNCComponentButton]) {
        [defaultStyle setValue:kNCTrue forKey:kNCStyleVisibility];
        [defaultStyle setValue:kNCFalse forKey:kNCStyleDisable];
        [defaultStyle setValue:kNCBlack forKey:kNCStyleBackgroundColor];
        [defaultStyle setValue:kNCWhite forKey:kNCStyleActiveTextColor];
        [defaultStyle setValue:kNCWhite forKey:kNCStyleTextColor];
        [defaultStyle setValue:kNCUndefined forKey:kNCStyleImage];
        [defaultStyle setValue:kNCUndefined forKey:kNCStyleInnerImage];
        [defaultStyle setValue:kNCUndefined forKey:kNCStyleText];
    }
    if ([component isEqualToString:kNCComponentBackButton]) {
        [defaultStyle setValue:kNCTrue forKey:kNCStyleVisibility];
        [defaultStyle setValue:kNCBlack forKey:kNCStyleBackgroundColor];
        [defaultStyle setValue:kNCWhite forKey:kNCStyleActiveTextColor];
        [defaultStyle setValue:kNCWhite forKey:kNCStyleTextColor];
        [defaultStyle setValue:kNCUndefined forKey:kNCStyleInnerImage];
        [defaultStyle setValue:kNCUndefined forKey:kNCStyleText];
    }
    if ([component isEqualToString:kNCComponentLabel]) {
        [defaultStyle setValue:kNCTrue forKey:kNCStyleVisibility];
        [defaultStyle setValue:[NSNumber numberWithFloat:1.0] forKey:kNCStyleOpacity];
        [defaultStyle setValue:kNCWhite forKey:kNCStyleTextColor];
        [defaultStyle setValue:kNCUndefined forKey:kNCStyleText];
    }
    if ([component isEqualToString:kNCComponentSearchBox]) {
        [defaultStyle setValue:kNCTrue forKey:kNCStyleVisibility];
        [defaultStyle setValue:kNCFalse forKey:kNCStyleDisable];
        [defaultStyle setValue:[NSNumber numberWithFloat:1.0] forKey:kNCStyleOpacity];
        [defaultStyle setValue:kNCBlack forKey:kNCStyleTextColor];
        [defaultStyle setValue:kNCUndefined forKey:kNCStylePlaceholder];
        [defaultStyle setValue:kNCFalse forKey:kNCStyleFocus];
    }
    if ([component isEqualToString:kNCComponentSegment]) {
        [defaultStyle setValue:kNCTrue forKey:kNCStyleVisibility];
        [defaultStyle setValue:kNCFalse forKey:kNCStyleDisable];
        [defaultStyle setValue:[NSNumber numberWithFloat:1.0] forKey:kNCStyleOpacity];
        [defaultStyle setValue:kNCBlack forKey:kNCStyleBackgroundColor];
        [defaultStyle setValue:kNCWhite forKey:kNCStyleActiveTextColor];
        [defaultStyle setValue:kNCWhite forKey:kNCStyleTextColor];
        [defaultStyle setValue:[NSArray array] forKey:kNCStyleTexts];
        [defaultStyle setValue:[NSNumber numberWithInt:0] forKey:kNCStyleActiveIndex];
    }
    if ([component isEqualToString:kNCComponentTabbarItem]) {
        [defaultStyle setValue:kNCUndefined forKey:kNCStyleText];
        [defaultStyle setValue:kNCUndefined forKey:kNCStyleImage];
        [defaultStyle setValue:kNCUndefined forKey:kNCStyleBadgeText];
    }

    return defaultStyle;
}

- (id)initWithComponent:(NSString *)component
{
    self = [super init];
    
    if (self) {
        _component = component;
        _defaultStyle = [self.class defaultStyleForComponent:_component];
        _style = [_defaultStyle mutableCopy];
        
    }
    
    return self;
}

- (void)setStyles:(NSDictionary *)styles
{
    for (id styleKey in styles) {
        if ([_defaultStyle objectForKey:styleKey] == nil)
            continue;
        if (![self checkStyle:[styles objectForKey:styleKey] forKey:styleKey]) {
            continue;
        }
        [_style setValue:[styles valueForKey:styleKey] forKey:styleKey];
    }
}

- (NSDictionary *)getStyles
{
    return _style;
}

- (void)updateStyle:(id)value forKey:(NSString *)key
{
    if (value == [NSNull null]) {
        value = kNCUndefined;
    }
    [_style setValue:value forKey:key];
}

- (id)retrieveStyle:(NSString *)key
{
    if ([_style objectForKey:key] == nil) {
        // 例外処理
        return nil;
    }
    
    return [_style objectForKey:key];
}

- (BOOL)checkStyle:(id)value forKey:(id)key
{
    if ([_style objectForKey:key] == nil) {
        // 例外処理
        return NO;
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
    if (![[MFUIChecker valueType:value] isEqualToString:[MFUIChecker valueType:[_defaultStyle valueForKey:key]]]) {
        if ([[MFUIChecker valueType:value] isEqualToString:@"Integer"] &&
            [[MFUIChecker valueType:[_defaultStyle valueForKey:key]] isEqualToString:@"Float"]) {
            return YES;
        }
        NSLog(NSLocalizedString(@"Invalid value type", nil), _component , key,
              [MFUIChecker valueType:[_defaultStyle objectForKey:key]], value);
        return NO;
    }
    return YES;
}

@end
