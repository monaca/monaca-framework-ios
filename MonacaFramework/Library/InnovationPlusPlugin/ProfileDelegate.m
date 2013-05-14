//
//  ProfileDelegate.m
//  MonacaDebugger
//
//  Created by Shikata on 5/13/13.
//  Copyright (c) 2013 ASIAL CORPORATION. All rights reserved.
//

#import "ProfileDelegate.h"

@implementation ProfileDelegate

-(id)initWithCDVPlugin:(MIPCommunicationPlugin*)plugin
{
	self = [super init];
	if (self != nil)
    {
        cdvPlugin = plugin;
        MIPUtility* mipUtility = [[MIPUtility alloc]init];
        MFDelegate* mfDelegate = (MFDelegate *)[UIApplication sharedApplication].delegate;
        client = [[IPPProfileClient alloc] init];
        
        [client setAuthKey:[mipUtility getAuthKey]];
        [client setApplicationId:[[mfDelegate getApplicationPlist] objectForKey:@"application_id"]];

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
        NSArray* profiles = result;
        [cdvPlugin returnSuccessValueForArray:profiles];
    }

}

- (void)ippDidError:(int)code
{
    [cdvPlugin returnErrorValue:code];
}

@end
