//
//  MonacaTabBarController+Bottom.m
//  MonacaFramework
//
//  Created by Nakagawa Hiroki on 12/02/17.
//  Copyright (c) 2012年 ASIAL CORPORATION. All rights reserved.
//

#import "MonacaTabBarController+Bottom.h"

/*
 * Supports iOS4. Cannot use setTintColor method in iOS4.
 */
static void
setBackgroundColor(NSArray *components, NCToolbar *toolbar) {
    for (int i = 0; i < [components count]; i++) {
        NSDictionary *style_def = [(NSDictionary *)[components objectAtIndex:i] objectForKey:kNCTypeStyle];
        UIView *view = [[toolbar subviews] objectAtIndex:i];
        
        // Register component's view.
        NSString *cid = [(NSDictionary *)[components objectAtIndex:i] objectForKey:kNCTypeID];
        if (cid) {
            [[Utility currentTabBarController].viewDict setObject:view forKey:cid];
        }
        [NCButtonBuilder setUpdatedTag:view];
        
        NSString *bgColor = [style_def objectForKey:kNCStyleBackgroundColor];
        if (bgColor) {
            UIColor *color = hexToUIColor(removeSharpPrefix(bgColor), 1);
            if([view respondsToSelector:@selector(setTintColor:)]){
                [view performSelector:@selector(setTintColor:) withObject:color];
            }
        }
        [view setHidden:isFalse([style_def objectForKey:kNCStyleVisibility])];
    }
}

/*
 * Creates a filepath from relative path and current directory.
 */
static NSString *
stringByRelativePath(NSString *relativePath) {
    MonacaDelegate *delegate = (MonacaDelegate *)[UIApplication sharedApplication].delegate;
    
    BOOL isDir;
    NSFileManager *fm = [NSFileManager defaultManager];
    NSURL *currentURL = delegate.viewController.cdvViewController.webView.request.URL;
    
    [fm fileExistsAtPath:[currentURL path] isDirectory:&isDir];
    if (isDir) {
        return [[currentURL absoluteString] stringByAppendingPathComponent:relativePath];
    }
    return [[[currentURL absoluteString] stringByDeletingLastPathComponent] stringByAppendingPathComponent:relativePath];
}



@implementation MonacaTabBarController (Bottom)

#pragma mark - Bottom toolbar

- (NSMutableDictionary *)dictionaryWithBottomBarStyle {
    return [[self.ncManager.properties objectForKey:kNCPositionBottom] objectForKey:kNCTypeStyle];
}

- (NSMutableDictionary *)dictionaryWithBottomBar {
    return [self.ncManager.properties objectForKey:kNCPositionBottom];
}

+ (UIToolbar *)updateBottomToolbar:(UIToolbar *)toolbar with:(NSDictionary *)style {
    // Visibility.
    UINavigationController *navController = ((MonacaDelegate *)[UIApplication sharedApplication].delegate).viewController.tabBarController.navigationController;
    BOOL hidden = isFalse([style objectForKey:kNCStyleVisibility]);
    
    if (!hidden && navController.toolbarHidden) {
        [navController setToolbarHidden:NO animated:NO];
    }
    
    
    if (hidden != toolbar.hidden) {
        if (toolbar.hidden) {
        
             if (!toolbar.translucent) {
                 
                 /*
                 CGRect rect = toolbar.superview.frame;
                 rect.size.height = rect.size.height - toolbar.frame.size.height;
                 
                 toolbar.superview.frame = rect;
                 */
                 toolbar.hidden = NO;
                 toolbar.alpha = 1.0f;
                 [navController setToolbarHidden:NO animated:NO];
             } else {
                // Show the bottom toolbar.
                [UIView animateWithDuration:0.3f
                                      delay:0.0f
                                    options:UIViewAnimationOptionCurveEaseOut | UIViewAnimationOptionAllowUserInteraction
                                 animations:^{
                                     toolbar.alpha = 0.0f;
                                     toolbar.hidden = NO;
                                     toolbar.alpha = 1.0f;
                                     
                                 } completion:^(BOOL finished) {
                                 }];
                 
             }
        } else {
            // Hide the bottom toolbar.
                             
            if (!toolbar.translucent) {
                // hide bottom toolbar without animations.
                /*j
                CGRect rect = toolbar.superview.frame;
                rect.size.height += toolbar.frame.size.height;
                toolbar.superview.frame = rect;
                */
                toolbar.hidden = YES;
                [navController setToolbarHidden:YES animated:NO];
            } else {
                [UIView animateWithDuration:0.3f
                                      delay:0.0f
                                    options:UIViewAnimationOptionCurveEaseOut | UIViewAnimationOptionAllowUserInteraction
                                 animations:^{
                                     toolbar.alpha = 0.0f;
                                     toolbar.hidden = NO;
                                 }
                                 completion:^(BOOL finished){
                                     toolbar.hidden = YES;
                                 }];
            }
            
        }
    }
    
    // Opacity.
    NSString *opacity = [style objectForKey:kNCStyleOpacity];
    if (opacity) {
        // NOTE(nhiroki): Ignore the given opacity (alpha) parameter because buttons included
        // in this toolbar also become transparent when set the parameter.
        // float alpha = [opacity floatValue];
        [toolbar setTranslucent:YES];
        //[toolbar setAlpha:1.0f];
    } else {
        [toolbar setTranslucent:NO];
        //[toolbar setAlpha:1.0f];
    }
    
    
    // Give priority to the ios-style property than the backgroundColor property.
    NSString *iosStyle = [style objectForKey:kNCStyleIOSBarStyle];
    if (iosStyle) {
        [toolbar setTranslucent:NO];
        if ([iosStyle isEqualToString:@"UIBarStyleBlack"]) {
            [toolbar setBarStyle:UIBarStyleBlack];
        } else if ([iosStyle isEqualToString:@"UIBarStyleBlackOpaque"]) {
            [toolbar setBarStyle:UIBarStyleBlack];
        } else if ([iosStyle isEqualToString:@"UIBarStyleBlackTranslucent"]) {
            //[toolbar setBarStyle:UIBarStyleBlack];
            [toolbar setBarStyle:UIBarStyleBlackTranslucent];
            [toolbar setTranslucent:YES];
        } else if ([iosStyle isEqualToString:@"UIBarStyleDefault"]) {
            [toolbar setBarStyle:UIBarStyleDefault];
        }
    } else {
        NSString *toolbarColor = [style objectForKey:kNCStyleBackgroundColor];
        if (toolbarColor) {
            UIColor *bgColor = hexToUIColor(removeSharpPrefix(toolbarColor), 1);
            toolbar.tintColor = bgColor;
        }
    }
    
    return toolbar;
}

- (void)applyBottomToolbar:(NSDictionary *)uidict {
    // Store a reference to the object representing the native component.
    NSString *cid = [uidict objectForKey:kNCTypeID];
    [self.ncManager setComponent:self.navigationController.toolbar forID:cid];
    
    NSMutableDictionary *style = [NSMutableDictionary dictionary];
    [style addEntriesFromDictionary:[uidict objectForKey:kNCTypeStyle]];
    [style addEntriesFromDictionary:[uidict objectForKey:kNCTypeIOSStyle]];
    
    [[self class] updateBottomToolbar:self.navigationController.toolbar with:style];
    [self setToolbarItems:nil];
    NSArray *components;
    
    NSMutableArray *items;
    NCToolbar *toolbar;
    NSMutableArray *icons = [NSMutableArray array];
    
    UIBarButtonItem *spacer =
    [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil] autorelease];
    
    // Adjust UIToolBar left and right margin.
    static const double kMargin = -12.0f;
    UIBarButtonItem *negativeSpacer = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil] autorelease];
    negativeSpacer.width = kMargin;
    
    // Left side components.
    components = [uidict objectForKey:kNCTypeLeft];
    if (nil != components) {
        items = [NSMutableArray array];
        self.leftBottomToolbarContainers = [self createContainers:components position:kNCPositionBottom];
        for (NCContainer *container in leftBottomToolbarContainers_) {
            [items addObject:container.component];
        }
        
        toolbar = [[[NCToolbar alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 0.0f, 44.0f)] autorelease];
        [toolbar setBackgroundColor:[UIColor clearColor]];
        toolbar.autoresizingMask = UIViewAutoresizingFlexibleHeight;
        toolbar.items = items;
        [toolbar sizeToFit];
        
        setBackgroundColor(components, toolbar);
        
        [icons addObject:negativeSpacer];
        [icons addObject:[[[UIBarButtonItem alloc] initWithCustomView:toolbar] autorelease]];
        [icons addObject:spacer];
    }
    
    // Center side components.
    components = [uidict objectForKey:kNCTypeCenter];
    if (nil != components) {
        BOOL isCenterOnly = (![uidict objectForKey:kNCTypeLeft] && ![uidict objectForKey:kNCTypeRight]);
        items = [NSMutableArray array];
        self.centerBottomToolbarContainers = [self createContainers:components position:kNCPositionBottom];
        for (NCContainer *container in centerBottomToolbarContainers_) {
            if (isCenterOnly) {
                [items addObject:spacer];
            }
            [items addObject:container.component];
        }
        
        CGRect frame = CGRectMake(0.0f, 0.0f, 0.0f, 44.0f);
        if (isCenterOnly) {
            UIInterfaceOrientation orientation = [Utility currentInterfaceOrientation];
            double width = [Device widthOfWindow:orientation];
            double height = [Device heightOfNavigationBar:orientation];
            frame = CGRectMake(0, 0, width + kMargin * 2, height);
        }
        
        toolbar = [[[NCToolbar alloc] initWithFrame:frame] autorelease];
        [toolbar setBackgroundColor:[UIColor clearColor]];
        toolbar.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
        
        if (isCenterOnly) {
            [items addObject:spacer];
        } else {
            [toolbar sizeToFitCenter];
        }
        
        toolbar.items = items;
        setBackgroundColor(components, toolbar);
        
        if (isCenterOnly) {
            //[icons addObject:[[[UIBarButtonItem alloc] initWithCustomView:toolbar] autorelease]];
            // Fixed side margin
            icons = items;
        } else {
            if (![uidict objectForKey:kNCTypeLeft]) {
                [icons addObject:spacer];
            }
            [icons addObject:[[[UIBarButtonItem alloc] initWithCustomView:toolbar] autorelease]];
            if (![uidict objectForKey:kNCTypeRight]) {
                [icons addObject:spacer];
            }
        }
    }
    
    // Right side components.
    components = [uidict objectForKey:kNCTypeRight];
    if (nil != components) {
        items = [NSMutableArray array];
        self.rightBottomToolbarContainers = [self createContainers:components position:kNCPositionBottom];
        for (NCContainer *container in rightBottomToolbarContainers_) {
            [items addObject:container.component];
        }
        
        toolbar = [[[NCToolbar alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 0.0f, 44.0f)] autorelease];
        [toolbar setBackgroundColor:[UIColor clearColor]];
        toolbar.autoresizingMask = UIViewAutoresizingFlexibleHeight;
        toolbar.items = items;
        [toolbar sizeToFit];
        
        setBackgroundColor(components, toolbar);
        
        [icons addObject:spacer];
        [icons addObject:[[[UIBarButtonItem alloc] initWithCustomView:toolbar] autorelease]];
        [icons addObject:negativeSpacer];
    }
    
    [self setToolbarItems:icons];
}



#pragma mark - Bottom tabbar

- (void)showTabBar:(BOOL)visible {
    BOOL ignoreStatusbarHeight = [UIApplication sharedApplication].statusBarStyle == UIStatusBarStyleBlackTranslucent || [UIApplication sharedApplication].statusBarHidden;
    UIInterfaceOrientation orientation = [Utility currentInterfaceOrientation];
    double heightOfWindow = [Device heightOfWindow:orientation];
    
    const float kHeightOfStatusBar     = ignoreStatusbarHeight ? 0 : [Device heightOfStatusBar];
    const float kHeightOfWindow        = heightOfWindow - kHeightOfStatusBar;
    const float kHeightOfNavigationBar = [Device heightOfNavigationBar:orientation];
    //ステータスバーが透明の時は、タブバーの高さが無い、については一旦外します。 katsuya
    //const float kHeightOfTabBar        = ignoreStatusbarHeight ? 0 : [Device heightOfTabBar];
    const float kHeightOfTabBar        = [Device heightOfTabBar];
    const float kHeightOfToolBar       = kHeightOfNavigationBar;
    
    BOOL isToolbarHidden = self.navigationController.toolbarHidden;
    BOOL isToolbarTranslucent = self.navigationController.toolbar.translucent;
    
    BOOL _navigationBarHidden = self.navigationController.navigationBarHidden;
    BOOL _navigationBarTranslucent = self.navigationController.navigationBar.translucent;
    BOOL navigationBarHidden = _navigationBarHidden || _navigationBarTranslucent || ignoreStatusbarHeight;

    CGFloat heigthOfView = kHeightOfWindow;
    if (!isToolbarTranslucent && !isToolbarHidden) {
        heigthOfView -= kHeightOfToolBar;
    }

    // Resize the frame of the MonacaTabBarController's view.
    // It is because the view has wrong height value after memory warning occurs.
    if (!navigationBarHidden) {
        heigthOfView -= kHeightOfNavigationBar;
    }

    CGRect rect = self.view.frame;
    [self.view setFrame:CGRectMake(rect.origin.x, rect.origin.y, rect.size.width, heigthOfView)];

    for(UIView *view in self.view.subviews) {
        CGRect frame = view.frame;
        
        if([view isKindOfClass:[UITabBar class]]) {
            float ypos;
            if (visible) {
                if (navigationBarHidden) {
                    ypos = kHeightOfWindow - kHeightOfTabBar;
                } else {
                    ypos = kHeightOfWindow - kHeightOfNavigationBar - kHeightOfTabBar; // 367
                }
            } else {
                ypos = kHeightOfWindow;
            }
            
            frame.size.height = kHeightOfTabBar;
            frame.origin.y = ypos;
        } else {
            float height;
            if (visible) {
                if (navigationBarHidden) {
                    height = kHeightOfWindow - kHeightOfTabBar;
                } else {
                    height = kHeightOfWindow - kHeightOfNavigationBar - kHeightOfTabBar;
                }
            } else {
                if (navigationBarHidden) {
                    height = kHeightOfWindow;
                } else {
                    height = kHeightOfWindow - kHeightOfNavigationBar;
                    //if (self.navigationController.navigationBar.translucent) {
                    //    height += kHeightOfNavigationBar;
                    //}
                }
            }
            
            if (!isToolbarHidden && !isToolbarTranslucent) {
                height -= kHeightOfToolBar;
            }
            
            frame.origin.y = 0;
            frame.size.height = height;
        }

        [view setFrame:frame];
    }
}

- (void)applyBottomTabbar:(NSDictionary *)uidict {
    NSMutableDictionary *bottomBarStyle = [NSMutableDictionary dictionaryWithDictionary:[self dictionaryWithBottomBarStyle]];
    [bottomBarStyle addEntriesFromDictionary:uidict];
    
    MonacaDelegate *delegate = (MonacaDelegate *)[UIApplication sharedApplication].delegate;
    [delegate.viewController.tabBarController.navigationController setToolbarHidden:YES];
    self.delegate = self;
    
    CGRect frame = delegate.viewController.cdvViewController.webView.frame;
    
    NSMutableArray *controllers = [NSMutableArray array];
    NSArray *items = [bottomBarStyle objectForKey:kNCTypeItems];
    
    int i = 0;
    for (NSDictionary *item in items) {
        NSMutableDictionary *style = [NSMutableDictionary dictionary];
        [style addEntriesFromDictionary:[item objectForKey:kNCTypeStyle]];
        [style addEntriesFromDictionary:[item objectForKey:kNCTypeIOSStyle]];
        
        // Setup a view controller in the tab contoller.
        UIViewController *controller = [[[UIViewController alloc] init] autorelease];
        [controller.view setAutoresizesSubviews:YES];
        controller.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        
        // Setup tabbar item.
        controller.tabBarItem = [NCTabbarItemBuilder tabbarItem:style];
        controller.tabBarItem.tag = i;
        
        [controllers addObject:controller];
        
        // Store a reference to the object representing the native component.
        NSString *cid = [item objectForKey:kNCTypeID];
        [self.ncManager setComponent:controller.tabBarItem forID:cid];
        i++;
    }
    [((UIViewController *)[controllers objectAtIndex:0]).view addSubview:delegate.viewController.cdvViewController.webView];
    
    NSString *tabbarId = [bottomBarStyle objectForKey:kNCTypeID];
    if (tabbarId != nil) {
        [self.ncManager setComponent:self forID:tabbarId];
    }
    
    [self setViewControllers:controllers animated:NO];
    
    // 指定されたタブをアクティブにする。isInitialized フラグによって、メモリ破壊後にこのメソッドが呼ばれた時に
    // UI ファイルの値を使用しないようにし、最後に見ていたタブをアクティブにする。
    NSMutableDictionary *style = [bottomBarStyle objectForKey:kNCTypeStyle];
    NSString *activeIndex = [style objectForKey:kNCStyleActiveIndex];
    if (activeIndex && !isInitialized_) {
        self.activeIndex = [activeIndex intValue];
        [self setSelectedIndex:self.activeIndex];
        [delegate.viewController.cdvViewController.webView removeFromSuperview];
        [((UIViewController *)[controllers objectAtIndex:self.activeIndex]).view addSubview:delegate.viewController.cdvViewController.webView];
        isInitialized_ = YES;
    }
    
    // Resize the webview because |setViewController| method modified the size.
    delegate.viewController.cdvViewController.webView.frame = frame;
    
    [self showTabBar:!isFalse([style objectForKey:kNCStyleVisibility])];
}


+ (void)updateBottomTabbarStyle:(MonacaTabBarController *)tabbarController with:(NSDictionary *)style {
    BOOL invisible = isFalse([style objectForKey:kNCStyleVisibility]);
    
    if (invisible) {
        [tabbarController showTabBar:NO];
    } else {
        [tabbarController showTabBar:YES];
    }
    
}

- (void)tabBarController:(UITabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController {
    if (isLocked_ == NO) {
        isLocked_ = YES;
        selectedTab_ = tabBarController.selectedIndex;

        MonacaDelegate *delegate = (MonacaDelegate *)[UIApplication sharedApplication].delegate;
        [delegate.viewController.cdvViewController.webView removeFromSuperview];
        [viewController.view addSubview:delegate.viewController.cdvViewController.webView];

        self.activeIndex = self.selectedIndex;
        NSArray *items = [[self dictionaryWithBottomBar] objectForKey:kNCTypeItems];
        NSString *relativePath = [[items objectAtIndex:self.activeIndex] objectForKey:kNCTypeLink];
        NSString *linkpath = stringByRelativePath(relativePath);

        // Load link url page.
        NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:linkpath]];
        delegate.viewController.cdvViewController.webView.tag = kWebViewIgnoreStyle;
        [delegate.viewController.cdvViewController.webView loadRequest:request];
    }
    tabBarController.selectedIndex = selectedTab_;
}

- (void)hideTabbar {
    //transitのリンクに影響?
//    [self setViewControllers:nil animated:NO];
    [self showTabBar:NO];
}

@end
