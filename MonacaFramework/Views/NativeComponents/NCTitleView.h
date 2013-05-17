//
//  NCTitleView.h
//  MonacaFramework
//
//  Created by Nakagawa Hiroki on 11/12/22.
//  Copyright (c) 2011年 ASIAL CORPORATION. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface NCTitleLabel : UILabel {
 @private
    CGFloat fontScale_;
}

@property(nonatomic, assign) CGFloat fontScale;

@end


@interface NCTitleView : UIView {
 @private
    NCTitleLabel *titleLabel_;
    NCTitleLabel *subtitleLabel_;
    UIImageView *titleImageView_;
}

- (void)setTitle:(NSString *)title color:(UIColor *)color scale:(CGFloat)scale;
- (void)setSubtitle:(NSString *)subtitle color:(UIColor *)color scale:(CGFloat)scale;
- (void)setTitleImage:(NSString *)imageFilePath;

@property(nonatomic, retain) NCTitleLabel *titleLabel;
@property(nonatomic, retain) NCTitleLabel *subtitleLabel;
@property(nonatomic, retain) UIImageView *titleImageView;

@end
