//
//  NCTabbarItem.h
//  MonacaFramework
//
//  Created by Yasuhiro Mitsuno on 2013/04/27.
//  Copyright (c) 2013年 ASIAL CORPORATION. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIStyleProtocol.h"

@interface NCTabbarItem : UITabBarItem <UIStyleProtocol>
{
    NCStyle *_ncStyle;
}

@end
