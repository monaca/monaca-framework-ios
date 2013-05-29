//
//  UILabel+Resize.m
//  MonacaFramework
//
//  Created by Nakagawa Hiroki on 11/12/27.
//  Copyright (c) 2011年 ASIAL CORPORATION. All rights reserved.
//

#import "UILabel+Resize.h"

@implementation UILabel (Resize)

- (void)resizeWithPoint:(CGPoint)point {
    self.frame = [self resizedFrameWithPoint:point];
}

- (id)initWithText:(NSString *)text andFont:(UIFont *)font {
    self = [self initWithText:text
                      andFont:font
                     andPoint:CGPointMake(0, 0)];
    
    return self;
}

- (id)initWithText:(NSString *)text andFont:(UIFont *)font andPoint:(CGPoint)point {
    self = [super initWithFrame:CGRectZero];
    if (self) {
        self.numberOfLines = 0;
        self.font = font;
        self.text = text;
        
        self.frame = [self resizedFrameWithPoint:point];
    }
    
    return self;
}

- (CGRect)resizedFrameWithPoint:(CGPoint)point
{
    CGSize size = [self.text sizeWithFont:self.font
                        constrainedToSize:CGSizeMake([[UIScreen mainScreen] bounds].size.width, NSIntegerMax) 
                            lineBreakMode:UILineBreakModeTailTruncation];
    
    CGRect resizedFrame = CGRectMake(point.x, point.y, size.width, size.height);
    
    return resizedFrame;
}

@end
