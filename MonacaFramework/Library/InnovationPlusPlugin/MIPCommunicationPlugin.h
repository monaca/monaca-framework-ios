//
//  CDVInnovationPlusPlugin.h
//  MonacaDebugger
//
//  Created by Shikata on 5/2/13.
//  Copyright (c) 2013 ASIAL CORPORATION. All rights reserved.
//

#import "CDVPlugin.h"
#import "MFUtility.h"
#import "MIPUtility.h"

@interface MIPCommunicationPlugin : CDVPlugin{
    NSString* callbackId;
    CDVPluginResult* pluginResult;
}

-(void)returnSuccessValueForJson:(NSDictionary*)returnValues;
-(void)returnSuccessValueForArray:(NSArray*)returnValues;
-(void)returnSuccessValueForString:(NSString*)returnString;
-(void)returnErrorValue:(int*)errorCode;

@end
