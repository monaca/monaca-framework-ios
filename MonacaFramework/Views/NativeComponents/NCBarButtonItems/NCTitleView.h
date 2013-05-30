//
//  NCTitleView.h
//  MonacaFramework
//
//  Created by Nakagawa Hiroki on 11/12/22.
//  Copyright (c) 2011年 ASIAL CORPORATION. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIStyleProtocol.h"

#define TitleUndefined @" "

@interface NCTitleView : UIView <UIStyleProtocol> {
    UILabel *_title;
    UILabel *_subtitle;
    UIImageView *_titleImageView;
    NCStyle *_ncStyle;
}

@end
