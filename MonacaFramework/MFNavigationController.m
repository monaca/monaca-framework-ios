//
//  MFNavigationController.m
//  MonacaFramework
//
//  Created by Yasuhiro Mitsuno on 2013/02/23.
//  Copyright (c) 2013年 ASIAL CORPORATION. All rights reserved.
//

#import "MFNavigationController.h"
#import "MFUtility.h"
#import "NativeComponents.h"

@interface MFNavigationController ()

@end

@implementation MFNavigationController

- (id)initWithRootViewController:(UIViewController *)rootViewController
{
    self = [super initWithRootViewController:rootViewController];

    if (self) {
        ncStyle = [[NSMutableDictionary alloc] init];
        [ncStyle setValue:@"true" forKey:kNCStyleVisibility];
        [ncStyle setValue:@"false" forKey:kNCStyleDisable];
        [ncStyle setValue:@"#000000" forKey:kNCStyleBackgroundColor];
        [ncStyle setValue:@"" forKey:kNCStyleTitle];
        [ncStyle setValue:@"" forKey:kNCStyleSubtitle];
        [ncStyle setValue:@"#FFFFFF" forKey:kNCStyleTitleColor];
        [ncStyle setValue:@"#FFFFFF" forKey:kNCStyleSubtitleColor];
        [ncStyle setValue:[NSNumber numberWithFloat:1.0]  forKey:kNCStyleTitleFontScale];
        [ncStyle setValue:[NSNumber numberWithFloat:1.0]  forKey:kNCStyleSubtitleFontScale];
        [ncStyle setValue:@"" forKey:kNCStyleIOSBarStyle];
    }

    return self;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    return YES;
}

- (void)loadView
{
    [super loadView];
    self.delegate = self;
}

- (void)viewDidLoad
{
    self.navigationBarHidden = YES;
    CGRect viewBounds = [[UIScreen mainScreen] bounds];
    self.view.frame = viewBounds;
    
    [super viewDidLoad];  
}

#pragma mark - UINavigationControllerDelegate

- (void)pushViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    [super pushViewController:viewController animated:animated];
}

- (UIViewController *)popViewControllerAnimated:(BOOL)animated
{
    return [super popViewControllerAnimated:animated];
}

- (void)navigationController:(UINavigationController *)navigationController
       didShowViewController:(UIViewController *)viewController animated:(BOOL)animated
{

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

    // TODO: implement apply for subtitle
    if ([key isEqualToString:kNCStyleBackgroundColor]) {
        [self.navigationBar setTintColor:hexToUIColor(removeSharpPrefix(value), 1)];
    }
    if ([key isEqualToString:kNCStyleTitle]) {
        [self.topViewController setTitle:value];
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

@end
