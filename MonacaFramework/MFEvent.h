//
//  MFEvent.h
//  MonacaFramework
//
//  Created by Yasuhiro Mitsuno on 2013/02/23.
//  Copyright (c) 2013年 ASIAL CORPORATION. All rights reserved.
//

#import <Foundation/Foundation.h>

#define monacaEventEnterForeground @"monacaEventEnterForeground"
#define monacaEventOpenPage @"monacaEventOpenpage"
#define monacaEvent404Error @"monacaEvent404Error"
#define monacaEventNoUIFile @"monacaEventNoUIFile"
#define monacaEventNCParseSuccess @"monacaEventNCParseSuccess"
#define monacaEventNCParseError @"monacaEventNCParseError"
#define monacaEventWillLoadUIFile @"monacaEventWillLoadUIFile"
#define monacaEventDidLoadUIFile @"monacaEventDidLoadUIFile"
#define monacaEventReloadPage @"monacaEventReloadPage"
#define monacaEventWillConnectNetwork @"monacaEventWillConnectNetwork"
#define monacaEventDidConnectNetwork @"monacaEventDidConnectNetwork"

@interface MFEvent : NSObject
+ (void)dispatchEvent:(NSString *)eventName withInfo:(NSMutableDictionary *)info;
@end
