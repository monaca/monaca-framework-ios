//
//  NCSearchBox.h
//  MonacaFramework
//
//  Created by Yasuhiro Mitsuno on 2013/04/27.
//  Copyright (c) 2013年 ASIAL CORPORATION. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NCBarButtonItem.h"

@interface NCSearchBox : NCBarButtonItem <UISearchBarDelegate>
{
    UISearchBar *_searchBar;
    id<UISearchBarDelegate> _delegate;
}

@property (retain,nonatomic) id<UISearchBarDelegate> deleagte;

@end