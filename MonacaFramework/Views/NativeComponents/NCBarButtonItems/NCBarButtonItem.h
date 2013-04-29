//
//  NCBarButtonItem.h
//  MonacaFramework
//
//  Created by Yasuhiro Mitsuno on 2013/04/28.
//  Copyright (c) 2013年 ASIAL CORPORATION. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIStyleProtocol.h"

@interface NCBarButtonItem : UIBarButtonItem <UIStyleProtocol>
{
    NSMutableDictionary *_ncStyle;
    id<UIStyleProtocol> _toolbar;
    BOOL _hidden;
}

@property (nonatomic, assign) BOOL hidden;
@property (nonatomic, retain) id<UIStyleProtocol> toolbar;

@end
