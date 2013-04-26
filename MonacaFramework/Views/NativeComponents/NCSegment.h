//
//  NCSegment.h
//  MonacaFramework
//
//  Created by Yasuhiro Mitsuno on 2013/04/26.
//  Copyright (c) 2013年 ASIAL CORPORATION. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIStyleProtocol.h"

@interface NCSegment : UIBarButtonItem <UIStyleProtocol>
{
    UISegmentedControl *_segment;
    NSString* _position;
    NSMutableDictionary *_ncStyle;
}

- (void)applyUserInterface:(NSDictionary *)uidict;
- (void)addTarget:(id)target action:(SEL)action forControlEvents:(UIControlEvents)controlEvents;

@end
