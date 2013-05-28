//
//  ProfileDelegate.h
//  MonacaDebugger
//
//  Created by Shikata on 5/13/13.
//  Copyright (c) 2013 ASIAL CORPORATION. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <IPP_RESTKit4iOS/IPPProfileClient.h>
#import "MIPCommunicationPlugin.h"
#import "MFUtility.h"
#import "MIPUtility.h"

@interface ProfileDelegate : NSObject<IPPQueryCallback>
{
    MIPCommunicationPlugin* cdvPlugin;
    IPPProfileClient* client;
}

-(id)initWithCDVPlugin:(MIPCommunicationPlugin*)plugin :(NSString*)plistApplicationId  :(NSString*)authKey;
-(void)retrieveResource:(NSMutableArray*)feelds;
-(void)retrieveQueryResource:(NSMutableArray*)feelds;

@end
