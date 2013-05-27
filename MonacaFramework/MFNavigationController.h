//
//  MFNavigationController.h
//  MonacaFramework
//
//  Created by Yasuhiro Mitsuno on 2013/02/23.
//  Copyright (c) 2013年 ASIAL CORPORATION. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MFNavigationController : UINavigationController <UINavigationControllerDelegate,UINavigationBarDelegate>
{
    BOOL popFlag;
}

- (void)destroy;

@end
