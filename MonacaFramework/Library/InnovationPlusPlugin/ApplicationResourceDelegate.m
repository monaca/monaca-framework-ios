//
//  ApplicationResourceDelegate.m
//  MonacaDebugger
//
//  Created by Shikata on 5/13/13.
//  Copyright (c) 2013 ASIAL CORPORATION. All rights reserved.
//

#import "ApplicationResourceDelegate.h"

@implementation ApplicationResourceDelegate

-(id)initWithCDVPlugin:(MIPCommunicationPlugin*)plugin
{
	self = [super init];
	if (self != nil)
    {
        cdvPlugin = plugin;
        MIPUtility* mipUtility = [[MIPUtility alloc]init];
        MFDelegate *mfDelegate = (MFDelegate *)[UIApplication sharedApplication].delegate;
        client = [[IPPApplicationResourceClient alloc]init];
        [client setApplicationId:[[mfDelegate getApplicationPlist] objectForKey:@"application_id"]];
        [client setAuthKey:[mipUtility getAuthKey]];
	}
	return self;
}

-(void)retrieveResource:(NSString*)resourceName :(NSString*)resourceId
{
    [client get:resourceName resourceId:resourceId callback:self];
}

-(void)retrieveQueryResource:(NSString*)resourceName :(NSMutableDictionary*)condition
{
    [client query:resourceName condition:condition callback:self];
}

-(void)createResourceForDictionary:(NSString*)resourceName :(NSMutableDictionary*)resource
{
    [client create:resourceName resource:resource callback:self];
}

-(void)createResourceForArray:(NSString*)resourceName :(NSMutableArray*)resources
{
    [client createAll:resourceName resources:resources callback:self];
}

-(void)deleteResource:(NSString*)resourceName :(NSString*)resourceId
{
    [client delete:resourceName resourceId:resourceId callback:self];
}

- (void)ippDidFinishLoading:(id)result
{
    if ([result isKindOfClass:[NSDictionary class]])
    {
        NSDictionary* resource = result;
        [cdvPlugin returnSuccessValueForJson:resource];
    }
    else if ([result isKindOfClass:[NSArray class]])
    {
        NSArray* resources = result;
        [cdvPlugin returnSuccessValueForArray:resources];
    }
    else if ([result isKindOfClass:[NSString class]])
    {
        NSString* resources = result;
        [cdvPlugin returnSuccessValueForString:resources];
    }
}

- (void)ippDidError:(int)code
{
    [cdvPlugin returnErrorValue:code];
}

@end
