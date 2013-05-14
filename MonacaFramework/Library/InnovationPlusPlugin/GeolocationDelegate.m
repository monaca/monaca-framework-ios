//
//  GeolocationDelegate.m
//  MonacaDebugger
//
//  Created by Shikata on 5/13/13.
//  Copyright (c) 2013 ASIAL CORPORATION. All rights reserved.
//

#import "GeolocationDelegate.h"

@implementation GeolocationDelegate

-(id)initWithCDVPlugin:(MIPCommunicationPlugin*)plugin
{
	self = [super init];
	if (self != nil)
    {
        cdvPlugin = plugin;
        MIPUtility* mipUtility = [[MIPUtility alloc]init];
        MFDelegate *mfDelegate = (MFDelegate *)[UIApplication sharedApplication].delegate;
        client = [[IPPGeoLocationClient alloc]init];
        [client setApplicationId:[[mfDelegate getApplicationPlist] objectForKey:@"application_id"]];
        [client setAuthKey:[mipUtility getAuthKey]];
	}
	return self;
}

-(void)retrieveOwnResource
{
    [client get:self];
}

-(void)retrieveResource:(NSString*)resourceId
{
    [client get:resourceId callback:self];
}

-(void)createResourceForArray:(NSMutableArray*)resources
{
    [client createAll:resources callback:self];
}

-(void)createResourceForDictionary:(NSMutableDictionary*)resources
{
    [client create:resources callback:self];
}

-(void)deleteResource:(NSString*)resourceId
{
    [client delete:resourceId callback:self];
}

-(void)retrieveQueryResource:(NSMutableDictionary*)condition
{
    [client query:condition callback:self];
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
