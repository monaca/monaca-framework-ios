//
//  MIPCommunicationDelegate.m
//  MonacaDebugger
//
//  Created by Shikata on 5/10/13.
//  Copyright (c) 2013 ASIAL CORPORATION. All rights reserved.
//

#import "UserDelegate.h"

@implementation UserDelegate

-(id)initWithCDVPlugin:(MIPCommunicationPlugin*)plugin{
	self = [super init];
	if (self != nil) {
        cdvPlugin = plugin;
        mipUtility = [[MIPUtility alloc]init];
        MFDelegate *mfDelegate = (MFDelegate *)[UIApplication sharedApplication].delegate;
        applicationId = [[mfDelegate getApplicationPlist] objectForKey:@"application_id"];

	}
	return self;
}

-(void)userLogin:(NSString*)userName :(NSString*)userPassword
{
    IPPLoginClient* client = [[IPPLoginClient alloc]init];
    [client setApplicationId:applicationId];
    [client login:userName withPassword:userPassword callback:self];
}

- (void)ippDidFinishLoading:(id)result
{
    [mipUtility updateMIPPlist:[result objectForKey:@"auth_key"]];
    [cdvPlugin returnSuccessValueForJson:resultValues];
}

- (void)ippDidError:(int)code
{
    [cdvPlugin returnErrorValue:code];
}

-(void)getAuthKey
{
    [cdvPlugin returnSuccessValueForString:[[mipUtility getMIPPlist] objectForKey:@"auth_key"]];
}

-(void)userLogout
{
    @try
    {
        [mipUtility updateMIPPlist:@""];
    }@catch (NSException *exception)
    {
        [cdvPlugin returnErrorValue:-40];
    }
    @finally
    {
        [cdvPlugin returnSuccessValueForString:@"OK"];
    }
}

@end
