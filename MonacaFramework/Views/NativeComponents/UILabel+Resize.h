//
//  UILabel+Resize.h
//  MonacaFramework
//
//  Created by Nakagawa Hiroki on 11/12/27.
//  Copyright (c) 2011年 ASIAL CORPORATION. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UILabel (Resize)

- (void) resizeWithPoint: (CGPoint)point;
- (id) initWithText:(NSString *)text andFont:(UIFont *)font;
- (id) initWithText:(NSString *)text andFont:(UIFont *)font andPoint:(CGPoint)point;
- (CGRect)resizedFrameWithPoint: (CGPoint)point;

@end
