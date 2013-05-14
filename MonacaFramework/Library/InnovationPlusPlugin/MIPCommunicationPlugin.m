//
//  CDVInnovationPlusPlugin.m
//  MonacaDebugger
//
//  Created by Shikata on 5/2/13.
//  Copyright (c) 2013 ASIAL CORPORATION. All rights reserved.
//

#import "MIPCommunicationPlugin.h"
#import "UserDelegate.h"
#import "ProfileDelegate.h"
#import "GeolocationDelegate.h"
#import "ApplicationResourceDelegate.h"

@implementation MIPCommunicationPlugin

const int internalError = -40;

// == Return Value Method ===============================================================================================

-(void)returnSuccessValueForJson:(NSDictionary*)returnValues
{
    pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:returnValues];
    [self writeJavascript:[pluginResult toSuccessCallbackString:callbackId]];
}

-(void)returnSuccessValueForArray:(NSArray*)returnValues
{
    pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsArray:returnValues];
    [self writeJavascript:[pluginResult toSuccessCallbackString:callbackId]];
}

-(void)returnSuccessValueForString:(NSString*)returnString
{
    pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:returnString];
    [self writeJavascript:[pluginResult toSuccessCallbackString:callbackId]];
}

-(void)returnErrorValue:(int*)errorCode
{
    pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsInt:errorCode];
    [self writeJavascript:[pluginResult toErrorCallbackString:callbackId]];
}


// == Cordova Plugin Action Method ================================================================================

-(void)User_login:(CDVInvokedUrlCommand*)command
{
    callbackId = command.callbackId;
    [self checkArgumentsExists:command];
    NSDictionary* loginData = [[NSDictionary alloc] initWithDictionary:[command.arguments objectAtIndex:0] ];
    UserDelegate* mipUserLoginDelegate = [[UserDelegate alloc]initWithCDVPlugin:self ];
    [mipUserLoginDelegate userLogin:[loginData objectForKey:@"username"] :[loginData objectForKey:@"password"]];
    //NSLog(@"User_login");
}

-(void)User_logout:(CDVInvokedUrlCommand*)command
{
    callbackId = command.callbackId;
    UserDelegate* mipUserLoginDelegate = [[UserDelegate alloc]initWithCDVPlugin:self ];
    [mipUserLoginDelegate userLogout];
    //NSLog(@"User_logout");
}

-(void)User_getAuthKey:(CDVInvokedUrlCommand*)command
{
    callbackId = command.callbackId;
    UserDelegate* mipUserLoginDelegate = [[UserDelegate alloc]initWithCDVPlugin:self ];
    [mipUserLoginDelegate getAuthKey];
    //NSLog(@"User_getAuthKey");
}

-(void)Profile_retrieveResource:(CDVInvokedUrlCommand*)command
{
    callbackId = command.callbackId;
    [self checkArgumentsExists:command];
    ProfileDelegate* profileDelegate = [[ProfileDelegate alloc]initWithCDVPlugin:self];
    [profileDelegate retrieveResource:[[NSMutableArray alloc] initWithArray:[command.arguments objectAtIndex:0]]];
    //NSLog(@"Profile_retrieveResource");
}

-(void)Profile_retrieveQueryResource:(CDVInvokedUrlCommand*)command
{
    callbackId = command.callbackId;
    [self checkArgumentsExists:command];
    ProfileDelegate* profileDelegate = [[ProfileDelegate alloc]initWithCDVPlugin:self];
    [profileDelegate retrieveQueryResource:[[NSMutableArray alloc] initWithArray:[command.arguments objectAtIndex:0]]];
    //NSLog(@"Profile_retrieveQueryResource");
}

-(void)Geolocation_retrieveOwnResource:(CDVInvokedUrlCommand*)command
{
    callbackId = command.callbackId;
    GeolocationDelegate* geolocationDelegate = [[GeolocationDelegate alloc]initWithCDVPlugin:self];
    [geolocationDelegate retrieveOwnResource];
    //NSLog(@"Geolocation_retrieveOwnResource");
}

-(void)Geolocation_retrieveResource:(CDVInvokedUrlCommand*)command
{
    callbackId = command.callbackId;
    [self checkArgumentsExists:command];
    GeolocationDelegate* geolocationDelegate = [[GeolocationDelegate alloc]initWithCDVPlugin:self];
    [geolocationDelegate retrieveResource:[command.arguments objectAtIndex:0]];
    //NSLog(@"Geolocation_retrieveResource");
}

-(void)Geolocation_createResource:(CDVInvokedUrlCommand*)command
{
    callbackId = command.callbackId;
    [self checkArgumentsExists:command];
    GeolocationDelegate* geolocationDelegate = [[GeolocationDelegate alloc]initWithCDVPlugin:self];
        
    if([[command.arguments objectAtIndex:0] isKindOfClass:[NSDictionary class]])
    {
        [geolocationDelegate createResourceForDictionary:[command.arguments objectAtIndex:0]];
    }
    else if([[command.arguments objectAtIndex:0] isKindOfClass:[NSArray class]])
    {
        [geolocationDelegate createResourceForArray:[command.arguments objectAtIndex:0]];
    }
        
    //NSLog(@"Geolocation_createResource");
}

-(void)Geolocation_deleteResource:(CDVInvokedUrlCommand*)command
{
    callbackId = command.callbackId;
    [self checkArgumentsExists:command];
    GeolocationDelegate* geolocationDelegate = [[GeolocationDelegate alloc]initWithCDVPlugin:self];
    [geolocationDelegate deleteResource:(NSString*)[command.arguments objectAtIndex:0]];
    //NSLog(@"Geolocation_deleteResource");
}

-(void)Geolocation_retrieveQueryResource:(CDVInvokedUrlCommand*)command
{
    callbackId = command.callbackId;
    [self checkArgumentsExists:command];
    GeolocationDelegate* geolocationDelegate = [[GeolocationDelegate alloc]initWithCDVPlugin:self];
    [geolocationDelegate retrieveQueryResource:[command.arguments objectAtIndex:0]];
    //NSLog(@"Geolocation_retrieveQueryResource");
}

-(void)ApplicationResource_retrieveResource:(CDVInvokedUrlCommand*)command
{
    callbackId = command.callbackId;
    [self checkArgumentsExists:command];
    NSDictionary* resourceData = [[NSDictionary alloc] initWithDictionary:[command.arguments objectAtIndex:0] ];
    ApplicationResourceDelegate* applicationResourceDelegate = [[ApplicationResourceDelegate alloc]initWithCDVPlugin:self];
    [applicationResourceDelegate retrieveResource:[resourceData objectForKey:@"resourceName"] :[resourceData objectForKey:@"resourceId"]];
    //NSLog(@"ApplicationResource_retrieveResource");
}

-(void)ApplicationResource_retrieveQueryResource:(CDVInvokedUrlCommand*)command
{
    callbackId = command.callbackId;
    [self checkArgumentsExists:command];
    NSDictionary* resourceData = [[NSDictionary alloc] initWithDictionary:[command.arguments objectAtIndex:0] ];
    ApplicationResourceDelegate* applicationResourceDelegate = [[ApplicationResourceDelegate alloc]initWithCDVPlugin:self];
    [applicationResourceDelegate retrieveQueryResource:[resourceData objectForKey:@"resourceName"] :[command.arguments objectAtIndex:1]];
    //NSLog(@"ApplicationResource_retrieveQueryResourcet");
}

-(void)ApplicationResource_createResource:(CDVInvokedUrlCommand*)command
{
    callbackId = command.callbackId;
    [self checkArgumentsExists:command];
    NSDictionary* resourceData = [[NSDictionary alloc] initWithDictionary:[command.arguments objectAtIndex:0] ];
    ApplicationResourceDelegate* applicationResourceDelegate = [[ApplicationResourceDelegate alloc]initWithCDVPlugin:self];
    
    if([[resourceData objectForKey:@"requestJson"] isKindOfClass:[NSDictionary class]])
    {
        [applicationResourceDelegate createResourceForDictionary:[resourceData objectForKey:@"resourceName"] :[resourceData objectForKey:@"requestJson"]];
    }
    else if([[resourceData objectForKey:@"requestJson"] isKindOfClass:[NSArray class]])
    {
        [applicationResourceDelegate createResourceForArray:[resourceData objectForKey:@"resourceName"] :[resourceData objectForKey:@"requestJson"]];
    }
    //NSLog(@"ApplicationResource_createResource");
}
-(void)ApplicationResource_deleteResource:(CDVInvokedUrlCommand*)command
{
    callbackId = command.callbackId;
    [self checkArgumentsExists:command];
    NSDictionary* resourceData = [[NSDictionary alloc] initWithDictionary:[command.arguments objectAtIndex:0] ];
    ApplicationResourceDelegate* applicationResourceDelegate = [[ApplicationResourceDelegate alloc]initWithCDVPlugin:self];
    [applicationResourceDelegate deleteResource:[resourceData objectForKey:@"resourceName"] :[resourceData objectForKey:@"resourceId"]];
    //NSLog(@"ApplicationResource_deleteResource");
}

// === Check Method ==========================================================================

-(void)checkArgumentsExists:(CDVInvokedUrlCommand*)command
{    
     if ([[command.arguments objectAtIndex:0] isEqual:[NSNull null]])
     {
         [self returnErrorValue:internalError];
     }
}

@end
