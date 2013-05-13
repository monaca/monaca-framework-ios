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
        _centerViewToolbar = [[UIToolbar alloc] init];
        _titleView = [[NCTitleView alloc] init];
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
        NCContainer *container = [NCContainer container:component forToolbar:self];
        if (container.component == nil) continue;
        if ([container.type isEqualToString:kNCComponentBackButton]) {
            if (_backButton == nil) {
                _backButton = container;
            } else {
                continue;
            }
        }
        [containers addObject:container.component];
        [_viewController.ncManager setComponent:container forID:container.cid];
    }
    _leftContainers = containers;
    [_viewController setBackButton:_backButton];
    if (!_backButton) {
        [_viewController.navigationItem setHidesBackButton:YES];
    }

    /***** create rightContainers *****/
    containers = [NSMutableArray array];
    for (id component in topRight) {
        NCContainer *container = [NCContainer container:component forToolbar:self];
        if (container.component == nil) continue;
        [containers addObject:container.component];
        [_viewController.ncManager setComponent:container forID:container.cid];
    }
    // 表示順序を入れ替える
    NSMutableArray *reverseContainers = [NSMutableArray array];
    while ([containers count] != 0){
        [reverseContainers addObject:[containers lastObject]];
        [containers removeLastObject];
    }
    _rightContainers = reverseContainers;

    /***** create centerContainers *****/
    containers = [NSMutableArray array];
    for (id component in topCenter) {
        NCContainer *container = [NCContainer container:component forToolbar:self];
        if (container.component == nil) continue;
        [containers addObject:container.component];
        [_viewController.ncManager setComponent:container forID:container.cid];
    }
    _centerContainers = containers;

    [self applyVisibility];
}

- (void)applyBackButton
{
    if (_backButton) {
        NSArray *viewControllers = [_viewController.navigationController viewControllers];
        if ([viewControllers count]> 1) {
            [[[viewControllers objectAtIndex:[viewControllers count]-2] navigationItem] setBackBarButtonItem:nil];
            [[[viewControllers objectAtIndex:[viewControllers count]-2] navigationItem] setBackBarButtonItem:_backButton.component];
            [_viewController.navigationItem setHidesBackButton:[_backButton.component hidden] animated:YES];
            [_viewController.navigationItem setLeftItemsSupplementBackButton:YES];
        }
    } else {
        [_viewController.navigationItem setHidesBackButton:YES];
    }
}

- (void)applyVisibility
{
    /***** apply leftContainers *****/
    NSMutableArray *visiableContainers = [NSMutableArray array];
    for (NCBarButtonItem *container in _leftContainers) {
        if (![container hidden] && ![container isKindOfClass:[NCBackButton class]]) {
            [visiableContainers addObject:container];
        }
    }
    _viewController.navigationItem.leftBarButtonItems = visiableContainers;

    /***** apply backButton Container *****/
    [self applyBackButton];

    /***** apply rightContainers *****/
    visiableContainers = [NSMutableArray array];
    for (NCBarButtonItem *container in _rightContainers) {
        if (![container hidden]) {
            [visiableContainers addObject:container];
        }
    }
    _viewController.navigationItem.rightBarButtonItems = visiableContainers;

    /***** apply centerContainers *****/
    UIBarButtonItem *spacer =
    [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    visiableContainers = [NSMutableArray array];

    [visiableContainers addObject:spacer];
    for (NCBarButtonItem *container in _centerContainers) {
        if (![container hidden]) {
            [visiableContainers addObject:container];
        }
    }
    [visiableContainers addObject:spacer];

    if (![[_titleView retrieveUIStyle:kNCStyleTitle] isEqualToString:kNCUndefined]) {
        _viewController.navigationItem.titleView = _titleView;
    } else {
        if ([visiableContainers count] > 2) {
            [_centerViewToolbar setItems:visiableContainers];
            // TODO: allow few containers
            _viewController.navigationItem.titleView = nil;
            _viewController.navigationItem.titleView = [[visiableContainers objectAtIndex:1] view];
        } else {
            _viewController.navigationItem.titleView = nil;
        }
    }
}

#pragma mark - UIStyleProtocol

- (void)applyUserInterface:(NSDictionary *)uidict
{
    for (id key in uidict) {
        [self updateUIStyle:[uidict objectForKey:key] forKey:key];
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
        [_viewController.navigationController setNavigationBarHidden:hidden];
    }
    if ([key isEqualToString:kNCStyleBackgroundColor]) {
        [_navigationBar setTintColor:hexToUIColor(removeSharpPrefix(value), 1)];
        [_centerViewToolbar setTintColor:hexToUIColor(removeSharpPrefix(value), 1)];
    }

    // title,subtitleに関してはNCTitleViewに委譲
    [_titleView updateUIStyle:value forKey:key];
    
    if ([key isEqualToString:kNCStyleIOSBarStyle]) {
        UIBarStyle style = UIBarStyleDefault;
        if ([value isEqualToString:@"UIBarStyleBlack"]) {
            style = UIBarStyleBlack;
        } else if ([value isEqualToString:@"UIBarStyleBlackOpaque"]) {
            style = UIBarStyleBlackOpaque;
        } else if ([value isEqualToString:@"UIBarStyleBlackTranslucent"]) {
            style = UIBarStyleBlackTranslucent;
        } else if ([value isEqualToString:@"UIBarStyleDefault"]) {
            style = UIBarStyleDefault;
        }
        [_navigationBar setBarStyle:style];
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
