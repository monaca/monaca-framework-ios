//
//  CDVCamera+MonacaAction.m
//  MonacaFramework
//
//  Created by Katsuya Saitou on 12/11/26.
//  Copyright (c) 2012年 ASIAL CORPORATION. All rights reserved.
//

#import "CDVCamera+MonacaAction.h"
#import "MonacaViewController.h"
#import "Utility.h"



@implementation CDVCamera (MonacaAction)

- (UIViewController *)viewController
{
    return [Utility getAppDelegate].viewController;
}

@end
