//
//  NCTitleView.h
//  MonacaFramework
//
//  Created by Nakagawa Hiroki on 11/12/22.
//  Copyright (c) 2011年 ASIAL CORPORATION. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIStyleProtocol.h"

/*
@interface NCTitleLabel : UILabel <UIStyleProtocol> {
 @private
    CGFloat fontScale_;
}

@property(nonatomic, assign) CGFloat fontScale;

@end


@interface NCTitleView : UIView {
 @private
    NCTitleLabel *titleLabel_;
    NCTitleLabel *subtitleLabel_;
}

- (void)setTitle:(NSString *)title color:(UIColor *)color scale:(CGFloat)scale;
- (void)setSubtitle:(NSString *)subtitle color:(UIColor *)color scale:(CGFloat)scale;

@property(nonatomic, retain) NCTitleLabel *titleLabel;
@property(nonatomic, retain) NCTitleLabel *subtitleLabel;

@end
 
 */

@interface NCTitleView : UIView <UIStyleProtocol> {
    UILabel *_title;
    UILabel *_subtitle;
    NSMutableDictionary *_ncStyle;
}

@end
