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
    BOOL multiCreateFrag;
}

-(id)initWithCDVPlugin :(MIPCommunicationPlugin*)plugin :(NSString*)plistApplicationId  :(NSString*)authKey;
-(void)retrieveResource :(NSString*)resourceId :(NSString*)resourceName;
-(void)retrieveQueryResource :(NSMutableDictionary*)condition :(NSString*)resourceName;
-(void)createResourceForDictionary :(NSMutableDictionary*)resource :(NSString*)resourceName;
-(void)createResourceForArray :(NSMutableArray*)resources :(NSString*)resourceName;
-(void)deleteResource :(NSString*)resourceId :(NSString*)resourceName;

@end
