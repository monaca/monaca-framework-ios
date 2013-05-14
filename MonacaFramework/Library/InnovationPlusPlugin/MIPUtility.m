//
//  MIPUtility.m
//  MonacaDebugger
//
//  Created by Shikata on 5/13/13.
//  Copyright (c) 2013 ASIAL CORPORATION. All rights reserved.
//

#import "MIPUtility.h"

@implementation MIPUtility

-(NSString*)getMIPPlistPath
{
    return [[NSBundle mainBundle] pathForResource:@"MICommunication-info" ofType:@"plist"];
}

-(NSMutableDictionary*)getMIPPlist
{
    return [NSMutableDictionary dictionaryWithContentsOfFile:[self getMIPPlistPath]];
}

-(void)updateMIPPlist:(NSString*)authKey
{
    NSMutableDictionary* ippApplicationInfo = [self getMIPPlist];
    [ippApplicationInfo setObject:authKey forKey:@"auth_key" ];
    [ippApplicationInfo writeToFile:[self getMIPPlistPath] atomically:YES];
}

-(NSString*)getAuthKey
{
    NSMutableDictionary* ippApplicationInfo = [self getMIPPlist];
    return [ippApplicationInfo objectForKey:@"auth_key"];
}

@end
