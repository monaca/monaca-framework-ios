//
//  MIPCommunicationDelegate.h
//  MonacaDebugger
//
//  Created by Shikata on 5/10/13.
//  Copyright (c) 2013 ASIAL CORPORATION. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <IPP_RESTKit4iOS/IPPLoginClient.h>
#import "MIPCommunicationPlugin.h"
#import "MFUtility.h"
#import "MIPUtility.h"

@interface UserDelegate : NSDictionary <IPPQueryCallback>{
    MIPCommunicationPlugin* cdvPlugin;
    MIPUtility* mipUtility;
    NSString* applicationId;
    NSMutableDictionary *resultValues;
}

-(id)initWithCDVPlugin:(CDVPlugin*)plugin :(NSString*)plistApplicationId;
-(void)userLogin:(NSString*)userName :(NSString*)userPassword;
-(void)getAuthKey;
-(void)userLogout;
@end
