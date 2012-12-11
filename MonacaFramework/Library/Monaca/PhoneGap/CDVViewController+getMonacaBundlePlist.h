//
//  CDVViewController+getBundlePlist.h
//  MonacaFramework
//
//  Created by Katsuya Saitou on 12/09/30.
//  Copyright (c) 2012年 ASIAL CORPORATION. All rights reserved.
//

#import "CDVViewController.h"

@interface CDVViewController (getMonacaBundlePlist)

+ (NSDictionary*) getMonacaBundlePlist:(NSString*)plistName;

@end
