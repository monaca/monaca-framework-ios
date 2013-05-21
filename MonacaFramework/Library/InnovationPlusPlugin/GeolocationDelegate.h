//
//  GeolocationDelegate.h
//  MonacaDebugger
//
//  Created by Shikata on 5/13/13.
//  Copyright (c) 2013 ASIAL CORPORATION. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <IPP_RESTKit4iOS/IPPGeoLocationClient.h>
#import "MIPCommunicationPlugin.h"
#import "MFUtility.h"
#import "MIPUtility.h"


@interface GeolocationDelegate : NSObject <IPPQueryCallback>
{
    MIPCommunicationPlugin* cdvPlugin;
    IPPGeoLocationClient* client;
    BOOL multiCreateFrag;
}
-(id)initWithCDVPlugin:(MIPCommunicationPlugin*)plugin :(NSString*)plistApplicationId  :(NSString*)authKey;
-(void)retrieveOwnResource;
-(void)retrieveResource:(NSString*)resourceId;
-(void)createResourceForArray:(NSMutableArray*)resources;
-(void)createResourceForDictionary:(NSMutableDictionary*)resources;
-(void)deleteResource:(NSString*)resourceId;
-(void)retrieveQueryResource:(NSMutableDictionary*)condition;

@end
