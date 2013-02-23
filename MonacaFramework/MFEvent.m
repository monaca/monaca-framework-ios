//
//  MFEvent.m
//  MonacaFramework
//
//  Created by Yasuhiro Mitsuno on 2013/02/23.
//  Copyright (c) 2013年 ASIAL CORPORATION. All rights reserved.
//

#import "MFEvent.h"

@implementation MFEvent

+ (void)dispatchEvent:(NSString *)eventName withInfo:(NSMutableDictionary *)info {
    NSNotification* notification = [NSNotification notificationWithName:eventName object:self userInfo:info];
    [[NSNotificationCenter defaultCenter] postNotification:notification];
}

@end
