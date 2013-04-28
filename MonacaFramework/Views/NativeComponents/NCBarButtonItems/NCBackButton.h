//
//  NCBackButton.h
//  MonacaFramework
//
//  Created by Yasuhiro Mitsuno on 2013/04/27.
//  Copyright (c) 2013年 ASIAL CORPORATION. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NCBarButtonItem.h"

@interface NCBackButton : NCBarButtonItem
{
    UIButton *_backButton;
    NSString* _position;
}

- (void)addTarget:(id)target action:(SEL)action forControlEvents:(UIControlEvents)controlEvents;

@end
