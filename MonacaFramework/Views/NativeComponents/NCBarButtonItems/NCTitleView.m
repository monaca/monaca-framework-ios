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
#import "UILabel+Resize.h"

@implementation NCTitleView

static const CGFloat kSizeOfTitleFont             = 14.0f;
static const CGFloat kSizeOfSubtitleFont          = 11.0f;
static const CGFloat kSizeOfLandscapeTitleFont    = 18.0f;
static const CGFloat kSizeOfPortraitTitleFont     = 19.0f;

- (id)init {
    self = [super init];
    
    if (self) {

        _title = [[UILabel alloc] init];
        _subtitle = [[UILabel alloc] init];
        _titleImageView = [[UIImageView alloc] init];

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
        [self addSubview:_titleImageView];
        _ncStyle = [[NSMutableDictionary alloc] init];
        [_ncStyle setValue:kNCUndefined forKey:kNCStyleTitle];
        [_ncStyle setValue:kNCUndefined forKey:kNCStyleSubtitle];
        [_ncStyle setValue:kNCWhite forKey:kNCStyleTitleColor];
        [_ncStyle setValue:kNCWhite forKey:kNCStyleSubtitleColor];
        [_ncStyle setValue:[NSNumber numberWithFloat:1.0] forKey:kNCStyleTitleFontScale];
        [_ncStyle setValue:[NSNumber numberWithFloat:1.0] forKey:kNCStyleSubtitleFontScale];
        [_ncStyle setValue:kNCUndefined forKey:kNCStyleTitleImage];
    }
    
    return self;
}

- (void)setFrame:(CGRect)frame
{
    [super setFrame:frame];
    [self sizeToFit];
}

- (void)sizeToFit
{
    if (![[self retrieveUIStyle:kNCStyleTitleImage] isEqualToString:kNCUndefined]) {
        [_titleImageView setHidden:NO];
        [_title setHidden:YES];
        [_subtitle setHidden:YES];
        _titleImageView.frame = CGRectMake(-_titleImageView.image.size.width/2.0f, -_titleImageView.image.size.height/2.0f,
                                           _titleImageView.image.size.width, _titleImageView.image.size.height);
        [_titleImageView sizeToFit];
    } else {
        [_title setHidden:NO];
        [_subtitle setHidden:NO];
        [_titleImageView setHidden:YES];
    }
    if (UIInterfaceOrientationIsLandscape([MFUtility currentInterfaceOrientation])) {
        _title.font = [UIFont boldSystemFontOfSize:kSizeOfLandscapeTitleFont * [[self retrieveUIStyle:kNCStyleTitleFontScale] floatValue]];
        _title.frame = [_title resizedFrameWithPoint:CGPointMake(0, 0)];
        [_title setCenter:CGPointMake(self.frame.size.width/2.0f, self.frame.size.height/2.0f)];
        [_subtitle setHidden:YES];
    } else {
        if (![[self retrieveUIStyle:kNCStyleSubtitle] isEqual:kNCUndefined]) {
            _title.font = [UIFont boldSystemFontOfSize:kSizeOfTitleFont * [[self retrieveUIStyle:kNCStyleTitleFontScale] floatValue]];
            _subtitle.font = [UIFont systemFontOfSize:kSizeOfSubtitleFont * [[self retrieveUIStyle:kNCStyleSubtitleFontScale] floatValue]];
            _title.frame = [_title resizedFrameWithPoint:CGPointMake(0, 0)];
            _subtitle.frame = [_subtitle resizedFrameWithPoint:CGPointMake(0, 0)];
            _title.center = CGPointMake(0, 8);
            _subtitle.center = CGPointMake(0, -10);
        } else {
            _title.font = [UIFont boldSystemFontOfSize:kSizeOfPortraitTitleFont * [[self retrieveUIStyle:kNCStyleTitleFontScale] floatValue]];
            _title.frame = [_title resizedFrameWithPoint:CGPointMake(0, 0)];
            _title.center = CGPointMake(0, self.frame.size.height/2.0f);
            [_subtitle setHidden:YES];
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
            [_title setFont:[UIFont boldSystemFontOfSize:kSizeOfLandscapeTitleFont * [value floatValue]]];
        } else {
            if (![[self retrieveUIStyle:kNCStyleSubtitle] isEqual:kNCUndefined]) {
                [_title setFont:[UIFont boldSystemFontOfSize:kSizeOfTitleFont * [value floatValue]]];
            } else {
                [_title setFont:[UIFont boldSystemFontOfSize:kSizeOfPortraitTitleFont * [value floatValue]]];
            }
        }
    }
    if ([key isEqualToString:kNCStyleSubtitleFontScale]) {
        [_subtitle setFont:[UIFont boldSystemFontOfSize:kSizeOfSubtitleFont * [value floatValue]]];
    }
    if ([key isEqualToString:kNCStyleTitleImage]) {
        NSString *imagePath = [[MFUtility currentViewController].wwwFolderName stringByAppendingPathComponent:value];
        _titleImageView.image = [UIImage imageWithContentsOfFile:imagePath];
        _titleImageView.contentMode = UIViewContentModeCenter;
    }
    
    if (value == nil) {
        value = kNCUndefined;
    }
    [_ncStyle setValue:value forKey:key];
    [self sizeToFit];
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
