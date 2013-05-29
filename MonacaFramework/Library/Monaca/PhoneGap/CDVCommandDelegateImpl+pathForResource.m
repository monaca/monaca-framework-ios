//
//  CDVCommandDelegateImpl+pathForResource.m
//  MonacaDebugger
//
//  Created by Katsuya SAITO on 12/07/27.
//  Copyright (c) 2012年 ASIAL CORPORATION. All rights reserved.
//

#import "CDVCommandDelegateImpl+pathForResource.h"
#import "MFViewController.h"

@implementation CDVCommandDelegateImpl(pathForResource)

- (NSString*) pathForResource:(NSString*)resourcepath {
    NSString *path = [_viewController.wwwFolderName stringByAppendingPathComponent:resourcepath];
    NSFileManager *fileManager = [NSFileManager defaultManager];

    if( [fileManager fileExistsAtPath:path]){
        return [_viewController.wwwFolderName stringByAppendingPathComponent:resourcepath];
    }else {
        return nil;
    }
}

@end
