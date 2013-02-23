//
//  main.m
//  unittest
//
//  Created by Katsuya Saitou on 13/01/09.
//  Copyright (c) 2012年 ASIAL CORPORATION. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <GHUnitIOS/GHUnit.h>

int main(int argc, char *argv[])
{
    int retVal;
    @autoreleasepool {
        if (getenv("GHUNIT_CLI")) {
            retVal = [GHTestRunner run];
        } else {
            retVal = UIApplicationMain(argc, argv, nil, @"GHUnitIOSAppDelegate");
        }
    }
    return retVal;
}
