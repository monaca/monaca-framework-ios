//
//  MFDevice.m
//  MonacaFramework
//
//  Created by Shikata on 7/5/13.
//  Copyright (c) 2013 ASIAL CORPORATION. All rights reserved.
//

#import "MFDevicePlugin.h"

@implementation MFDevicePlugin

-(void)getRuntimeConfiguration:(CDVInvokedUrlCommand*)command
{
    if ([[NSUserDefaults standardUserDefaults] objectForKey:@"UUID"] == nil)
    {
        CFUUIDRef uuidObj = CFUUIDCreate(nil);
        NSString *uuidString = (__bridge NSString*)CFUUIDCreateString(nil, uuidObj);
        CFRelease(uuidObj);
        [[NSUserDefaults standardUserDefaults] setObject:uuidString forKey:@"UUID"];
        [[NSUserDefaults standardUserDefaults]synchronize];
    }
    
    CDVPluginResult* result;
    if ([[NSUserDefaults standardUserDefaults] objectForKey:@"UUID"])
    {
        NSDictionary *deviceData = [NSDictionary dictionaryWithObject:[[NSUserDefaults standardUserDefaults] objectForKey:@"UUID"] forKey:@"deviceId"];
        result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:deviceData];
        [self writeJavascript:[result toSuccessCallbackString:command.callbackId]];
        
    }
    else
    {
        result = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR];
        [self writeJavascript:[result toErrorCallbackString:command.callbackId]];
    }
}

@end
