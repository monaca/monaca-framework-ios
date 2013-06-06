//
//  MFVIewBackground.h
//  MonacaDebugger
//
//  Created by Shikata on 5/23/13.
//  Copyright (c) 2013 ASIAL CORPORATION. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIStyleProtocol.h"
#import "MFViewController.h"

@interface MFViewBackground : UIImageView <UIStyleProtocol>
{
    MFViewController *_viewController;
    NCStyle *_ncStyle;
    UIImage *_originalImage;
    UIImage *_resizedImage;
}

- (id)initWithViewController:(MFViewController *)viewController;
- (void)createBackgroundView:(NSDictionary *)uidict;
- (void)setBackgroundStyle:(NSDictionary*)style;
- (void)updateFrame;

@end
