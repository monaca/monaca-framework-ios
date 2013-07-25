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
#import "MFViewManager.h"

@implementation MFTabBarController

@synthesize ncManager = _ncManager;
@synthesize uidict = _uidict;
@synthesize backButton = _backButton;
@synthesize type;

// iOS4 の場合、このメソッドは MonacaViewController の viewDidApper メソッドから呼ばれる
- (void)viewWillAppear:(BOOL)animated {
    [self.navigationController setToolbarHidden:YES];
    [super viewWillAppear:animated];
    if (!_isload) {
        _isload = YES;
        NSDictionary *top = [_uidict objectForKey:kNCPositionTop];
        NSMutableDictionary *style = [NSMutableDictionary dictionary];
        [style addEntriesFromDictionary:[_uidict objectForKey:kNCTypeStyle]];
        [style addEntriesFromDictionary:[_uidict objectForKey:kNCTypeIOSStyle]];
        
        if ([[top objectForKey:kNCTypeContainer] isEqualToString:kNCContainerToolbar]) {
            _navigationBar = [[NCNavigationBar alloc] initWithViewController:(id)self];
            [self.ncManager setComponent:_navigationBar forID:[top objectForKey:kNCTypeID]];
            [(NCNavigationBar *)_navigationBar createNavigationBar:top];
        }
    }
}

// iOS4 の場合、このメソッドは MonacaViewController の viewDidApper メソッドから呼ばれる
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [_navigationBar applyUserInterface];
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
        _isload = NO;
        self.delegate = self;
    }
    return self;
}

- (void)destroy
{

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

- (void)tabBarController:(UITabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController
{
    MFViewController *vc = (MFViewController *)viewController;
    NSString *path = [vc.startWwwFolder stringByAppendingPathComponent:vc.startPage];
    [vc.webView loadRequest:[NSURLRequest requestWithURL:[NSURL fileURLWithPath:path]]];
}

#pragma mark - UIStyleProtocol

- (void)setUserInterface:(NSDictionary *)uidict
{
    [_ncStyle setStyles:uidict];
}

- (void)applyUserInterface
{
    for (id key in [_ncStyle styles]) {
        [self updateUIStyle:[[_ncStyle styles] objectForKey:key] forKey:key];
    }
}

- (void)updateUIStyle:(id)value forKey:(NSString *)key
{
    if (![_ncStyle checkStyle:value forKey:key]) {
        return;
    }
    
    if (value == [NSNull null]) {
        value = kNCUndefined;
    }
    if ([NSStringFromClass([[_ncStyle.styles valueForKey:key] class]) isEqualToString:@"__NSCFBoolean"]) {
        if (isFalse(value)) {
            value = kNCFalse;
        } else {
            value = kNCTrue;
        }
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
