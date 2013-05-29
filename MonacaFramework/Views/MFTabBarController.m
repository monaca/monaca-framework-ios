//
//  MonacaTabBarController.m
//  MonacaFramework
//
//  Created by Hiroki Nakagawa on 11/11/10.
//  Copyright (c) 2011 ASIAL CORPORATION. All rights reserved.
//

#import "MFTabBarController.h"
#import "MFUtility.h"
#import "MFEvent.h"
#import "MFViewBuilder.h"

@implementation MFTabBarController

@synthesize ncManager = _ncManager;

// iOS4 の場合、このメソッドは MonacaViewController の viewDidApper メソッドから呼ばれる
- (void)viewWillAppear:(BOOL)animated {
    [self.navigationController setNavigationBarHidden:YES];
    [super viewWillAppear:animated];
}

// iOS4 の場合、このメソッドは MonacaViewController の viewDidApper メソッドから呼ばれる
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
}

- (id)init {
    self = [super init];
    if (nil != self) {
        self.ncManager = [[NCManager alloc] init];
        _ncStyle = [[NCStyle alloc] initWithComponent:kNCContainerTabbar];
    }
    return self;
}

- (void)destroy
{
    for (MFViewController *view in self.viewControllers) {
        [view destroy];
    }
}

- (void)dealloc {
    self.ncManager = nil;
}

- (BOOL) shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)orientation {
    return [MFUtility getAllowOrientationFromPlist:orientation];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)viewDidUnload {
    [super viewDidUnload];
}

- (void)loadView {
    [super loadView];
}

#pragma mark - UITabBarDeledate

/*
    現時点ではmoreNavigationControllerの編集は不可としているため呼び出されないが、
    編集を許可した場合にはbackButtonの表示問題を解決しなければならない。
*/
- (void)tabBar:(UITabBar *)tabBar didEndCustomizingItems:(NSArray *)items changed:(BOOL)changed
{
    if (!changed) {
        return;
    }
    // moreViewControllerで呼び出されるviewControllerは全てRootViewControllerに戻す.
    for (MFNavigationController *viewController in self.viewControllers) {
        BOOL exist = NO;
        for (UITabBarItem *item in items) {
            if (viewController.tabBarItem == item) {
                exist = YES;
                break;
            }
        }
        if (!exist) {
            [viewController popToRootViewControllerAnimated:NO];
        }
    }
}

#pragma mark - UIStyleProtocol

- (void)setUserInterface:(NSDictionary *)uidict
{
    [_ncStyle setStyles:uidict];
}

- (void)applyUserInterface
{
    for (id key in [[_ncStyle getStyles] copy]) {
        [self updateUIStyle:[[_ncStyle getStyles] objectForKey:key] forKey:key];
    }
}

- (void)updateUIStyle:(id)value forKey:(NSString *)key
{
    if (![_ncStyle checkStyle:value forKey:key]) {
        return;
    }
    
    // TODO: Implement hideTabbar
    if ([key isEqualToString:kNCStyleBackgroundColor]) {
        [self.tabBar setTintColor:hexToUIColor(removeSharpPrefix(value), 1)];
    }
    if ([key isEqualToString:kNCStyleActiveIndex]) {
        NSInteger index = [value intValue];
        if (index < 0 || index >= [self.viewControllers count]) {
            index = 0;
        }
        [self setSelectedIndex:index];
    }

    if (value == [NSNull null]) {
        value = kNCUndefined; 
    }
    [_ncStyle updateStyle:value forKey:key];
}

- (id)retrieveUIStyle:(NSString *)key
{
    // activeIndexについてはselectedIndexから取得する．
    [_ncStyle updateStyle:[NSNumber numberWithInt:[self selectedIndex]] forKey:kNCStyleActiveIndex];

    return [_ncStyle retrieveStyle:key];
}

@end
