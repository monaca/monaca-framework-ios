//
//  GeolocationDelegate.m
//  MonacaDebugger
//
//  Created by Shikata on 5/13/13.
//  Copyright (c) 2013 ASIAL CORPORATION. All rights reserved.
//

#import "GeolocationDelegate.h"

@implementation GeolocationDelegate

-(id)initWithCDVPlugin:(MIPCommunicationPlugin*)plugin :(NSString*)plistApplicationId  :(NSString*)authKey
{
	self = [super init];
	if (self != nil)
    {
        cdvPlugin = plugin;
        client = [[IPPGeoLocationClient alloc]init];
        [client setApplicationId:plistApplicationId];
        [client setAuthKey:authKey];
        multiCreateFrag =FALSE;
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
    multiCreateFrag =TRUE;
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
    NSMutableDictionary* query = [[NSMutableDictionary alloc] init];
    NSArray* bound = [condition objectForKey:@"bound"];
    if([bound count] > 0)
    {
        [query geolocationQuery_boundTop:[[bound objectAtIndex:0] doubleValue]
                                  bottom:[[bound objectAtIndex:1] doubleValue]
                                    left:[[bound objectAtIndex:2] doubleValue]
                                   right:[[bound objectAtIndex:3] doubleValue]];
    }
    NSArray* radiusSquare = [condition objectForKey:@"radiusSquare"];
    if([radiusSquare count] > 0)
    {
        [query geolocationQuery_radiusSquare:[[radiusSquare objectAtIndex:0] intValue]
                              centerLatitude:[[radiusSquare objectAtIndex:1] doubleValue]
                             centerLongitude:[[radiusSquare objectAtIndex:2] doubleValue]];
    }
    [query geolocationQuery_count:[condition objectForKey:@"count"]];
    [query geolocationQuery_self];
    [query geolocationQuery_since:[condition objectForKey:@"since"]];
    [query geolocationQuery_until:[condition objectForKey:@"until"]];

    [client query:query callback:self];
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
        
        NSDictionary *resultJsonData;
        if(multiCreateFrag)
        {
            resultJsonData = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt: [resources count]], @"resultCount", nil];
        }
        else
        {
            resultJsonData = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt: [resources count]], @"resultCount",resources, @"result",nil];
        }
        [cdvPlugin returnSuccessValueForJson:resultJsonData];
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
