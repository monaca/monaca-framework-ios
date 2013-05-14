//
//  ApplicationResourceDelegate.h
//  MonacaDebugger
//
//  Created by Shikata on 5/13/13.
//  Copyright (c) 2013 ASIAL CORPORATION. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <IPP_RESTKit4iOS/IPPApplicationResourceClient.h>
#import "MIPCommunicationPlugin.h"
#import "MFUtility.h"
#import "MIPUtility.h"

@interface ApplicationResourceDelegate : NSObject <IPPQueryCallback>
{
    MIPCommunicationPlugin* cdvPlugin;
    IPPApplicationResourceClient* client;
}

-(id)initWithCDVPlugin:(MIPCommunicationPlugin*)plugin;
-(void)retrieveResource:(NSString*)resourceName :(NSString*)resourceId;
-(void)retrieveQueryResource:(NSString*)resourceName :(NSMutableDictionary*)condition;
-(void)createResourceForDictionary:(NSString*)resourceName :(NSMutableDictionary*)resource;
-(void)createResourceForArray:(NSString*)resourceName :(NSMutableArray*)resources;
-(void)deleteResource:(NSString*)resourceName :(NSString*)resourceId;

@end
