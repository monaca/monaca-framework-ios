//
//  NCTitleView.m
//  MonacaFramework
//
//  Created by Nakagawa Hiroki on 11/12/22.
//  Copyright (c) 2011年 ASIAL CORPORATION. All rights reserved.
//

#import "NCTitleView.h"
#import "MFDelegate.h"
#import "MFDevice.h"
#import "MFUtility.h"

/*
@implementation NCTitleLabel

@synthesize fontScale = fontScale_;

@end
*/

@implementation NCTitleView
/*
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
    CGPoint naviCenter = [MFUtility currentTabBarController].navigationController.navigationBar.center;
    self.center = CGPointMake(naviCenter.x, center.y);
 /*
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
*/

static const CGFloat kSizeOfTitleFont             = 14.0f;
static const CGFloat kSizeOfSubtitleFont          = 11.0f;
static const CGFloat kSizeOfLandscapeTitleFont    = 18.0f;
static const CGFloat kSizeOfPortraitTitleFont     = 19.0f;

- (id)init {
    self = [super init];
    
    if (self) {

        _title = [[UILabel alloc] init];
        _subtitle = [[UILabel alloc] init];

        [_title setBackgroundColor:[UIColor clearColor]];
        _title.textAlignment = UITextAlignmentCenter;
        [_title setFont:[UIFont boldSystemFontOfSize:kSizeOfTitleFont]];
        [_title setTextColor:[UIColor whiteColor]];
        _title.shadowColor = [UIColor colorWithWhite:0.0 alpha:0.5];

        [_subtitle setBackgroundColor:[UIColor clearColor]];
        _subtitle.textAlignment = UITextAlignmentCenter;
        [_subtitle setFont:[UIFont boldSystemFontOfSize:kSizeOfTitleFont]];
        [_subtitle setTextColor:[UIColor whiteColor]];
        _subtitle.shadowColor = [UIColor colorWithWhite:0.0 alpha:0.5];
        
        [self addSubview:_title];
        [self addSubview:_subtitle];
        _ncStyle = [[NSMutableDictionary alloc] init];
        [_ncStyle setValue:kNCUndefined forKey:kNCStyleTitle];
        [_ncStyle setValue:kNCUndefined forKey:kNCStyleSubtitle];
        [_ncStyle setValue:kNCWhite forKey:kNCStyleTitleColor];
        [_ncStyle setValue:kNCWhite forKey:kNCStyleSubtitleColor];
        [_ncStyle setValue:[NSNumber numberWithFloat:1.0] forKey:kNCStyleTitleFontScale];
        [_ncStyle setValue:[NSNumber numberWithFloat:1.0] forKey:kNCStyleSubtitleFontScale];
    }
    
    return self;
}

- (void)setFrame:(CGRect)frame
{
    CGFloat height = [MFDevice heightOfNavigationBar:[MFUtility currentInterfaceOrientation]];
    [super setFrame:CGRectMake(0, 0, 0, height)];
    
    [self setCenter:CGPointMake(frame.origin.x, frame.size.height/2.0f)];
    if (UIInterfaceOrientationIsLandscape([MFUtility currentInterfaceOrientation])) {
        _title.font = [UIFont boldSystemFontOfSize:kSizeOfLandscapeTitleFont * [[self retrieveUIStyle:kNCStyleTitleFontScale] floatValue]];
        [_title setCenter:CGPointMake(frame.size.width/2.0f, frame.size.height/2.0f)];
    } else {
        if (![_subtitle.text isEqual:kNCUndefined]) {
            _title.font = [UIFont boldSystemFontOfSize:kSizeOfTitleFont * [[self retrieveUIStyle:kNCStyleTitleFontScale] floatValue]];
            _subtitle.font = [UIFont systemFontOfSize:kSizeOfSubtitleFont * [[self retrieveUIStyle:kNCStyleSubtitleFontScale] floatValue]];
            _title.center = CGPointMake(frame.size.width/2.0f, 30);
            _subtitle.center = CGPointMake(frame.size.width/2.0f, 12);
        } else {
            _title.font = [UIFont boldSystemFontOfSize:kSizeOfPortraitTitleFont * [[self retrieveUIStyle:kNCStyleTitleFontScale] floatValue]];
            _title.center = CGPointMake(frame.size.width/2.0f, frame.size.height/2.0f);
        }
    }
    [_title sizeToFit];
    [_subtitle sizeToFit];
    _title.frame = CGRectIntegral(_title.frame);
    _subtitle.frame = CGRectIntegral(_subtitle.frame);
    
}

#pragma mark - UIStyleProtocol

- (void)updateUIStyle:(id)value forKey:(NSString *)key
{
    if ([_ncStyle objectForKey:key] == nil) {
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
    
    if ([key isEqualToString:kNCStyleTitle]) {
        [_title setText:value];
        [_title sizeToFit];
    }
    if ([key isEqualToString:kNCStyleSubtitle]) {
        [_subtitle setText:value];
    }
    if ([key isEqualToString:kNCStyleTitleColor]) {
        [_title setTextColor:hexToUIColor(removeSharpPrefix(value), 1)];
    }
    if ([key isEqualToString:kNCStyleSubtitleColor]) {
        [_subtitle setTextColor:hexToUIColor(removeSharpPrefix(value), 1)];
    }
    if ([key isEqualToString:kNCStyleTitleFontScale]) {
        if (UIInterfaceOrientationIsLandscape([MFUtility currentInterfaceOrientation])) {
            [_title setFont:[UIFont boldSystemFontOfSize:kSizeOfTitleFont * [value floatValue]]];
        }
    }
    if ([key isEqualToString:kNCStyleSubtitleFontScale]) {
        [_title setFont:[UIFont boldSystemFontOfSize:kSizeOfTitleFont * [value floatValue]]];
        [_title sizeToFit];
    }

    [_ncStyle setValue:value forKey:key];
}

- (id)retrieveUIStyle:(NSString *)key
{
    if ([_ncStyle objectForKey:key] == nil) {
        // 例外処理
        return nil;
    }
    
    return [_ncStyle objectForKey:key];
}

@end
