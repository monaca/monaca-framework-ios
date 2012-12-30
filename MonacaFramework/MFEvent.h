//
//  MonacaEvent.h
//  MonacaFramework
//
//  Created by Katsuya Saitou on 12/10/26.
//  Copyright (c) 2012年 ASIAL CORPORATION. All rights reserved.
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
