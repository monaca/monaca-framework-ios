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
        [delegate.viewController.cdvViewController.webView removeFromSuperview];
        UIView *view = ((UIViewController *)[self.viewControllers objectAtIndex:self.activeIndex]).view;
        [view addSubview:delegate.viewController.cdvViewController.webView];
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
    [self applyUserInterface:[self.ncManager.properties copy]];
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
