//
//  NCSearchBox.h
//  MonacaFramework
//
//  Created by Yasuhiro Mitsuno on 2013/04/27.
//  Copyright (c) 2013年 ASIAL CORPORATION. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIStyleProtocol.h"

@interface NCSearchBox : UIBarButtonItem <UIStyleProtocol,UISearchBarDelegate>
{
    UISearchBar *_searchBar;
    NSString* _position;
    NSMutableDictionary *_ncStyle;
    id<UISearchBarDelegate> _delegate;
}

- (void)applyUserInterface:(NSDictionary *)uidict;

@property (retain,nonatomic) id<UISearchBarDelegate> deleagte;

@end