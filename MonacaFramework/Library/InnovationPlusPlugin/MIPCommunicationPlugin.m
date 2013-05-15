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

const int ERROR_notLogined = -20;
const int ERROR_internalError = -40;
const int ERROR_invalidParametersOrArguments = -60;
const int ERROR_applicationIdNotDefined = -80;

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
    
    if([self checkArgumentsExists:command] && [self checkApplicationIdExists] && [self checkIosVersion])
    {
        NSDictionary* loginData = [[NSDictionary alloc] initWithDictionary:[command.arguments objectAtIndex:0] ];
        UserDelegate* mipUserLoginDelegate = [[UserDelegate alloc]initWithCDVPlugin:self :[self getApplicationId]];
        [mipUserLoginDelegate userLogin:[loginData objectForKey:@"username"] :[loginData objectForKey:@"password"]];
    }
}

-(void)User_logout:(CDVInvokedUrlCommand*)command
{
    callbackId = command.callbackId;
    if([self checkApplicationIdExists] && [self checkIosVersion])
    {
        UserDelegate* mipUserLoginDelegate = [[UserDelegate alloc]initWithCDVPlugin:self :[self getApplicationId] ];
        [mipUserLoginDelegate userLogout];
    }
}

-(void)User_getAuthKey:(CDVInvokedUrlCommand*)command
{
    callbackId = command.callbackId;
    if([self checkApplicationIdExists] && [self checkIosVersion])
    {
        UserDelegate* mipUserLoginDelegate = [[UserDelegate alloc]initWithCDVPlugin:self :[self getApplicationId] ];
        [mipUserLoginDelegate getAuthKey];
    }
}

-(void)Profile_retrieveResource:(CDVInvokedUrlCommand*)command
{
    callbackId = command.callbackId;
    NSMutableArray* feelds;
    if(!([[command.arguments objectAtIndex:0] isEqual:[NSNull null]]))
    {
        feelds = [[NSMutableArray alloc] initWithArray:[command.arguments objectAtIndex:0]];
    }
    
    if([self checkAuthKeyAndApplicationIdExists] && [self checkIosVersion])
    {
        ProfileDelegate* profileDelegate = [[ProfileDelegate alloc]initWithCDVPlugin:self :[self getApplicationId]  :[self getAuthKey] ];
        [profileDelegate retrieveResource:feelds];
    }
}

-(void)Profile_retrieveQueryResource:(CDVInvokedUrlCommand*)command
{
    callbackId = command.callbackId;
    NSMutableArray* feelds;

    if(!([[command.arguments objectAtIndex:0] isEqual:[NSNull null]]))
    {
        feelds = [[NSMutableArray alloc] initWithArray:[command.arguments objectAtIndex:0]];
    }
    
    if([self checkAuthKeyAndApplicationIdExists] && [self checkIosVersion])
    {
        ProfileDelegate* profileDelegate = [[ProfileDelegate alloc]initWithCDVPlugin:self :[self getApplicationId]  :[self getAuthKey] ];
        [profileDelegate retrieveQueryResource:feelds];
    }
}

-(void)Geolocation_retrieveOwnResource:(CDVInvokedUrlCommand*)command
{
    callbackId = command.callbackId;
    if([self checkAuthKeyAndApplicationIdExists] && [self checkIosVersion])
    {
        GeolocationDelegate* geolocationDelegate = [[GeolocationDelegate alloc]initWithCDVPlugin:self :[self getApplicationId]  :[self getAuthKey]];
        [geolocationDelegate retrieveOwnResource];
    }
}

-(void)Geolocation_retrieveResource:(CDVInvokedUrlCommand*)command
{
    callbackId = command.callbackId;
    if([self checkAllParameterExists:command] && [self checkIosVersion])
    {
        GeolocationDelegate* geolocationDelegate = [[GeolocationDelegate alloc]initWithCDVPlugin:self :[self getApplicationId]  :[self getAuthKey]];
        [geolocationDelegate retrieveResource:[command.arguments objectAtIndex:0]];
    }
}

-(void)Geolocation_createResource:(CDVInvokedUrlCommand*)command
{
    callbackId = command.callbackId;
    if([self checkAllParameterExists:command] && [self checkIosVersion])
    {
        GeolocationDelegate* geolocationDelegate = [[GeolocationDelegate alloc]initWithCDVPlugin:self :[self getApplicationId]  :[self getAuthKey]];
        
        if([[command.arguments objectAtIndex:0] isKindOfClass:[NSDictionary class]])
        {
            [geolocationDelegate createResourceForDictionary:[command.arguments objectAtIndex:0]];
        }
        else if( [[command.arguments objectAtIndex:0] isKindOfClass:[NSArray class]])
        {
            [geolocationDelegate createResourceForArray:[command.arguments objectAtIndex:0]];
        }
    }
}

-(void)Geolocation_deleteResource:(CDVInvokedUrlCommand*)command
{
    callbackId = command.callbackId;
    if([self checkAllParameterExists:command] && [self checkIosVersion])
    {
        GeolocationDelegate* geolocationDelegate = [[GeolocationDelegate alloc]initWithCDVPlugin:self :[self getApplicationId]  :[self getAuthKey]];
        [geolocationDelegate deleteResource:(NSString*)[command.arguments objectAtIndex:0]];
    }
}

-(void)Geolocation_retrieveQueryResource:(CDVInvokedUrlCommand*)command
{
    callbackId = command.callbackId;
    if([self checkAllParameterExists:command] && [self checkIosVersion])
    {
        GeolocationDelegate* geolocationDelegate = [[GeolocationDelegate alloc]initWithCDVPlugin:self :[self getApplicationId]  :[self getAuthKey]];
        [geolocationDelegate retrieveQueryResource:[command.arguments objectAtIndex:0]];
    }
}

-(void)ApplicationResource_retrieveResource:(CDVInvokedUrlCommand*)command
{
    callbackId = command.callbackId;
    if([self checkAllParameterExists:command] && [self checkArgumentsExistsOfIndex:command :1] && [self checkIosVersion])
    {
        ApplicationResourceDelegate* applicationResourceDelegate = [[ApplicationResourceDelegate alloc]initWithCDVPlugin:self :[self getApplicationId] :[self getAuthKey]];
        [applicationResourceDelegate retrieveResource:[command.arguments objectAtIndex:0] :[command.arguments objectAtIndex:1]];
    }
}

-(void)ApplicationResource_retrieveQueryResource:(CDVInvokedUrlCommand*)command
{
    callbackId = command.callbackId;
    if([self checkAllParameterExists:command] && [self checkArgumentsExistsOfIndex:command :1] && [self checkIosVersion])
    {
        ApplicationResourceDelegate* applicationResourceDelegate = [[ApplicationResourceDelegate alloc]initWithCDVPlugin:self :[self getApplicationId] :[self getAuthKey]];
        [applicationResourceDelegate retrieveQueryResource:[command.arguments objectAtIndex:0] :[command.arguments objectAtIndex:1]];
    }
}

-(void)ApplicationResource_createResource:(CDVInvokedUrlCommand*)command
{
    callbackId = command.callbackId;

    if( [self checkAllParameterExists:command] && [self checkArgumentsExistsOfIndex:command :1] && [self checkIosVersion])
    {
        ApplicationResourceDelegate* applicationResourceDelegate = [[ApplicationResourceDelegate alloc]initWithCDVPlugin:self :[self getApplicationId] :[self getAuthKey]];
        
        if([[command.arguments objectAtIndex:0] isKindOfClass:[NSDictionary class]])
        {
            [applicationResourceDelegate createResourceForDictionary:[command.arguments objectAtIndex:0] :[command.arguments objectAtIndex:1] ];
        }
        else if([[command.arguments objectAtIndex:0]  isKindOfClass:[NSArray class]])
        {
            [applicationResourceDelegate createResourceForArray:[command.arguments objectAtIndex:0] :[command.arguments objectAtIndex:0] ];
        }
    }
}

-(void)ApplicationResource_deleteResource:(CDVInvokedUrlCommand*)command
{
    callbackId = command.callbackId;
    if([self checkAllParameterExists:command] && [self checkArgumentsExistsOfIndex:command :1] && [self checkIosVersion])
    {
        ApplicationResourceDelegate* applicationResourceDelegate = [[ApplicationResourceDelegate alloc]initWithCDVPlugin:self :[self getApplicationId]  :[self getAuthKey]];
        [applicationResourceDelegate deleteResource:[command.arguments objectAtIndex:0] :[command.arguments objectAtIndex:1]];
    }
}

// === Plugin Info Get Method ==========================================================================
-(NSString*)getApplicationId
{
    MFDelegate *mfDelegate = (MFDelegate *)[UIApplication sharedApplication].delegate;
    return [[mfDelegate getApplicationPlist] objectForKey:@"application_id"];
}

-(NSString*)getAuthKey
{
    MIPUtility* mipUtility = [[MIPUtility alloc]init];
    return [mipUtility getAuthKey];
}

// === Check Method ==========================================================================

-(BOOL)checkAllParameterExists:(CDVInvokedUrlCommand*)command
{
    if(![self checkArgumentsExists:command])
    {
        return FALSE;
    }
    
    if(![self checkAuthKeyAndApplicationIdExists])
    {
        return FALSE;
    }
    return TRUE;
}

-(BOOL)checkAuthKeyAndApplicationIdExists
{
    if(![self checkApplicationIdExists])
    {
        return FALSE;
    }
    
    if(![self checkAuthKeyExists])
    {
        return FALSE;
    }
    return TRUE;
}

-(BOOL)checkApplicationIdExists
{
    if ([[self getApplicationId] isEqual:[NSNull null]])
    {
        [self returnErrorValue:ERROR_applicationIdNotDefined];
        return FALSE;
    }
    
    return TRUE;
}

-(BOOL)checkAuthKeyExists
{
    if ([[self getAuthKey] isEqual:[NSNull null]])
    {
        [self returnErrorValue:ERROR_notLogined];
        return FALSE;
    }
    
    return TRUE;
}

-(BOOL)checkArgumentsExists:(CDVInvokedUrlCommand*)command
{    
     if ([[command.arguments objectAtIndex:0] isEqual:[NSNull null]])
     {
         [self returnErrorValue:ERROR_invalidParametersOrArguments];
         return FALSE;
     }
    
    return TRUE;
}

-(BOOL)checkArgumentsExistsOfIndex:(CDVInvokedUrlCommand*)command :(int)index
{
    if ([[command.arguments objectAtIndex:index] isEqual:[NSNull null]])
    {
        [self returnErrorValue:ERROR_invalidParametersOrArguments];
        return FALSE;
    }
    
    return TRUE;
}

-(BOOL)checkIosVersion
{
    NSArray *aOsVersions = [[[UIDevice currentDevice]systemVersion] componentsSeparatedByString:@"."];
    NSInteger iOsVersionMajor = [[aOsVersions objectAtIndex:0] intValue];
    if (iOsVersionMajor < 6)
    {
        [self returnErrorValue:ERROR_internalError];
        return FALSE;
    }
    
    return TRUE;
}

@end
