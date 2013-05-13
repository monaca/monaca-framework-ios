//
//  MFSpinnerParaneter.h
//  HealthPlanet
//
//  Created by Mitsunori KUBOTA on 13/05/09.
//  Copyright (c) 2013年 Asial Corporation. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface MFSpinnerParameter : NSObject {
    @protected
    NSString *_title;
    NSUInteger _titleFontSize;
    UIColor *_titleColor;
    UIColor *_backgroundColor;
    NSArray *_images;
    float _animationDuration;
}

@property (readonly) NSString *title;
@property (readonly) NSUInteger titleFontSize;
@property (readonly) UIColor *titleColor;
@property (readonly) UIColor *backgroundColor;
@property (readonly) NSArray *images;
@property (readonly) float animationDuration;

+ (MFSpinnerParameter *)defaultParameter;
+ (MFSpinnerParameter *)parseFromJSONDictionary:(NSDictionary*)dictionary;

- (id)initWithImages:(NSArray *)images
    withBackgroundColor:(UIColor *)backgroundColor
    withAnimationDuration:(float) animationDuration
    withTitle:(NSString *)title
    withTitleColor:(UIColor *)titleColor
    withTitleFontSize:(NSUInteger)titleFontSize;

+ (MFSpinnerParameter *)parseFromCodrovaPluginArguments:(NSArray *)arguments;

@end
