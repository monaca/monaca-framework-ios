//
//  MFSpinnerView.m
//  HealthPlanet
//
//  Created by Mitsunori KUBOTA on 13/05/09.
//  Copyright (c) 2013年 Asial Corporation. All rights reserved.
//

#import "MFSpinnerView.h"
#import "QuartzCore/QuartzCore.h"

@implementation MFSpinnerView

#define WINDOW_FRAME UIApplication.sharedApplication.delegate.window.frame

- (id)init
{
    self = [super init];
    
    if (self) {
        self.frame = WINDOW_FRAME;
        self.layer.backgroundColor = [UIColor colorWithRed:.0 green:.0 blue:.0 alpha:0.3].CGColor;
        self.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight |
        UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleLeftMargin |
        UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin |
        UIViewAutoresizingFlexibleBottomMargin;
        
        _label = [UILabel.alloc initWithFrame:WINDOW_FRAME];
        _label.text = @"";
        _label.textAlignment = UITextAlignmentCenter;
        _label.backgroundColor = UIColor.clearColor;
        _label.textColor = UIColor.blackColor;
        
        _imageView = [UIImageView.alloc initWithFrame:WINDOW_FRAME];
        _imageView.animationDuration = 1.0f;
        
        [self addSubview:_label];
        [self addSubview:_imageView];
    }
    
    return self;
}

- (void)layoutSubviews
{
    self.frame = WINDOW_FRAME;
    
    UIImage *image = [_imageView.animationImages objectAtIndex:0];
    _imageView.frame = image
        ? CGRectMake(self.center.x - image.size.width / 2, self.center.y - image.size.height / 2, image.size.width, image.size.height)
        : CGRectMake(0, 0, 0, 0);
    
    CGFloat marginTop = _label.font.lineHeight * 0.5;
    _label.frame = CGRectMake(0, _imageView.frame.origin.y + _imageView.frame.size.height + marginTop,
                              WINDOW_FRAME.size.width, _label.font.lineHeight);
}

- (void)applyParameter:(MFSpinnerParameter *)parameter
{
    _label.text = parameter.title;
    _label.textColor = parameter.titleColor;
    _label.font = [UIFont systemFontOfSize:parameter.titleFontSize];
    
    self.layer.backgroundColor = parameter.backgroundColor.CGColor;
    
    _imageView.animationImages = parameter.images;
    _imageView.animationDuration = parameter.animationDuration;
    
    [self layoutSubviews];
}

- (void)setTitle:(NSString *)title
{
    _label.text = title;
}

- (void)dealloc
{
    _label = nil;
    _imageView = nil;
}

- (void)startSpinnerAnimating
{
    [_imageView startAnimating];
}

static MFSpinnerView *spinnerView = nil;

+ (void)show:(MFSpinnerParameter *)parameter
{
    // Hide previous spinner
    [self hide];

    spinnerView = [MFSpinnerView.alloc init];
    [spinnerView applyParameter:parameter];
    [spinnerView startSpinnerAnimating];
    
    UIWindow *window = UIApplication.sharedApplication.delegate.window;
    UIView *rootView = window.rootViewController.view;
    [rootView addSubview:spinnerView];
    
}

+ (void)updateTitle:(NSString *)title
{
    if (spinnerView) {
        spinnerView.title = title;
    }
}

+ (void)hide
{
    if (spinnerView) {
        [spinnerView removeFromSuperview];
        spinnerView = nil;
    }
}

@end
