//
//  NativeComponentsInternal.h
//  MonacaFramework
//
//  Created by Hiroki Nakagawa on 11/11/15.
//  Copyright (c) 2011 ASIAL CORPORATION. All rights reserved.
//

#import "MFViewController.h"
#import "MFTabBarController.h"

#define kNCTrue         @"true"
#define kNCFalse        @"false"
#define kNCUndefined    @"undefined"
#define kNCBlack        @"#000000"
#define kNCWhite        @"#FFFFFF"
#define kNCBlue         @"#0000FF"
#define kNCArray        [NSArray array]
#define kNCInt0         [NSNumber numberWithInt:0]
#define kNCFloat1       [NSNumber numberWithFloat:1.0]

#define kNCPageStyle     @"style"

#define kNCPositionTop    @"top"
#define kNCPositionMiddle @"middle"
#define kNCPositionBottom @"bottom"

#define kNCContainerPage     @"page"
#define kNCContainerToolbar @"toolbar"
#define kNCContainerTabbar  @"tabbar"

#define kNCTypeStyle     @"style"
#define kNCTypeIOSStyle  @"iosStyle"
#define kNCTypeCenter    @"center"
#define kNCTypeLeft      @"left"
#define kNCTypeRight     @"right"
#define kNCTypeContainer @"container"
#define kNCTypeEvent     @"event"
#define kNCTypeID        @"id"
#define kNCTypeItems     @"items"
#define kNCTypeLink      @"link"
#define kNCTypeRepeat    @"repeat"
#define kNCTypeNoRepeat  @"no-repeat"
#define kNCTypeContain   @"contain"
#define kNCTypeAuto      @"auto"
#define kNCTypeCover     @"cover"

#define kNCEventTypeTap     @"onTap"
#define kNCEventTypeChange  @"onChange"
#define kNCEventTypeSearch  @"onSearch"

#define kNCComponentButton      @"button"
#define kNCComponentBackButton  @"backButton"
#define kNCComponentLabel       @"label"
#define kNCComponentSearchBox   @"searchBox"
#define kNCComponentSegment     @"segment"
#define kNCComponentTabbarItem  @"tabbarItem"

#define kNCStyleComponent          @"component"
#define kNCStyleText               @"text"
#define kNCStyleInnerImage         @"innerImage"
#define kNCStyleVisibility         @"visibility"
#define kNCStyleDisable            @"disable"
#define kNCStyleOpacity            @"opacity"
#define kNCStyleBackgroundColor    @"backgroundColor"
#define kNCStyleBackgroundImage    @"backgroundImage"
#define kNCStyleBackgroundSize     @"backgroundSize"
#define kNCStyleBackgroundRepeat   @"backgroundRepeat"
#define kNCStyleBackgroundPosition @"backgroundPosition"
#define kNCStyleTextColor          @"textColor"
#define kNCStylePlaceholder        @"placeholder"
#define kNCStyleValue              @"value"
#define kNCStyleTitle              @"title"
#define kNCStyleSubtitle           @"subtitle"
#define kNCStyleTitleImage         @"titleImage"
#define kNCStyleShadowOpacity      @"shadowOpacity"
#define kNCStyleTitleColor         @"titleColor"
#define kNCStyleSubtitleColor      @"subtitleColor"
#define kNCStyleTitleFontScale     @"titleFontScale"
#define kNCStyleSubtitleFontScale  @"subtitleFontScale"
#define kNCStyleTexts              @"texts"
#define kNCStyleImage              @"image"
#define kNCStyleActiveIndex        @"activeIndex"
#define kNCStyleBadgeText          @"badgeText"
#define kNCStyleFocus              @"focus"
#define kNCStyleActiveTextColor    @"activeTextColor"
#define kNCStyleForceVisibility    @"forceVisibility"

#define kNCStyleBackgroundImageFilePath        @"backgroundImageFilePath"
#define kNCStyleBackgroundSizeWidth        @"backgroundSizeWidth"
#define kNCStyleBackgroundSizeHeight       @"backgroundSizeHeight"
#define kNCStyleBackgroundPositionHorizontal  @"backgroundPositionHorizontal"
#define kNCStyleBackgroundPositionVertical    @"backgroundPositionVertical"

#define kNCStyleIOSBarStyle     @"iosBarStyle"
#define kNCStyleIOSButtonStyle  @"iosButtonStyle"
#define kNCStyleIOSFrame        @"ios-frame"


static BOOL
isTrue(id object) {
    if (object == NULL) {
        return NO;
    }
    if ([object isKindOfClass:[NSString class]]) {
        return [(NSString *)object isEqualToString:kNCTrue];
    }
    if ([object isKindOfClass:[NSNumber class]]) {
        return [object intValue] == 1;
    }
    return NO;
}

static BOOL
isFalse(id object) {
    if (object == NULL) {
        return NO;
    }
    if ([object isKindOfClass:[NSString class]]) {
        return [(NSString *)object isEqualToString:kNCFalse];
    }
    if ([object isKindOfClass:[NSNumber class]]) {
        return [object intValue] == 0;
    }
    return NO;
}


// =================================================
// Utility functions for UIColor.
// =================================================

// Removes prefix # (ex. "#ff0000" => "ff0000").
static inline NSString *
removeSharpPrefix(NSString *color) {
    return [color substringFromIndex:1];
}

static inline NSString *
normalizeColorHex(NSString *colorHex) {
    if (colorHex.length == 3) {
        NSString *a, *b, *c;
        a = [colorHex substringWithRange:NSMakeRange(0, 1)];
        b = [colorHex substringWithRange:NSMakeRange(1, 1)];
        c = [colorHex substringWithRange:NSMakeRange(2, 1)];
        colorHex = [NSString stringWithFormat:@"%@%@%@%@%@%@", a, a, b, b, c, c, nil];
    }
    
    return colorHex;
}

static inline UIColor *
hexToUIColor(NSString *hex, CGFloat a) {
	NSScanner *colorScanner = [NSScanner scannerWithString:normalizeColorHex(hex)];
	unsigned int color;
	[colorScanner scanHexInt:&color];
	CGFloat r = ((color & 0xFF0000) >> 16)/255.0f;
	CGFloat g = ((color & 0x00FF00) >> 8) /255.0f;
	CGFloat b =  (color & 0x0000FF) /255.0f;
	return [UIColor colorWithRed:r green:g blue:b alpha:a];
}

static inline NSString*
UIColorToHex(UIColor *color) {
    CGFloat red, green, blue, alpha;
    NSNumber *redValue, *greenValue, *blueValue;
    [color getRed:&red green:&green blue:&blue alpha:&alpha];
    redValue = [[NSNumber alloc] initWithFloat:red * 255.0f];
    greenValue = [[NSNumber alloc] initWithFloat:green * 255.0f];
    blueValue = [[NSNumber alloc ] initWithFloat:blue * 255.0f];
    return [NSString stringWithFormat:@"#%02X%02X%02X", [redValue intValue], [greenValue intValue], [blueValue intValue]];
}

// =================================================
// iOS version.
// =================================================

static inline NSInteger
iOSVersionMajor() {
    NSArray *versions = [[[UIDevice currentDevice] systemVersion] componentsSeparatedByString:@"."];
    return [[versions objectAtIndex:0] intValue];
}

static inline NSInteger
iOSVersionMinor1() {
    NSArray *versions = [[[UIDevice currentDevice] systemVersion] componentsSeparatedByString:@"."];
    return [[versions objectAtIndex:1] intValue];
}

static inline NSInteger
iOSVersionMinor2() {
    NSArray *versions = [[[UIDevice currentDevice] systemVersion] componentsSeparatedByString:@"."];
    return [[versions objectAtIndex:2] intValue];
}
