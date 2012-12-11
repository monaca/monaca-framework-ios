//
//  NCToolbar.m
//  MonacaFramework
//
//  Created by Nakagawa Hiroki on 12/02/15.
//  Copyright (c) 2012年 ASIAL CORPORATION. All rights reserved.
//

#import "NCToolbar.h"

@implementation NCToolbar
- (void)drawRect:(CGRect)rect {
    // Nothing to do.
}

// TODO: 怪しい
- (void)sizeToFit {
    static const double kRightPadding = 6.0f;
    double width = 0.0;
    for(int i = 0; i < [self.subviews count]; i++){
        UIView *view = (UIView *)[self.subviews objectAtIndex:i];
        double wx = view.bounds.size.width + view.frame.origin.x;
        if (width < wx) {
            width = wx;
        }
    }
    CGSize size = self.frame.size;
    size.width = width + kRightPadding;
    [self setFrame:CGRectMake(0.0f, 0.0f, size.width, size.height)];
}

- (void)sizeToFitCenter {
    [self sizeToFit];
    double offsetX = 0.0;

    NSArray *subviews = [self subviews];
    if ([subviews count] == 0) {
        // TODO: ok?
        return;
    }

    UIView *view = [subviews objectAtIndex:0];
    if (view) {
        offsetX = view.frame.origin.x;
    }
    CGRect frame = self.frame;
    [self setFrame:CGRectMake(frame.origin.x, frame.origin.y, frame.size.width + offsetX, frame.size.height)];
}

@end
