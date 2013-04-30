//
//  NCTitleView.m
//  MonacaFramework
//
//  Created by Nakagawa Hiroki on 11/12/22.
//  Copyright (c) 2011年 ASIAL CORPORATION. All rights reserved.
//

#import "NCTitleView.h"
#import "MFDelegate.h"
#import "UILabel+Resize.h"
#import "MFDevice.h"
#import "MFUtility.h"


@implementation NCTitleLabel

@synthesize fontScale = fontScale_;

@end


@implementation NCTitleView

@synthesize titleLabel = titleLabel_;
@synthesize subtitleLabel = subtitleLabel_;

static const CGFloat kSizeOfTitleFont             = 14.0f;
static const CGFloat kSizeOfSubtitleFont          = 11.0f;
static const CGFloat kSizeOfLandscapeTitleFont    = 18.0f;
static const CGFloat kSizeOfPortraitTitleFont     = 19.0f;

static NCTitleLabel *
labelForTitle(NSString *title, UIColor *color, CGFloat fontScale) {
    NCTitleLabel *label = [[NCTitleLabel alloc] init];
    label.fontScale = fontScale;
    label.text = title;
    label.textColor = color;
    label.backgroundColor = [UIColor clearColor];
    label.textAlignment = UITextAlignmentCenter;
    return label;
}

static NCTitleLabel *
labelForSubtitle(NSString *subtitle, UIColor *color, CGFloat fontScale) {
    NCTitleLabel *label = [[NCTitleLabel alloc] init];
    label.fontScale = fontScale;
    label.text = subtitle;
    label.textColor = color;
    label.backgroundColor = [UIColor clearColor];
    label.textAlignment = UITextAlignmentCenter;
    return label;
}

- (id)init {
    self = [super init];
    if (nil != self) {
        self.contentMode = UIViewContentModeCenter;
    }
    return self;
}

- (void)dealloc {
    self.titleLabel = nil;
    self.subtitleLabel = nil;
}

- (void)setTitle:(NSString *)title color:(UIColor *)color scale:(CGFloat)scale {
    self.titleLabel = labelForTitle(title, color, scale);
    [self addSubview:self.titleLabel];
    [self sizeToFit];
}

- (void)setSubtitle:(NSString *)subtitle color:(UIColor *)color scale:(CGFloat)scale {
    self.subtitleLabel = labelForSubtitle(subtitle, color, scale);
    [self addSubview:self.subtitleLabel];
    [self sizeToFit];
}

static BOOL
isEmpty(NCTitleLabel *label) {
    return !label.text || [label.text isEqualToString:@""];
}

// Override.
- (void)setFrame:(CGRect)frame {
    MFDelegate *delegate = ((MFDelegate *)[UIApplication sharedApplication].delegate);
    CGFloat height = [MFDevice heightOfNavigationBar:[MFUtility currentInterfaceOrientation]];
    [super setFrame:CGRectMake(0, 0, 0, height)];

    CGPoint center = self.center;
    CGPoint naviCenter = delegate.viewController.tabBarController.navigationController.navigationBar.center;
    self.center = CGPointMake(naviCenter.x, center.y);

    if (UIInterfaceOrientationIsLandscape([MFUtility currentInterfaceOrientation])) {
        self.titleLabel.font = [UIFont boldSystemFontOfSize:kSizeOfLandscapeTitleFont * self.titleLabel.fontScale];
        self.titleLabel.frame = [self.titleLabel resizedFrameWithPoint:CGPointMake(0, 0)];
        self.titleLabel.center = CGPointMake(self.frame.size.width/2.0f, height/2.0f);
    } else {
        if (!isEmpty(self.subtitleLabel)) {
            self.titleLabel.font = [UIFont boldSystemFontOfSize:kSizeOfTitleFont * self.titleLabel.fontScale];
            self.subtitleLabel.font = [UIFont systemFontOfSize:kSizeOfSubtitleFont * self.subtitleLabel.fontScale];
            self.titleLabel.frame = [self.titleLabel resizedFrameWithPoint:CGPointMake(0, 0)];
            self.subtitleLabel.frame = [self.subtitleLabel resizedFrameWithPoint:CGPointMake(0, 0)];
            self.titleLabel.center = CGPointMake(self.frame.size.width/2.0f, 30);
            self.subtitleLabel.center = CGPointMake(self.frame.size.width/2.0f, 12);
        } else {
            self.titleLabel.font = [UIFont boldSystemFontOfSize:kSizeOfPortraitTitleFont * self.titleLabel.fontScale];
            self.titleLabel.frame = [self.titleLabel resizedFrameWithPoint:CGPointMake(0, 0)];
            self.titleLabel.center = CGPointMake(self.frame.size.width/2.0f, height/2.0f);
        }
    }

    self.titleLabel.frame = CGRectIntegral(self.titleLabel.frame);
    self.subtitleLabel.frame = CGRectIntegral(self.subtitleLabel.frame);
}

@end
