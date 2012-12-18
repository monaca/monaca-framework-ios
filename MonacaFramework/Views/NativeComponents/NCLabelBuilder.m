//
//  NCLabelBuilder.m
//  MonacaFramework
//
//  Created by Hiroki Nakagawa on 11/11/15.
//  Copyright (c) 2011 ASIAL CORPORATION. All rights reserved.
//

#import "NCLabelBuilder.h"
#import "UILabel+Resize.h"


@implementation NCLabelBuilder

static UILabel *
updateLabel(UILabel *label, NSDictionary *style) {
    [label setBackgroundColor:[UIColor clearColor]];
    [label setText:[style objectForKey:kNCStyleText]];
    
    BOOL invisible = isFalse([style objectForKey:kNCStyleVisibility]);
    [label setHidden:invisible];
    
    // Opacity (not support).
    
    NSString *textColor = [style objectForKey:kNCStyleTextColor];
    if (textColor) {
        [label setTextColor:hexToUIColor(removeSharpPrefix(textColor), 1)];
    }
    
    [label sizeToFit];
    label.frame = [label resizedFrameWithPoint:CGPointMake(0, 0)];
    return label;    
}

+ (UILabel *)label:(NSDictionary *)style {
    UILabel *label = [[UILabel alloc] init];
    return updateLabel(label, style);
}

+ (UIBarButtonItem *)update:(UIBarButtonItem *)label with:(NSDictionary *)style {
    label.customView = updateLabel((UILabel *)label.customView, style);
    return label;
}

@end
