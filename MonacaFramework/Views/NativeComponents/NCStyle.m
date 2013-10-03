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
#import "MFViewManager.h"

@implementation NCStyle

+ (NSDictionary *)defaultStyleForComponent:(NSString *)component
{
    NSMutableDictionary *defaultStyle = [[NSMutableDictionary alloc] init];

    if ([component isEqualToString:kNCContainerPage]) {
        [defaultStyle setValue:kNCWhite forKey:kNCStyleBackgroundColor];
        [defaultStyle setValue:kNCUndefined forKey:kNCStyleBackgroundImage];
        [defaultStyle setValue:kNCTypeAuto forKey:kNCStyleBackgroundSize];
        [defaultStyle setValue:kNCTypeNoRepeat forKey:kNCStyleBackgroundRepeat];
        [defaultStyle setValue:@[kNCTypeCenter, kNCTypeCenter] forKey:kNCStyleBackgroundPosition];
        [defaultStyle setValue:kNCTypeInherit forKey:kNCStyleScreenOrientation];
    }
    if ([component isEqualToString:kNCContainerToolbar]) {
        [defaultStyle setValue:kNCTrue forKey:kNCStyleVisibility];
        [defaultStyle setValue:kNCFalse forKey:kNCStyleDisable];
        [defaultStyle setValue:kNCBlack forKey:kNCStyleBackgroundColor];
        [defaultStyle setValue:[NSNumber numberWithFloat:1.0] forKey:kNCStyleOpacity];
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
        [defaultStyle setValue:[NSNumber numberWithFloat:1.0] forKey:kNCStyleOpacity];
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
        [defaultStyle setValue:kNCFalse forKey:kNCStyleDisable];
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
        [defaultStyle setValue:kNCUndefined forKey:kNCStyleValue];
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
        _defaultStyles = [self.class defaultStyleForComponent:_component];
        _styles = [_defaultStyles mutableCopy];    
    }
    
    return self;
}

- (id)getDefaultStyle:(NSString *)key
{
    return [_defaultStyles objectForKey:key];
}

- (void)resetStyles
{
    _styles = [_defaultStyles mutableCopy];
}

- (void)setStyles:(NSDictionary *)styles
{

    for (id styleKey in styles) {
        if ([_defaultStyles objectForKey:styleKey] == nil) {
            NSLog(NSLocalizedString(@"Key is not one of valid keys", nil), _component, styleKey, [MFUIChecker dictionaryKeysToString:[_styles copy]]);
            continue;
        }
        if (![self checkStyle:[styles objectForKey:styleKey] forKey:styleKey]) {
            continue;
        }
        [_styles setValue:[styles valueForKey:styleKey] forKey:styleKey];
    }
}

- (NSDictionary *)styles
{
    return [_styles copy];
}

- (void)updateStyle:(id)value forKey:(NSString *)key
{
    if (value == [NSNull null]) {
        value = kNCUndefined;
    }
    [_styles setValue:value forKey:key];
}

- (id)retrieveStyle:(NSString *)key
{
    if ([_styles objectForKey:key] == nil) {
        // 例外処理
        return nil;
    }
    
    return [_styles objectForKey:key];
}

- (BOOL)checkStyle:(id)value forKey:(id)key
{
    if ([_styles objectForKey:key] == nil) {
        // 例外処理
        return NO;
    }
    
    if (value == [NSNull null]) {
        value = kNCUndefined;
    }
    if ([NSStringFromClass([[_styles valueForKey:key] class]) isEqualToString:@"__NSCFBoolean"]) {
        if (isFalse(value)) {
            value = kNCFalse;
        } else {
            value = kNCTrue;
        }
    }
    if (![[MFUIChecker valueType:value] isEqualToString:[MFUIChecker valueType:[_defaultStyles valueForKey:key]]]) {
        // 文字列が数字のみのときに反映されないバグの対応
        if ([key isEqualToString:kNCStyleTitle] || [key isEqualToString:kNCStyleSubtitle] || [key isEqualToString:kNCStyleText] || [key isEqualToString:kNCStylePlaceholder] || [key isEqualToString:kNCStyleBadgeText]) {
            if ([[MFUIChecker valueType:value] isEqualToString:@"Integer"] ||
                [[MFUIChecker valueType:value] isEqualToString:@"Float"]) {
                return YES;
            }
        }
        if ([[MFUIChecker valueType:value] isEqualToString:@"Integer"] &&
            [[MFUIChecker valueType:[_defaultStyles valueForKey:key]] isEqualToString:@"Float"]) {
            return YES;
        }
        if ([_component isEqualToString:kNCContainerPage]) {
            //TODO: Page styleは他でcheckする。
            if ([key isEqualToString:kNCStyleBackgroundColor])
                return NO;
            return YES;
        }
        NSLog(NSLocalizedString(@"Invalid value type", nil), _component , key,
              [MFUIChecker valueType:[_defaultStyles objectForKey:key]], value);
        return NO;
    }
    if ([key isEqualToString:kNCStyleInnerImage] || [key isEqualToString:kNCStyleImage] || [key isEqualToString:kNCStyleBackgroundImage]) {
        if (value != nil && ![value isEqualToString:kNCUndefined]) {
            NSString *imagePath = [[MFViewManager currentWWWFolderName] stringByAppendingPathComponent:value];
            if ([UIImage imageWithContentsOfFile:imagePath] == nil) {
                NSLog(NSLocalizedString(@"Resource not found", nil), _component, key, value);
                return NO;
            }
        }
    }
    
    return YES;
}

@end
