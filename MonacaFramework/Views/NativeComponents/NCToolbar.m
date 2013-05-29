//
//  NCToolbar.m
//  MonacaFramework
//
//  Created by Nakagawa Hiroki on 12/02/15.
//  Copyright (c) 2012年 ASIAL CORPORATION. All rights reserved.
//

#import "NCToolbar.h"
#import "MFUtility.h"
#import "NCBarButtonItem.h"

#import <QuartzCore/QuartzCore.h>

@implementation NCToolbar

@synthesize viewController = _viewController;

+ (NSDictionary *)defaultStyles
{
    NSMutableDictionary *defaultStyle = [[NSMutableDictionary alloc] init];
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
    
    return defaultStyle;
}

- (id)initWithViewController:(MFViewController *)viewController
{
    self = [super init];
    
    if (self) {
        _viewController = viewController;
        _toolbar = viewController.navigationController.toolbar;
        _ncStyle = [[self.class defaultStyles] mutableCopy];
    }

    return self;
}

- (void)createToolbar:(NSDictionary *)uidict
{
    NSArray *topRight = [uidict objectForKey:kNCTypeRight];
    NSArray *topLeft = [uidict objectForKey:kNCTypeLeft];
    NSArray *topCenter = [uidict objectForKey:kNCTypeCenter];

    if (uidict != nil) {
        [_viewController.navigationController setToolbarHidden:NO];
    }

    [self setUserInterface:[uidict objectForKey:kNCTypeStyle]];
    [self applyUserInterface];
    
    UIBarButtonItem *spacer =
    [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    
    /***** create leftContainers *****/
    NSMutableArray *containers = [NSMutableArray array];
    if (topLeft) {
        for (id component in topLeft) {
            NCContainer *container = [NCContainer container:component forToolbar:self];
            if (container.component == nil) continue;
            [containers addObject:container.component];
            [_viewController.ncManager setComponent:container forID:container.cid];
        }
    }

    /***** create centerContainers *****/
    [containers addObject:spacer];
    if (topCenter) {
        for (id component in topCenter) {
            NCContainer *container = [NCContainer container:component forToolbar:self];
            if (container.component == nil) continue;
            [containers addObject:container.component];
            [_viewController.ncManager setComponent:container forID:container.cid];
        }
    }
    [containers addObject:spacer];
    /***** create rightContainers *****/
    if (topRight) {
        for (id component in topRight) {
            NCContainer *container = [NCContainer container:component forToolbar:self];
            if (container.component == nil) continue;
            [containers addObject:container.component];
            [_viewController.ncManager setComponent:container forID:container.cid];
        }
        // 右のスペースをnavigationBarのそれと合わせる
        UIBarButtonItem *negativeSpacer =[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
        negativeSpacer.width = -5.0f;
        [containers addObject:negativeSpacer];
    }
    
    _containers = containers;
    [self applyVisibility];
}

- (void)applyVisibility
{
    NSMutableArray *visiableContainers = [NSMutableArray array];
    for (id container in _containers) {
        if ([container isKindOfClass:[NCBarButtonItem class]]) {
            if (![container hidden]) {
                [visiableContainers addObject:container];
            }
        } else {
            [visiableContainers addObject:container];
        }
    }
    [_viewController setToolbarItems:visiableContainers];
}

#pragma mark - UIStyleProtocol

- (void)setUserInterface:(NSDictionary *)uidict
{
    for (id key in uidict) { 
        if ([_ncStyle objectForKey:key] == nil)
            continue;
        [_ncStyle setValue:[uidict valueForKey:key] forKey:key];
    }
}

- (void)applyUserInterface
{
    for (id key in [_ncStyle copy]) {
        [self updateUIStyle:[_ncStyle objectForKey:key] forKey:key];
    }
}

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
        BOOL hidden = NO;
        if (isFalse(value)) {
            hidden = YES;
        }
        [_viewController.navigationController setToolbarHidden:hidden];
    }
    if ([key isEqualToString:kNCStyleBackgroundColor]) {
        @try {
            [_toolbar setTintColor:hexToUIColor(removeSharpPrefix(value), 1)];
        }
        @catch (NSException *exception) {
            NSLog(@"%@", exception);
        }
    }
    if ([key isEqualToString:kNCStyleIOSBarStyle]) {
        UIBarStyle style = UIBarStyleDefault;
        if ([value isEqualToString:kNCBarStyleBlack]) {
            style = UIBarStyleBlack;
            [_toolbar setTranslucent:NO];
        } else if ([value isEqualToString:kNCBarStyleBlackOpaque]) {
            style = UIBarStyleBlackOpaque;
            [_toolbar setTranslucent:NO];
        } else if ([value isEqualToString:kNCBarStyleBlackTranslucent]) {
            style = UIBarStyleBlackTranslucent;
            [_toolbar setTranslucent:YES];
        } else if ([value isEqualToString:kNCBarStyleDefault]) {
            style = UIBarStyleDefault;
            [_toolbar setTranslucent:NO];
        }
        [_toolbar setBarStyle:style];
        /// translucentを反映させる
        [_viewController.navigationController setToolbarHidden:YES];
        if (!isFalse([self retrieveUIStyle:kNCStyleVisibility])) {
            [_viewController.navigationController setToolbarHidden:NO];
         }
    }
    if ([key isEqualToString:kNCStyleShadowOpacity]) {
        CALayer *toolBarLayer = _toolbar.layer;
        //        navBarLayer.shadowColor = [[UIColor blackColor] CGColor];
        //        navBarLayer.shadowRadius = 3.0f;
        toolBarLayer.shadowOffset = CGSizeMake(0.0f, -2.0f);

        [toolBarLayer setShadowOpacity:[value floatValue]];
    }

    if (value == [NSNull null]) {
        value = kNCUndefined;
    }
    [_ncStyle setValue:value forKey:key];
}

- (id)retrieveUIStyle:(NSString *)key
{
    if ([_ncStyle objectForKey:key] == nil) {
        // 例外処理
        return nil;
    }
    
    return [_ncStyle objectForKey:key];
}

@end
