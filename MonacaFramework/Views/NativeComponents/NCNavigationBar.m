//
//  NCNavigationBar.m
//  MonacaFramework
//
//  Created by Yasuhiro Mitsuno on 2013/04/28.
//  Copyright (c) 2013年 ASIAL CORPORATION. All rights reserved.
//

#import "NCNavigationBar.h"
#import "MFUtility.h"

@implementation NCNavigationBar

@synthesize viewController = _viewController;

- (id)initWithViewController:(MFViewController *)viewController
{
    self = [super init];

    if (self) {
        _viewController = viewController;
        _navigationBar = viewController.navigationController.navigationBar;
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

- (void)createNavigationBar:(NSDictionary *)uidict
{
    NSArray *topRight = [uidict objectForKey:kNCTypeRight];
    NSArray *topLeft = [uidict objectForKey:kNCTypeLeft];
    NSArray *topCenter = [uidict objectForKey:kNCTypeCenter];

    if (uidict != nil) {
        [_viewController.navigationController setNavigationBarHidden:NO];
    }

    [self applyUserInterface:[uidict objectForKey:kNCTypeStyle]];

    /***** create leftContainers *****/
    NSMutableArray *containers = [NSMutableArray array];
    for (id component in topLeft) {
        NCContainer *container = [NCContainer container:component position:kNCPositionTop];
        [containers addObject:container.component];
        [_viewController.ncManager setComponent:container forID:container.cid];
    }
    _viewController.navigationItem.leftBarButtonItems = containers;

    /***** create rightContainers *****/
    containers = [NSMutableArray array];
    for (id component in topRight) {
        NCContainer *container = [NCContainer container:component position:kNCPositionTop];
        [containers addObject:container.component];
        [_viewController.ncManager setComponent:container forID:container.cid];
    }
    // 表示順序を入れ替える
    NSMutableArray *reverseContainers = [NSMutableArray array];
    while ([containers count] != 0){
        [reverseContainers addObject:[containers lastObject]];
        [containers removeLastObject];
    }
    _viewController.navigationItem.rightBarButtonItems = reverseContainers;

    /***** create centerContainers *****/
    containers = [NSMutableArray array];
    for (id component in topCenter) {
        NCContainer *container = [NCContainer container:component position:kNCPositionTop];
        [containers addObject:container.component];
        [_viewController.ncManager setComponent:container forID:container.cid];
    }
    // TODO: Fix to allow few component for centerView
    if ([containers count] != 0) {
        _viewController.navigationItem.titleView = [[containers objectAtIndex:0] view];
    }
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
        [_viewController.navigationController setNavigationBarHidden:hidden];
    }
    if ([key isEqualToString:kNCStyleBackgroundColor]) {
        [_navigationBar setTintColor:hexToUIColor(removeSharpPrefix(value), 1)];
    }
    if ([key isEqualToString:kNCStyleTitle]) {
        [_viewController setTitle:value];
    }
    if ([key isEqualToString:kNCStyleTitleColor]) {
        UIColor *color = hexToUIColor(removeSharpPrefix(value), 1);
        NSDictionary *attributes = [NSDictionary dictionaryWithObjectsAndKeys:color, UITextAttributeTextColor, nil];
        [_navigationBar setTitleTextAttributes:attributes];
    }
    // TODO: Implement Subtitle
    if ([key isEqualToString:kNCStyleIOSBarStyle]) {
        [_navigationBar setBarStyle:value];
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
