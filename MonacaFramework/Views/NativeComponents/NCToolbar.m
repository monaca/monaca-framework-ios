//
//  NCToolbar.m
//  MonacaFramework
//
//  Created by Nakagawa Hiroki on 12/02/15.
//  Copyright (c) 2012年 ASIAL CORPORATION. All rights reserved.
//

#import "NCToolbar.h"
#import "MFUtility.h"

@implementation NCToolbar

@synthesize viewController = _viewController;

- (id)initWithViewController:(MFViewController *)viewController
{
    self = [super init];
    
    if (self) {
        _viewController = viewController;
        _toolbar = viewController.navigationController.toolbar;
        _ncStyle = [[NSMutableDictionary alloc] init];
        [_ncStyle setValue:kNCTrue forKey:kNCStyleVisibility];
        [_ncStyle setValue:kNCFalse forKey:kNCStyleDisable];
        [_ncStyle setValue:kNCBlack forKey:kNCStyleBackgroundColor];
        [_ncStyle setValue:kNCUndefined forKey:kNCStyleTitle];
        [_ncStyle setValue:kNCUndefined forKey:kNCStyleSubtitle];
        [_ncStyle setValue:kNCWhite forKey:kNCStyleTitleColor];
        [_ncStyle setValue:kNCWhite forKey:kNCStyleSubtitleColor];
        [_ncStyle setValue:[NSNumber numberWithFloat:1.0]  forKey:kNCStyleTitleFontScale];
        [_ncStyle setValue:[NSNumber numberWithFloat:1.0]  forKey:kNCStyleSubtitleFontScale];
        [_ncStyle setValue:kNCUndefined forKey:kNCStyleIOSBarStyle];
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

    [self applyUserInterface:[uidict objectForKey:kNCTypeStyle]];
    
    UIBarButtonItem *spacer =
    [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    
    /***** create leftContainers *****/
    NSMutableArray *containers = [NSMutableArray array];
    if (topLeft) {
        for (id component in topLeft) {
            NCContainer *container = [NCContainer container:component position:kNCPositionTop];
            [containers addObject:container.component];
            [_viewController.ncManager setComponent:container forID:container.cid];
        }
    }

    /***** create centerContainers *****/
    [containers addObject:spacer];
    if (topCenter) {
        for (id component in topCenter) {
            NCContainer *container = [NCContainer container:component position:kNCPositionTop];
            [containers addObject:container.component];
            [_viewController.ncManager setComponent:container forID:container.cid];
        }
    }
    [containers addObject:spacer];
    
    /***** create rightContainers *****/
    if (topRight) {
        for (id component in topRight) {
            NCContainer *container = [NCContainer container:component position:kNCPositionTop];
            [containers addObject:container.component];
            [_viewController.ncManager setComponent:container forID:container.cid];
        }
        // 右のスペースをnavigationBarのそれと合わせる
        UIBarButtonItem *negativeSpacer =[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
        negativeSpacer.width = -5.0f;
        [containers addObject:negativeSpacer];
    }
    
    [_viewController setToolbarItems:containers];
}

- (void)applyUserInterface:(NSDictionary *)uidict
{
    for (id key in uidict) {
        [self updateUIStyle:[uidict objectForKey:key] forKey:key];
    }
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
        BOOL hidden = NO;
        if (isFalse(value)) {
            hidden = YES;
        }
        [_viewController.navigationController setToolbarHidden:hidden];
    }
    if ([key isEqualToString:kNCStyleBackgroundColor]) {
        [_toolbar setTintColor:hexToUIColor(removeSharpPrefix(value), 1)];
    }
    if ([key isEqualToString:kNCStyleIOSBarStyle]) {
        [_toolbar setBarStyle:value];
    }

    if (value == [NSNull null]) {
        value = nil;
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
