//
//  NCLabel.h
//  MonacaFramework
//
//  Created by Yasuhiro Mitsuno on 2013/04/26.
//  Copyright (c) 2013年 ASIAL CORPORATION. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIStyleProtocol.h"

@interface NCLabel : UIBarButtonItem <UIStyleProtocol>
{
    UILabel *_label;
    NSString* _position;
    NSMutableDictionary *_ncStyle;
}

- (void)applyUserInterface:(NSDictionary *)uidict;

@end
