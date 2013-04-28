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
}

@end
