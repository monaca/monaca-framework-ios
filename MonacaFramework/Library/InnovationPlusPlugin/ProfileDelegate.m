//
//  ProfileDelegate.m
//  MonacaDebugger
//
//  Created by Shikata on 5/13/13.
//  Copyright (c) 2013 ASIAL CORPORATION. All rights reserved.
//

#import "ProfileDelegate.h"

@implementation ProfileDelegate

-(id)initWithCDVPlugin:(MIPCommunicationPlugin*)plugin :(NSString*)plistApplicationId  :(NSString*)authKey
{
	self = [super init];
	if (self != nil)
    {
        cdvPlugin = plugin;
        client = [[IPPProfileClient alloc] init];
        [client setAuthKey:authKey];
        [client setApplicationId:plistApplicationId];

	}
	return self;
}

-(void)retrieveResource:(NSMutableArray*)feelds
{
    if ([feelds count] > 0) {
        [client get:feelds callback:self];
    }else{
        [client get:self];
    }
}

-(void)retrieveQueryResource:(NSMutableArray*)feelds
{
    if ([feelds count] > 0) {
        
        
        [client query:feelds callback:self];
    }else{
        [client query:self];
    }
}

- (void)ippDidFinishLoading:(id)result
{
    if ([result isKindOfClass:[NSDictionary class]])
    {
        NSDictionary* profile = result;
        [cdvPlugin returnSuccessValueForJson:profile];
    }
    else if ([result isKindOfClass:[NSArray class]])
    {
        NSArray* resources = result;
        NSDictionary *resultJsonData = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt: [resources count]], @"resultCount",resources, @"result",nil];
        [cdvPlugin returnSuccessValueForJson:resultJsonData];
    }
}

- (void)ippDidError:(int)code
{
    [cdvPlugin returnErrorValue:code];
}

@end
