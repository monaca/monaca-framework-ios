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

@implementation MFTabBarController

@synthesize centerContainer = centerContainer_;
@synthesize leftContainers = leftContainers_;
@synthesize rightContainers = rightContainers_;
@synthesize leftBottomToolbarContainers = leftBottomToolbarContainers_;
@synthesize centerBottomToolbarContainers = centerBottomToolbarContainers_;
@synthesize rightBottomToolbarContainers = rightBottomToolbarContainers_;

@synthesize viewDict = viewDict_;
@synthesize ncManager = ncManager_;
@synthesize activeIndex = activeIndex_;
@synthesize isInitialized = isInitialized_;

// iOS4 の場合、このメソッドは MonacaViewController の viewDidApper メソッドから呼ばれる
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self setSelectedIndex:self.activeIndex];
}

// iOS4 の場合、このメソッドは MonacaViewController の viewDidApper メソッドから呼ばれる
- (void)viewDidAppear:(BOOL)animated {
    MFDelegate *delegate = (MFDelegate *)[UIApplication sharedApplication].delegate;
    if ([self.viewControllers count] > 0) {
        [delegate.viewController.webView removeFromSuperview];
        UIView *view = ((UIViewController *)[self.viewControllers objectAtIndex:self.activeIndex]).view;
        [view addSubview:delegate.viewController.webView];
    }
}

- (id)init {
    self = [super init];
    if (nil != self) {
        self.viewDict = [NSMutableDictionary dictionary];
        self.ncManager = [[NCManager alloc] init];
        isLocked = YES;
        isInitialized_ = NO;

        NSNotificationCenter* center = [NSNotificationCenter defaultCenter];
        [center addObserver:self selector:@selector(onWillLoadUIFile:) name:monacaEventWillLoadUIFile object:nil];
        [center addObserver:self selector:@selector(onDidLoadUIFile:) name:monacaEventDidLoadUIFile object:nil];
        [center addObserver:self selector:@selector(onReloadPage:) name:monacaEventReloadPage object:nil];
    }
    return self;
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

- (NSMutableArray *)createContainers:(NSArray *)components position:(NSString *)aPosition {
    NSMutableArray *containers = [NSMutableArray array];
    for (id component in components) {
        NCContainer *container = [NCContainer container:component position:aPosition];
        [containers addObject:container];
        
        // Store a reference to the object representing the native component.
        [self.ncManager setComponent:container forID:container.cid];
    }
    return containers;
}

- (void)applyUserInterface:(NSDictionary *)uidict
{
    id item;
    
    // Clear all component IDs.
    [self.ncManager.components removeAllObjects];
    [self.viewDict removeAllObjects];
    
    [self.ncManager.properties removeAllObjects];
    [self.ncManager.properties addEntriesFromDictionary:uidict];
    
    item = [uidict objectForKey:kNCPositionTop];
    if (nil != item) {
        if ([[item objectForKey:kNCTypeContainer] isEqualToString:kNCContainerToolbar]) {
            [self apply:item];
        }
        [self.navigationController setNavigationBarHidden:NO animated:NO];
    } else {
        [self.navigationController setNavigationBarHidden:YES animated:NO];
    }
    
    item = [uidict objectForKey:kNCPositionBottom];
    if (nil != item) {
        NSString *containerType = [item objectForKey:kNCTypeContainer];
        if ([containerType isEqualToString:kNCContainerToolbar]) {
            [self applyBottomToolbar:item];
            [self hideTabbar];
        } else if ([containerType isEqualToString:kNCContainerTabbar]) {
            [self applyBottomTabbar:item];
        }
    } else {
        // Hides a bottom toolbar and a tabbar.
        [self hideTabbar];
        [self.navigationController setToolbarHidden:YES animated:NO];
        [self setToolbarItems:nil];
    }
}

- (void)applyBottomTabbar:(NSDictionary *)uidict WwwDir:(NSString *)wwwDir
{
    NSMutableArray *viewControllers = [NSMutableArray array];
    NSDictionary *top = [uidict objectForKey:kNCPositionTop];
    NSArray *topRight = [top objectForKey:kNCTypeRight];
    NSDictionary *topRightStyle = [topRight objectAtIndex:0];
    NSDictionary *bottom = [uidict objectForKey:kNCPositionBottom];
    
    NSArray *items = [bottom objectForKey:kNCTypeItems];
    if (nil != top) {
        if ([[top objectForKey:kNCTypeContainer] isEqualToString:kNCContainerToolbar]) {
            [self apply:top];
        }
    }
    self.rightContainers = [NSArray arrayWithObject:[NCContainer container:topRightStyle position:@"top"]];
    int i = 0;
    for (NSDictionary *item in items) {
        NSMutableDictionary *style = [NSMutableDictionary dictionary];
        [style addEntriesFromDictionary:[item objectForKey:kNCTypeStyle]];
        [style addEntriesFromDictionary:[item objectForKey:kNCTypeIOSStyle]];
        
        // Setup a view controller in the tab contoller.
        MFViewController *viewController = [[MFViewController alloc] initWithFileName:[item objectForKey:kNCTypeLink]];
        viewController.wwwFolderName = wwwDir;

        // Setup tabbar item.
        viewController.tabBarItem = [NCTabbarItemBuilder tabbarItem:style];
        viewController.tabBarItem.tag = i;
        
        UINavigationController *navi = [[UINavigationController alloc] initWithRootViewController:viewController];
        viewController.navigationItem.title = [[item objectForKey:kNCTypeStyle] objectForKey:@"text"];

        viewController.navigationItem.rightBarButtonItem = [(NCContainer *)[self.rightContainers objectAtIndex:0] component];
//        viewController.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:[[topRightStyle objectForKey:kNCTypeStyle] objectForKey:@"text"] style:UIBarButtonItemStyleBordered target:self action:nil];
//        viewController.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"button" style:UIBarButtonItemStyleBordered target:nil action:nil];
        if (nil != top) {
            if ([[top objectForKey:kNCTypeContainer] isEqualToString:kNCContainerToolbar]) {
//                [self apply:top];
            }
            [navi setNavigationBarHidden:NO animated:NO];
        } else {
            [navi setNavigationBarHidden:YES animated:NO];
        }
        
        [viewControllers addObject:navi];
        
        // Store a reference to the object representing the native component.
        //        NSString *cid = [item objectForKey:kNCTypeID];
//        [self.ncManager setComponent:rightContainers_ forID:@"tapme-button"];

        i++;
    }
    self.viewControllers  = viewControllers;
}

- (void)hoge
{
    MFNavigationController *navi = [[MFNavigationController alloc] initWithWwwDir:[MFUtility getBaseURL].path];
    [[[MFUtility getAppDelegate] monacaNavigationController] pushViewController:navi.topViewController animated:YES];
}

- (void)fuga
{
    [[[MFUtility getAppDelegate] monacaNavigationController] popViewControllerAnimated:YES];
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

#pragma mark - EventListener

- (void)onWillLoadUIFile:(NSNotificationCenter *)center {
    isLocked = YES;
}

- (void)onDidLoadUIFile:(NSNotificationCenter *)center {
    isLocked = NO;
}
- (void)onReloadPage:(NSNotificationCenter *)center {
    isInitialized_ = NO;
}
@end
