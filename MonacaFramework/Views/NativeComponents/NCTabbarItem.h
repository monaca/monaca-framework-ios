//
//  NCTabbarItem.h
//  MonacaFramework
//
//  Created by Yasuhiro Mitsuno on 2013/04/27.
//  Copyright (c) 2013年 ASIAL CORPORATION. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NCTabbarItem : UITabBarItem
{
    NSMutableDictionary *_ncStyle;
}

- (void)applyUserInterface:(NSDictionary *)uidict;

@end
