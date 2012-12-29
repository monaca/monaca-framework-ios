//
//  Device.h
//  MonacaFramework
//
//  Created by Nakagawa Hiroki on 12/01/10.
//  Copyright (c) 2012年 ASIAL CORPORATION. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface MFDevice : NSObject

+ (BOOL)isiPhone;
+ (BOOL)isiPad;

+ (float)heightOfWindow:(UIInterfaceOrientation)orientation;
+ (float)widthOfWindow:(UIInterfaceOrientation)orientation;
+ (float)heightOfNavigationBar:(UIInterfaceOrientation)orientation;
+ (float)heightOfToolBar:(UIInterfaceOrientation)orientation;

+ (float)heightOfStatusBar;
+ (float)heightOfTabBar;

+ (NSInteger)iOSVersionMajor;

@end
