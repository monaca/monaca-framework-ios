//
//  MFSpinnerView.h
//  HealthPlanet
//
//  Created by Mitsunori KUBOTA on 13/05/09.
//  Copyright (c) 2013年 Asial Corporation. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MFSpinnerParameter.h"

@interface MFSpinnerView : UIView {
    @protected
    UILabel *_label;
    UIImageView *_imageView;
}

+ (void)show:(MFSpinnerParameter *)parameter;
+ (void)updateTitle:(NSString *)title;
+ (void)hide;

@end
