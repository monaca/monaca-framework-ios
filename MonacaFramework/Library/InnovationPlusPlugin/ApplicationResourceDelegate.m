//
//  ApplicationResourceDelegate.m
//  MonacaDebugger
//
//  Created by Shikata on 5/13/13.
//  Copyright (c) 2013 ASIAL CORPORATION. All rights reserved.
//

#import "ApplicationResourceDelegate.h"

@implementation ApplicationResourceDelegate

-(id)initWithCDVPlugin:(MIPCommunicationPlugin*)plugin :(NSString*)plistApplicationId  :(NSString*)authKey
{
	self = [super init];
	if (self != nil)
    {
        cdvPlugin = plugin;
        client = [[IPPApplicationResourceClient alloc]init];
        [client setApplicationId:plistApplicationId];
        [client setAuthKey:authKey];

        multiCreateFrag =FALSE;
	}
	return self;
}

-(void)retrieveResource :(NSString*)resourceId :(NSString*)resourceName
{
    [client get:resourceName resourceId:resourceId callback:self];
}

-(void)retrieveQueryResource :(NSMutableDictionary*)condition :(NSString*)resourceName
{
    NSMutableDictionary* executeCondition = [[NSMutableDictionary alloc] init];
    NSDictionary* query = [condition objectForKey:@"query"];
    NSArray* keys = [query allKeys];
    for(int i = 0; i < [keys count]; i++ ){
        if(i>0){
            [executeCondition applicationresourceQuery_and];
        }
        
        if([[query objectForKey:[keys objectAtIndex:i]]  isKindOfClass:[NSString class]])
        {
            [executeCondition applicationresourceQuery_eqField:[keys objectAtIndex:i] withValue:[query objectForKey:[keys objectAtIndex:i]]];
        }
        else if ([[query objectForKey:[keys objectAtIndex:i]]  isKindOfClass:[NSNumber class]])
        {
            [executeCondition applicationresourceQuery_eqField:[keys objectAtIndex:i] withValue:[[NSNumber alloc] initWithInt:100111]];
            
        }
    }
    
    [executeCondition applicationresourceQuery_since:[condition objectForKey:@"since"]];
    [executeCondition applicationresourceQuery_until:[condition objectForKey:@"until"]];
    [executeCondition applicationresourceQuery_count:[condition objectForKey:@"count"]];
    [executeCondition applicationresourceQuery_self];
    [client query:resourceName condition:executeCondition callback:self];
}

-(void)createResourceForDictionary :(NSMutableDictionary*)resource :(NSString*)resourceName
{
    [client create:resourceName resource:resource callback:self];
}

-(void)createResourceForArray :(NSMutableArray*)resources :(NSString*)resourceName
{
    multiCreateFrag =TRUE;
    [client createAll:resourceName resources:resources callback:self];
}

-(void)deleteResource :(NSString*)resourceId :(NSString*)resourceName
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
