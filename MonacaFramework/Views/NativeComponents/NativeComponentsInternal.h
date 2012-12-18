//
//  NativeComponentsInternal.h
//  MonacaFramework
//
//  Created by Hiroki Nakagawa on 11/11/15.
//  Copyright (c) 2011 ASIAL CORPORATION. All rights reserved.
//

#import "MFViewController.h"
#import "MFTabBarController.h"

#define kNCTrue  @"true"
#define kNCFalse @"false"

#define kNCPositionTop    @"top"
#define kNCPositionMiddle @"middle"
#define kNCPositionBottom @"bottom"

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
#define kNCStyleTextColor          @"textColor"
#define kNCStylePlaceholder        @"placeholder"
#define kNCStyleValue              @"value"
#define kNCStyleTitle              @"title"
#define kNCStyleSubtitle           @"subtitle"
#define kNCStyleTitleColor         @"titleColor"
#define kNCStyleSubtitleColor      @"subtitleColor"
#define kNCStyleTitleFontScale     @"titleFontScale"
#define kNCStyleSubtitleFontScale  @"subtitleFontScale"
#define kNCStyleTexts              @"texts"
#define kNCStyleImage              @"image"
#define kNCStyleActiveIndex        @"activeIndex"
#define kNCStyleBadgeText          @"badgeText"
#define kNCStyleFocus              @"focus"


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

static inline UIColor *
hexToUIColor(NSString *hex, CGFloat a) {
	NSScanner *colorScanner = [NSScanner scannerWithString:hex];
	unsigned int color;
	[colorScanner scanHexInt:&color];
	CGFloat r = ((color & 0xFF0000) >> 16)/255.0f;
	CGFloat g = ((color & 0x00FF00) >> 8) /255.0f;
	CGFloat b =  (color & 0x0000FF) /255.0f;
	return [UIColor colorWithRed:r green:g blue:b alpha:a];
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
