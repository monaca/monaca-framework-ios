//
//  MFSpinnerParaneter.m
//  HealthPlanet
//
//  Created by Mitsunori KUBOTA on 13/05/09.
//  Copyright (c) 2013年 Asial Corporation. All rights reserved.
//

#import "MFSpinnerParameter.h"
#import "NativeComponentsInternal.h"

#define DEFAULT_SPINNER_SRC @"spinner.png"

@implementation MFSpinnerParameter

@synthesize images = _images, backgroundColor = _backgrondColor;
@synthesize animationDuration = _animationDuration, title = _title;
@synthesize titleColor = _titleColor, titleFontSize = _titleFontSize;

- (id)initWithImages:(NSArray *)images
withBackgroundColor:(UIColor *)backgroundColor
withAnimationDuration:(float) animationDuration
withTitle:(NSString *)title
withTitleColor:(UIColor *)titleColor
withTitleFontSize:(NSUInteger)titleFontSize
{
    self = [self init];
    
    if (self) {
        _images = images;
        _backgrondColor = backgroundColor;
        _animationDuration = animationDuration;
        _title = title;
        _titleColor = titleColor;
        _titleFontSize = titleFontSize;
    }
    
    return self;
}

+ (NSArray *)splitToAnimationImagesFromImage:(UIImage *)sourceImage withFrameCount:(NSUInteger)frameCount
{
    NSMutableArray *result = [NSMutableArray array];
    
    frameCount = frameCount <= 0 ? 1 : frameCount;
    
    int width = sourceImage.size.width;
    int height = sourceImage.size.height / frameCount;
    
    for (int i = 0; i < frameCount; i++) {
        UIGraphicsBeginImageContextWithOptions(CGSizeMake(width, height), NO, sourceImage.scale);
        CGContextRef context = UIGraphicsGetCurrentContext();
        
        CGRect drawRect = CGRectMake(0, -height * i, width, sourceImage.size.height);
        CGContextClipToRect(context, CGRectMake(0, 0, width, height));
        
        [sourceImage drawInRect:drawRect];
        
        // grab image
        UIImage* subImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        [result addObject:subImage];
    }
    
    return result;
}

+ (MFSpinnerParameter *)parseFromJSONDictionary:(NSDictionary *)dictionary
{
    return self.defaultParameter;
}

+ (MFSpinnerParameter *)defaultParameter
{
    UIColor *defaultBackgroundColor = [UIColor colorWithRed:.0 green:.0 blue:.0 alpha:.8];
    UIImage *sourceImage = [UIImage imageNamed:DEFAULT_SPINNER_SRC];
    
    return [self.alloc initWithImages:[self splitToAnimationImagesFromImage:sourceImage withFrameCount:12]
                  withBackgroundColor:defaultBackgroundColor
                withAnimationDuration:1.2f
                            withTitle:@""
                       withTitleColor:UIColor.whiteColor
                    withTitleFontSize:20];
}

+ (MFSpinnerParameter *)parseFromCodrovaPluginArguments:(NSArray *)arguments
{
    NSArray *images;
    {
        NSUInteger frameCount = 0;
        id srcString = [arguments objectAtIndex:1];
        if (![srcString isKindOfClass:NSString.class]) {
            srcString = DEFAULT_SPINNER_SRC;
            frameCount = 12;
        }
        UIImage *sourceImage = [UIImage imageNamed:srcString];
    
        if (frameCount == 0) {
            id frames = [arguments objectAtIndex:2];
            if ([frames isKindOfClass:NSNumber.class]) {
                frameCount = [frames integerValue];
            }
        }
    
        images = [self splitToAnimationImagesFromImage:sourceImage withFrameCount:frameCount];
    }
    
    float animationDuration;
    {
        id interval = [arguments objectAtIndex:3];
        if (![interval isKindOfClass:NSString.class]) {
            interval = @"0.1";
        }
        animationDuration = ((NSString*)interval).floatValue * images.count;
    }
    
    UIColor *backgroundColor;
    {
        id backgroundColorHex = [arguments objectAtIndex:4];
        id backgroundOpacity = [arguments objectAtIndex:5];
    
        if (![backgroundColorHex isKindOfClass:NSString.class]) {
            backgroundColorHex = @"#000000";
        }
    
        if (![backgroundOpacity isKindOfClass:NSNumber.class]) {
            backgroundOpacity = [NSNumber numberWithFloat:0.8];
        }
    
        backgroundColor = hexToUIColor(removeSharpPrefix(backgroundColorHex), ((NSNumber *)backgroundOpacity).floatValue);
    }

    NSString *title;
    {
        id tempTitle = [arguments objectAtIndex:6];
        if (![tempTitle isKindOfClass:NSString.class]) {
            tempTitle = @"";
        }
        title = (NSString*)tempTitle;
    }

    UIColor *titleColor;
    {
        id titleColorHex = [arguments objectAtIndex:7];
    
        if (![titleColorHex isKindOfClass:NSString.class]) {
            titleColorHex = @"#ffffff";
        }
    
        titleColor = hexToUIColor(removeSharpPrefix(titleColorHex), 1.0);
    }

    NSUInteger titleFontSize = 20;
    {
        id titleFontScale = [arguments objectAtIndex:8];
        if (![titleFontScale isKindOfClass:NSNumber.class]) {
            titleFontScale = [NSNumber numberWithFloat:1.0];
        }
        titleFontSize = 20 * ((NSNumber *)titleFontScale).floatValue;
    }

    return [self.alloc initWithImages:images
                  withBackgroundColor:backgroundColor
                withAnimationDuration:animationDuration
                            withTitle:title
                       withTitleColor:titleColor
                    withTitleFontSize:titleFontSize];
}

@end
