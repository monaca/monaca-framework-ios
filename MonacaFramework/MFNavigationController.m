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
        [ncStyle setValue:kNCTrue forKey:kNCStyleVisibility];
        [ncStyle setValue:kNCFalse forKey:kNCStyleDisable];
        [ncStyle setValue:kNCBlack forKey:kNCStyleBackgroundColor];
        [ncStyle setValue:kNCUndefined forKey:kNCStyleTitle];
        [ncStyle setValue:kNCUndefined forKey:kNCStyleSubtitle];
        [ncStyle setValue:kNCWhite forKey:kNCStyleTitleColor];
        [ncStyle setValue:kNCWhite forKey:kNCStyleSubtitleColor];
        [ncStyle setValue:[NSNumber numberWithFloat:1.0]  forKey:kNCStyleTitleFontScale];
        [ncStyle setValue:[NSNumber numberWithFloat:1.0]  forKey:kNCStyleSubtitleFontScale];
        [ncStyle setValue:kNCUndefined forKey:kNCStyleIOSBarStyle];
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
    if ([NSStringFromClass([value class]) isEqualToString:@"__NSCFBoolean"]) {
        if (isFalse(value)) {
            value = kNCFalse;
        } else {
            value = kNCTrue;
        }
    }

    // TODO: implement apply for subtitle
    if ([key isEqualToString:kNCStyleBackgroundColor]) {
        [self.navigationBar setTintColor:hexToUIColor(removeSharpPrefix(value), 1)];
    }
    if ([key isEqualToString:kNCStyleTitle]) {
        [self.topViewController setTitle:value];
    }

    if (value == [NSNull null]) {
        value = nil;
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
