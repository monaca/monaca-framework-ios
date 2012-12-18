//
//  NCSegmentBuilder.m
//  MonacaFramework
//
//  Created by Nakagawa Hiroki on 11/11/22.
//  Copyright (c) 2011年 ASIAL CORPORATION. All rights reserved.
//

#import "NCSegmentBuilder.h"

@implementation NCSegmentBuilder

static UISegmentedControl *
setTextColor(UISegmentedControl *segments, UIColor *color) {
    if (iOSVersionMajor() <= 4) {
        // BUG(nhiroki): When taps segment, segment's text color becomes white. I do not have idea...
        for (id segment in [segments subviews]) {
            for (id label in [segment subviews]) {
                if ([label isKindOfClass:[UILabel class]]) {
                    [label setTextColor:color];
                }
            }
        }
    } else if (iOSVersionMajor() >= 5) {
        NSDictionary *attributes = [NSDictionary dictionaryWithObjectsAndKeys:color, UITextAttributeTextColor, nil];
        [segments setTitleTextAttributes:attributes forState:UIControlStateNormal];
    }
    
    return segments;
}

static UISegmentedControl *
updateSegment(UISegmentedControl *segment, NSDictionary *dict) {
    [segment setSegmentedControlStyle:UISegmentedControlStyleBar];

    BOOL invisible = isFalse([dict objectForKey:kNCStyleVisibility]);
    [segment setHidden:invisible];
    
    // TODO(nhiroki): Opacity.
    
    NSString *bgColor = [dict objectForKey:kNCStyleBackgroundColor];
    if (bgColor) {
        [segment setTintColor:hexToUIColor(removeSharpPrefix(bgColor), 1)];
    }
    
    NSArray *texts = [dict objectForKey:kNCStyleTexts];
    if (texts) {
        // eight仕様
        CGRect frame = segment.frame;
        
        for (int i = 0; i < texts.count && i < [segment numberOfSegments]; i++) {
            [segment setTitle:[texts objectAtIndex:i] forSegmentAtIndex:i];
        }
        [segment sizeToFit];
        
        // eight仕様
        segment.frame = CGRectMake(segment.frame.origin.x, frame.origin.y, segment.frame.size.width, frame.size.height);
    }

    NSString *textColor = [dict objectForKey:kNCStyleTextColor];
    if (textColor) {
        setTextColor(segment, hexToUIColor(removeSharpPrefix(textColor), 1));
    }
    
    NSString *activeIndex = [dict objectForKey:kNCStyleActiveIndex];
    if (activeIndex) {
        [segment setSelectedSegmentIndex:[activeIndex intValue]];
    }
    
    return segment;
}

+ (UISegmentedControl *)segment:(NSDictionary *)dict {
    NSArray *texts = [dict objectForKey:kNCStyleTexts];
    UISegmentedControl *segment = [[UISegmentedControl alloc] initWithItems:texts];
    return updateSegment(segment, dict);
}

+ (UIBarButtonItem *)update:(UIBarButtonItem *)segment with:(NSDictionary *)style {
    segment.customView = updateSegment((UISegmentedControl *)segment.customView, style);
    return segment;
}

@end
