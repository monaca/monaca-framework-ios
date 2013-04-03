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

static BOOL ignoreBottom = NO;

+ (void)setIgnoreBottom:(BOOL)ignore
{
    ignoreBottom = ignore;
}

// iOS4 の場合、このメソッドは MonacaViewController の viewDidApper メソッドから呼ばれる
- (void)viewWillAppear:(BOOL)animated {
    [MFUtility setCurrentTabBarController:self];
    [self.navigationController setNavigationBarHidden:YES];
    [super viewWillAppear:animated];
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

- (id)initWithWwwDir:(NSString *)wwwDir path:(NSString *)path
{
    wwwDir = [[MFUtility getBaseURL].path stringByAppendingPathComponent:[MFUtility getWWWShortPath:wwwDir]];
    NSString *uipath = [wwwDir stringByAppendingPathComponent:[MFUtility getUIFileName:path]];
    NSDictionary *uiDict = [MFUtility parseJSONFile:uipath];
    MFNavigationController *navigationController = [MFUtility getAppDelegate].monacaNavigationController;
    
    id item;
    item = [uiDict objectForKey:kNCPositionBottom];
    if (item != nil && !ignoreBottom ) {
        NSString *containerType = [item objectForKey:kNCTypeContainer];
        if ([containerType isEqualToString:kNCContainerToolbar]) {
            self = [[MFTabBarController alloc] init];
            [self applyBottomToolbar:uiDict];
        } else if ([containerType isEqualToString:kNCContainerTabbar]) {
            self = [[MFTabBarController alloc] init];
            [self applyBottomTabbar:uiDict WwwDir:[[MFUtility getWWWShortPath:uipath] stringByDeletingLastPathComponent]];
            [navigationController setNavigationBarHidden:YES];
            [self.moreNavigationController setNavigationBarHidden:NO];
        }
    } else {
        item = [uiDict objectForKey:kNCPositionTop];
        if (item != nil && !ignoreBottom) {
            if ([[item objectForKey:kNCTypeContainer] isEqualToString:kNCContainerToolbar]) {
                MFViewController *viewController = [[MFViewController alloc] initWithFileName:[path lastPathComponent]];
                viewController.wwwFolderName = [[MFUtility getWWWShortPath:uipath] stringByDeletingLastPathComponent];
                self = (id)viewController;
            }
            [navigationController setNavigationBarHidden:NO animated:NO];
        } else {
            MFViewController *viewController = [[MFViewController alloc] initWithFileName:[path lastPathComponent]];
            viewController.wwwFolderName = [[MFUtility getWWWShortPath:uipath] stringByDeletingLastPathComponent];
            [navigationController setNavigationBarHidden:YES animated:NO];
            [MFViewController setWantsFullScreenLayout:NO];
            self = (id)viewController;
        }
        [navigationController setToolbarHidden:YES animated:NO];
        [navigationController setToolbarItems:nil];
    }
    ignoreBottom = NO;
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

- (void)applyBottomTabbar:(NSDictionary *)uidict WwwDir:(NSString *)wwwDir
{
    NSMutableArray *viewControllers = [NSMutableArray array];
    NSDictionary *bottom = [uidict objectForKey:kNCPositionBottom];
    NSDictionary *bottomStyle = [bottom objectForKey:kNCTypeStyle];
    NSArray *items = [bottom objectForKey:kNCTypeItems];
/*    if (nil != top) {
        if ([[top objectForKey:kNCTypeContainer] isEqualToString:kNCContainerToolbar]) {
//            [self apply:top];
        }
    }
 */
    int i = 0;
    for (NSDictionary *item in items) {
        NSMutableDictionary *style = [NSMutableDictionary dictionary];
        [style addEntriesFromDictionary:[item objectForKey:kNCTypeStyle]];
        [style addEntriesFromDictionary:[item objectForKey:kNCTypeIOSStyle]];
        
        NSString *link = [item objectForKey:kNCTypeLink];
        NSString *uipath = [[[MFUtility getBaseURL].path stringByAppendingPathComponent:wwwDir] stringByAppendingPathComponent:[MFUtility getUIFileName:link]];
        NSDictionary *uiDict = [MFUtility parseJSONFile:uipath];
        
        // Setup a view controller in the tab contoller.
        MFViewController *viewController = [[MFViewController alloc] initWithFileName:[item objectForKey:kNCTypeLink]];
        viewController.wwwFolderName = wwwDir;

        NSDictionary *top = [uiDict objectForKey:kNCPositionTop];
        NSDictionary *topStyle = [top objectForKey:kNCTypeStyle];

        
        // Setup tabbar item.
        if ([style objectForKey:kNCStyleText] == nil && [topStyle objectForKey:kNCStyleTitle]) {
            [style setObject:[topStyle objectForKey:kNCStyleTitle] forKey:kNCStyleText];
        }
        
        viewController.tabBarItem = [NCTabbarItemBuilder tabbarItem:style];
        viewController.tabBarItem.tag = i;
        
        MFNavigationController *navi = [[MFNavigationController alloc] initWithRootViewController:viewController];
        [viewControllers addObject:navi];

        if (top != nil) {
            [navi setNavigationBarHidden:NO];
        } else {
            [navi setNavigationBarHidden:YES];
        }
        
        // Store a reference to the object representing the native component.
        //        NSString *cid = [item objectForKey:kNCTypeID];
        
        [self.ncManager setComponent:viewController.tabBarItem forID:@"tapme-button"];
        i++;
    }
    self.viewControllers  = viewControllers;
    self.activeIndex = [[bottomStyle objectForKey:kNCStyleActiveIndex] intValue];
    if (self.activeIndex < 0 || self.activeIndex >= [items count]) {
        self.activeIndex = 0;
    }
    [self setSelectedIndex:self.activeIndex];
}

- (void)hoge
{

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

- (void)tabBarController:(UITabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController
{
    [MFUtility setCurrentViewController:(MFViewController *)viewController];
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
