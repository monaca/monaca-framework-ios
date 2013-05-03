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

@synthesize centerContainer = centerContainer_;
@synthesize leftContainers = leftContainers_;
@synthesize rightContainers = rightContainers_;
@synthesize leftBottomToolbarContainers = leftBottomToolbarContainers_;
@synthesize centerBottomToolbarContainers = centerBottomToolbarContainers_;
@synthesize rightBottomToolbarContainers = rightBottomToolbarContainers_;

@synthesize viewDict = viewDict_;
@synthesize ncManager = ncManager_;

static BOOL ignoreBottom = NO;

+ (void)setIgnoreBottom:(BOOL)ignore
{
    ignoreBottom = ignore;
}

// iOS4 の場合、このメソッドは MonacaViewController の viewDidApper メソッドから呼ばれる
- (void)viewWillAppear:(BOOL)animated {
    [self.navigationController setNavigationBarHidden:YES];
    [super viewWillAppear:animated];
}

// iOS4 の場合、このメソッドは MonacaViewController の viewDidApper メソッドから呼ばれる
- (void)viewDidAppear:(BOOL)animated {
    [MFUtility setCurrentTabBarController:self];
    
    [super viewDidAppear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
    // タブバーが無いviewに遷移した際にはnilにする。
    [MFUtility setCurrentTabBarController:nil];
    
    [super viewDidDisappear:animated];
}

- (id)init {
    self = [super init];
    if (nil != self) {
        self.viewDict = [NSMutableDictionary dictionary];
        self.ncManager = [[NCManager alloc] init];
        ncStyle = [[NSMutableDictionary alloc] init];
        [ncStyle setValue:kNCTrue forKey:kNCStyleVisibility];
        [ncStyle setValue:kNCBlack forKey:kNCStyleBackgroundColor];
        [ncStyle setValue:[NSNumber numberWithInt:0] forKey:kNCStyleActiveIndex];

        NSNotificationCenter* center = [NSNotificationCenter defaultCenter];
        [center addObserver:self selector:@selector(onWillLoadUIFile:) name:monacaEventWillLoadUIFile object:nil];
        [center addObserver:self selector:@selector(onDidLoadUIFile:) name:monacaEventDidLoadUIFile object:nil];
        [center addObserver:self selector:@selector(onReloadPage:) name:monacaEventReloadPage object:nil];
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
    self.centerContainer = nil;
    self.leftContainers = nil;
    self.rightContainers = nil;
    self.leftBottomToolbarContainers = nil;
    self.centerBottomToolbarContainers = nil;
    self.rightBottomToolbarContainers = nil;
    
    self.viewDict = nil;
    
    self.ncManager = nil;
}

- (BOOL) shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)orientation {
    return [MFUtility getAllowOrientationFromPlist:orientation];
}

- (void)applyBottomTabbar:(NSDictionary *)uidict WwwDir:(NSString *)wwwDir
{
    NSMutableArray *viewControllers = [NSMutableArray array];
    NSDictionary *bottom = [uidict objectForKey:kNCPositionBottom];
    NSDictionary *bottomStyle = [bottom objectForKey:kNCTypeStyle];
    NSArray *items = [bottom objectForKey:kNCTypeItems];
    
    int i = 0;
    for (NSDictionary *item in items) {
        NSMutableDictionary *style = [NSMutableDictionary dictionary];
        [style addEntriesFromDictionary:[item objectForKey:kNCTypeStyle]];
        [style addEntriesFromDictionary:[item objectForKey:kNCTypeIOSStyle]];
        
        NSString *link = [item objectForKey:kNCTypeLink];
        NSString *uipath = [[[MFUtility getBaseURL].path stringByAppendingPathComponent:wwwDir] stringByAppendingPathComponent:[MFUtility getUIFileName:link]];
        NSDictionary *uiDict = [MFUtility parseJSONFile:uipath];
        
        // Setup a view controller in the tab contoller.
        // TODO: make viewControllerProtocol
        id viewController;
        viewController = [MFViewBuilder createViewControllerWithPath:[wwwDir stringByAppendingPathComponent:[item objectForKey:kNCTypeLink]]];

        NSDictionary *top = [uiDict objectForKey:kNCPositionTop];
        NSDictionary *topStyle = [top objectForKey:kNCTypeStyle];

        
        // Setup tabbar item.
        if ([style objectForKey:kNCStyleText] == nil && [topStyle objectForKey:kNCStyleTitle]) {
            [style setObject:[topStyle objectForKey:kNCStyleTitle] forKey:kNCStyleText];
        }


        MFNavigationController *navi = [[MFNavigationController alloc] initWithRootViewController:viewController];
        [viewControllers addObject:navi];

        [MFUtility setCurrentViewController:viewController]; // for tabbarItem image
        NCTabbarItem *tabbarItem = [[NCTabbarItem alloc] init];
        [tabbarItem applyUserInterface:style];
        NSString *cid = [item objectForKey:kNCTypeID];
        [self.ncManager setComponent:tabbarItem forID:cid];

        [navi setTabBarItem:tabbarItem];

        if (top != nil) {
            [navi setNavigationBarHidden:NO];
        } else {
            [navi setNavigationBarHidden:YES];
        }
        i++;
    }
    self.viewControllers  = viewControllers;

    [self applyUserInterface:bottomStyle];
    NSString *cid = [bottom objectForKey:kNCTypeID];
    [self.ncManager setComponent:self forID:cid];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self restoreUserInterface];
}

- (void)viewDidUnload {
    [super viewDidUnload];
}

- (void)loadView {
    [super loadView];
}

- (void)restoreUserInterface
{
//    [self applyUserInterface:[self.ncManager.properties copy]];
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

- (void)applyUserInterface:(NSDictionary *)uidict
{
    for (id key in uidict) {
        [self updateUIStyle:[uidict objectForKey:key] forKey:key];
    }
}

#pragma mark - UIStyleProtocol

- (void)updateUIStyle:(id)value forKey:(NSString *)key
{
    if ([ncStyle objectForKey:key] == nil) {
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
    [ncStyle setValue:value forKey:key];
}

- (id)retrieveUIStyle:(NSString *)key
{
    if ([ncStyle objectForKey:key] == nil) {
        // 例外処理
        return nil;
    }

    return [ncStyle objectForKey:key];
}

#pragma mark - EventListener

- (void)onWillLoadUIFile:(NSNotificationCenter *)center {

}

- (void)onDidLoadUIFile:(NSNotificationCenter *)center {

}
- (void)onReloadPage:(NSNotificationCenter *)center {

}
@end
