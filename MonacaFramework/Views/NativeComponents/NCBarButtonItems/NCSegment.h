//
//  NCSegment.h
//  MonacaFramework
//
//  Created by Yasuhiro Mitsuno on 2013/04/26.
//  Copyright (c) 2013年 ASIAL CORPORATION. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NCBarButtonItem.h"

@interface NCSegment : NCBarButtonItem
{
    UISegmentedControl *_segment;
    NSString* _position;
}

- (void)addTarget:(id)target action:(SEL)action forControlEvents:(UIControlEvents)controlEvents;

@end
