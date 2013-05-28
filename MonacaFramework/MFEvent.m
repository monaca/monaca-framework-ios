//
//  MonacaEvent.m
//  MonacaFramework
//
//  Created by Katsuya Saitou on 12/10/26.
//  Copyright (c) 2012年 ASIAL CORPORATION. All rights reserved.
//

#import "MFEvent.h"

@implementation MFEvent

+ (void)dispatchEvent:(NSString *)eventName withInfo:(NSMutableDictionary *)info {
    NSNotification* notification = [NSNotification notificationWithName:eventName object:self userInfo:info];
    [[NSNotificationCenter defaultCenter] postNotification:notification];
}

@end
