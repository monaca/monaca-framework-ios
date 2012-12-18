//
//  MFTabBarController+Top.m
//  MonacaFramework
//
//  Created by Nakagawa Hiroki on 12/02/17.
//  Copyright (c) 2012年 ASIAL CORPORATION. All rights reserved.
//

#import "MFTabBarController+Top.h"


// Supports iOS4. Cannot use setTintColor method in iOS4.
static void
setBackgroundColor(NSArray *components, NCToolbar *toolbar) {
    for (int i = 0; i < [components count]; i++) {
        NSDictionary *style_def = [(NSDictionary *)[components objectAtIndex:i] objectForKey:kNCTypeStyle];
        UIView *view = [[toolbar subviews] objectAtIndex:i];
        
        // Register component's view.
        NSString *cid = [(NSDictionary *)[components objectAtIndex:i] objectForKey:kNCTypeID];
        if (cid) {
            [[MFUtility currentTabBarController].viewDict setObject:view forKey:cid];
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



@implementation MFTabBarController (Top)

- (NSMutableDictionary *)dictionaryWithTopBarStyle {
    NSMutableDictionary *style = [[self.ncManager.properties objectForKey:kNCPositionTop] objectForKey:kNCTypeStyle];
    [style addEntriesFromDictionary:[[self.ncManager.properties objectForKey:kNCPositionTop] objectForKey:kNCTypeIOSStyle]];
    return style;
}

// Set left side component on the toolbar.
- (void)setLeftComponent:(NSArray *)components {
    NSMutableArray *items = [NSMutableArray array];
    
    self.leftContainers = [self createContainers:components position:kNCPositionTop];
    
    for (NCContainer *container in self.leftContainers) {
        [items addObject:container.component];
    }
    
    UIInterfaceOrientation orientation = [MFUtility currentInterfaceOrientation];
    double width = [MFDevice widthOfWindow:orientation];
    double height = [MFDevice heightOfNavigationBar:orientation];
    NCToolbar *toolbar = [[NCToolbar alloc] initWithFrame:CGRectMake(0.0f, 0.0f, width, height)];
    [toolbar setBackgroundColor:[UIColor clearColor]];
    toolbar.autoresizingMask = UIViewAutoresizingFlexibleHeight;
    UIBarButtonItem *toolbarBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:toolbar];
    toolbar.items = items;
    [toolbar sizeToFit];
    
    setBackgroundColor(components, toolbar);
    
    // Adjust button position
    CGRect bounds = [toolbar bounds];
    bounds.origin.y = 1.0f;
    toolbar.bounds = bounds;
    
    // Adjust UIToolBar left margin.
    static const double kMargin = -5.0f;
    UIBarButtonItem *negativeSpacer = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    negativeSpacer.width = kMargin;
    
    // iOS4 cannot use leftBarButtonItems.
    self.navigationItem.leftBarButtonItem = toolbarBarButtonItem;
    //self.navigationItem.leftBarButtonItems = [NSArray arrayWithObjects:negativeSpacer, toolbarBarButtonItem, nil];
}

// Set right side component on the toolbar.
- (void)setRightComponent:(NSArray *)components {
    NSMutableArray *items = [NSMutableArray array];
    
    self.rightContainers = [self createContainers:components position:kNCPositionTop];
    if (self.rightContainers.count == 1) {
        NCContainer *container = [self.rightContainers objectAtIndex:0];
        self.navigationItem.rightBarButtonItem = container.component;
        return;
    }
    
    for (NCContainer *container in self.rightContainers) {
        [items addObject:container.component];
    }
    
    UIInterfaceOrientation orientation = [MFUtility currentInterfaceOrientation];
    double width = [MFDevice widthOfWindow:orientation];
    double height = [MFDevice heightOfNavigationBar:orientation];
    NCToolbar *toolbar = [[NCToolbar alloc] initWithFrame:CGRectMake(0.0f, 0.0f, width, height)];
    [toolbar setBackgroundColor:[UIColor clearColor]];
    toolbar.autoresizingMask = UIViewAutoresizingFlexibleHeight;
    UIBarButtonItem *toolbarBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:toolbar];
    
    toolbar.items = items;
    [toolbar sizeToFit];
    
    setBackgroundColor(components, toolbar);
    
    // Adjust button position
    CGRect bounds = [toolbar bounds];
    bounds.origin.y = 1.0f;
    toolbar.bounds = bounds;
    
    // Adjust UIToolBar right margin.
    static const double kMargin = -5.0f;
    UIBarButtonItem *negativeSpacer = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    negativeSpacer.width = kMargin;
    
    // iOS4 cannot use rightsBarButtonItems.
    self.navigationItem.rightBarButtonItem = toolbarBarButtonItem;
    //self.navigationItem.rightBarButtonItems = [NSArray arrayWithObjects:negativeSpacer, toolbarBarButtonItem, nil];
}

// Set center component on the toolbar.
// NOTE: Center component (titleView) requires an UIView object.
- (void)setCenterComponent:(NSArray *)components {
    // FIXME: Use only the first component.
    NSMutableArray *containers = [self createContainers:components position:kNCPositionTop];
    
    // Add null container when toolbar has 0 components.
    if ([components count]==0) {
        NCContainer *container = [[NCContainer alloc] init];
        [containers addObject:container];
    }
    self.centerContainer = [containers objectAtIndex:0];
    
    // (mitsunori)ツール・バーのセンターに検索ボックスを置く場合は、コンポーネントの中のsearchBoxを探して、幅を広く取るようにする
    if ([self.centerContainer.type isEqualToString:kNCComponentSearchBox]) {
        [NCSearchBoxBuilder makeWide:((UISearchBar *)self.centerContainer.component.customView)];
    }
    
    self.navigationItem.titleView = self.centerContainer.view;
        
    // Store a reference to the object representing the native component.
    [self.ncManager setComponent:self.centerContainer forID:self.centerContainer.cid];
}

- (BOOL)hasTitleView {
    NSMutableDictionary *topBarStyle = [self dictionaryWithTopBarStyle];
    NSString *title = [topBarStyle objectForKey:kNCStyleTitle];
    NSString *subtitle = [topBarStyle objectForKey:kNCStyleSubtitle];
    return title || subtitle;
}

- (void)changeTitleView {
    NSMutableDictionary *topBarStyle = [self dictionaryWithTopBarStyle];
    NSString *title = [topBarStyle objectForKey:kNCStyleTitle];
    NSString *subtitle = [topBarStyle objectForKey:kNCStyleSubtitle];
    
    if ((title && [title length] > 0) || (subtitle && [subtitle length] > 0)) {
        NSString *titleColor = [topBarStyle objectForKey:kNCStyleTitleColor];
        NSString *subtitleColor = [topBarStyle objectForKey:kNCStyleSubtitleColor];
        
        CGFloat titleFontScale = 1.0f;
        NSString *scale = [topBarStyle objectForKey:kNCStyleTitleFontScale];
        if (scale) {
            titleFontScale = [scale floatValue];
        }
        CGFloat subtitleFontScale = 1.0f;
        scale = [topBarStyle objectForKey:kNCStyleSubtitleFontScale];
        if (scale) {
            subtitleFontScale = [scale floatValue];
        }
        
        NCTitleView *titleView = [[NCTitleView alloc] init];
        
        if (!titleColor || [titleColor isEqualToString:@""]) {
            [titleView setTitle:title color:[UIColor whiteColor] scale:titleFontScale];
        } else {
            [titleView setTitle:title color:hexToUIColor(removeSharpPrefix(titleColor), 1) scale:titleFontScale];
        }
        
        if (!subtitleColor || [subtitleColor isEqualToString:@""]) {
            [titleView setSubtitle:subtitle color:[UIColor whiteColor] scale:subtitleFontScale];
        } else {
            [titleView setSubtitle:subtitle color:hexToUIColor(removeSharpPrefix(subtitleColor), 1) scale:subtitleFontScale];
        }
    
        self.navigationItem.titleView = titleView;
        self.navigationItem.title = nil;
    }
}

- (MFTabBarController *)applyTopToolbar:(NSDictionary *)style {
    // Visibility.
    BOOL hidden = isFalse([style objectForKey:kNCStyleVisibility]);
    if (hidden != self.navigationController.navigationBar.hidden) {
        if (self.navigationController.navigationBar.hidden) {
        
            if (!self.navigationController.navigationBar.translucent) {
                // Show the navigation bar without animation.
                CGRect rect = self.view.superview.frame;
                int toolbarHeight = self.navigationController.navigationBar.frame.size.height;
                rect.origin.y += toolbarHeight;
                rect.size.height = rect.size.height - toolbarHeight;
                self.navigationController.navigationBar.hidden = NO;
             
                self.view.superview.frame = rect;
            } else {
                // Show the navigation bar.
                [UIView animateWithDuration:0.3f
                                      delay:0.0f
                                    options:UIViewAnimationOptionCurveEaseOut | UIViewAnimationOptionAllowUserInteraction
                                 animations:^{
                                     
                                     self.navigationController.navigationBar.hidden = NO;
                                     self.navigationController.navigationBar.alpha = 0.0f;
                                     self.navigationController.navigationBar.alpha = 1.0f;
                                     
                                 } completion:^(BOOL finished) {
                                 
                                     
                                 }];
            }
        } else {
            if (!self.navigationController.navigationBar.translucent) {
                // Hide toolbar without animation.
                CGRect rect = self.view.superview.frame;
                int toolbarHeight = self.navigationController.navigationBar.frame.size.height;
                rect.origin.y -= toolbarHeight;
                rect.size.height = rect.size.height + toolbarHeight;
                
                self.view.superview.frame = rect;
             self.navigationController.navigationBar.hidden = YES;
            } else {
            // Hide the navigation bar.
                [UIView animateWithDuration:0.3f
                                      delay:0.0f
                                    options:UIViewAnimationOptionCurveEaseOut | UIViewAnimationOptionAllowUserInteraction
                                 animations:^{
                                     self.navigationController.navigationBar.alpha = 0.0f;
                                 } completion:^(BOOL finished) {
                                     self.navigationController.navigationBar.hidden = YES;
                                     
                                 }];
            }
                             
        }
    }
    
    // Opacity.
    NSString *opacity = [style objectForKey:kNCStyleOpacity];
    float alpha = [opacity floatValue];
    if (opacity) {
        if(alpha == 0.0f){
            [self.navigationController.navigationBar setTranslucent:NO];
        } else {
            // NOTE(nhiroki): Ignore the given opacity (alpha) parameter because buttons included
            // in this toolbar also become transparent when set the parameter.
            //float alpha = [opacity floatValue];
            [self.navigationController.navigationBar setTranslucent:YES];
            //[self.navigationController.navigationBar setAlpha:1.0f];
        }
    }
    
    // Give priority to ios-style property than backgroundColor property.
    // FIXME: ios-style が指定されたら UIBarStyle の範囲内でしかスタイルを変えられなくなる
    UINavigationBar *navBar = self.navigationController.navigationBar;
    NSString *iosStyle = [style objectForKey:kNCStyleIOSBarStyle];
    if (iosStyle) {
        [navBar setTranslucent:NO];
        if ([iosStyle isEqualToString:@"UIBarStyleBlack"]) {
            [navBar setBarStyle:UIBarStyleBlack];
        } else if ([iosStyle isEqualToString:@"UIBarStyleBlackOpaque"]) {
            [navBar setBarStyle:UIBarStyleBlack];
        } else if ([iosStyle isEqualToString:@"UIBarStyleBlackTranslucent"]) {
            //[navBar setBarStyle:UIBarStyleBlack];
            [navBar setBarStyle:UIBarStyleBlackTranslucent];
            [navBar setTranslucent:YES];
        } else if ([iosStyle isEqualToString:@"UIBarStyleDefault"]) {
            [navBar setBarStyle:UIBarStyleDefault];
        }
    } else {
        NSString *toolbarColor = [style objectForKey:kNCStyleBackgroundColor];
        if (toolbarColor) {
            UIColor *bgColor = hexToUIColor(removeSharpPrefix(toolbarColor), 1);
            [navBar setTintColor:bgColor];
        }
    }
    
    // Set title and subtitle.
    [self changeTitleView];
    
    return self;
}

- (MFTabBarController *)updateTopToolbar:(NSDictionary *)style {
    NSMutableDictionary *topBarStyle = [NSMutableDictionary dictionaryWithDictionary:[self dictionaryWithTopBarStyle]];
    [topBarStyle addEntriesFromDictionary:style];
    [self applyTopToolbar:topBarStyle];
    return self;
}

- (MFTabBarController *)setTopToolbar:(NSDictionary *)style {
    NSMutableDictionary *topBarStyle = [NSMutableDictionary dictionaryWithDictionary:[self dictionaryWithTopBarStyle]];
    [topBarStyle addEntriesFromDictionary:style];
    [self applyTopToolbar:topBarStyle];
    return self;
}

- (void)apply:(NSDictionary *)uidict {
    id params;
    
    // Toolbar style.
    params = [NSMutableDictionary dictionary];
    [params addEntriesFromDictionary:[uidict objectForKey:kNCTypeStyle]];
    [params addEntriesFromDictionary:[uidict objectForKey:kNCTypeIOSStyle]];
    [self setTopToolbar:params];
    
    // Store a reference to the object representing the native component.
    NSString *cid = [uidict objectForKey:kNCTypeID];
    [self.ncManager setComponent:kNCContainerTabbar forID:cid];
    
    // Left component.
    params = [uidict objectForKey:kNCTypeLeft];
    [self setLeftComponent:params];
    
    // Right component.
    params = [uidict objectForKey:kNCTypeRight];
    [self setRightComponent:params];
    
    // Center component.
    // If title or subtitle property exists, center component will be ignored.
    if (![[uidict objectForKey:kNCTypeStyle] objectForKey:kNCStyleTitle] &&
        ![[uidict objectForKey:kNCTypeStyle] objectForKey:kNCStyleSubtitle]) {
        params = [uidict objectForKey:kNCTypeCenter];
        [self setCenterComponent:params];
    }
}

@end
