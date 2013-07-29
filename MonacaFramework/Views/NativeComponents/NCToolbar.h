//
//  NCToolbar.h
//  MonacaFramework
//
//  Created by Nakagawa Hiroki on 12/02/15.
//  Copyright (c) 2012年 ASIAL CORPORATION. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MFViewController.h"
#import "UIStyleProtocol.h"

@interface NCToolbar : NSObject <UIStyleProtocol>
{
    MFViewController *_viewController;
    UIToolbar *_toolbar;
    NCStyle *_ncStyle;
    NSArray *_containers;
}

- (id)initWithViewController:(MFViewController *)viewController;
- (void)createToolbar:(NSDictionary *)uidict;

@property (nonatomic, retain) MFViewController *viewController;

@end
