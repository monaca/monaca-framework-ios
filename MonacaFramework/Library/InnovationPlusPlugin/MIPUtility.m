//
//  MIPUtility.m
//  MonacaDebugger
//
//  Created by Shikata on 5/13/13.
//  Copyright (c) 2013 ASIAL CORPORATION. All rights reserved.
//

#import "MIPUtility.h"

@implementation MIPUtility

-(NSMutableDictionary*)getMIPPlist
{
    NSMutableDictionary* plist = [NSMutableDictionary dictionaryWithContentsOfFile:[self dataFilePath]];
    if(plist)
    {
        return plist;
    }
    else
    {
        return  [NSDictionary dictionaryWithObjectsAndKeys:@"", @"auth_key",nil];
    }
}

-(void)updateMIPPlist:(NSString*)authKey
{
    //ファイルが存在しない場合(初回ロード時のみに使われる)
    if (![[NSFileManager defaultManager] fileExistsAtPath:[self dataFilePath]]) {
        
        NSMutableDictionary *temp = [NSDictionary dictionaryWithObjectsAndKeys:authKey, @"auth_key",nil];
        [temp writeToFile:[self dataFilePath] atomically:NO];
    }else{
    
        NSMutableDictionary* ippApplicationInfo = [NSMutableDictionary dictionaryWithContentsOfFile:[self dataFilePath]];
        [ippApplicationInfo setObject:authKey forKey:@"auth_key" ];
        [ippApplicationInfo writeToFile:[self dataFilePath] atomically:NO];
    }
}

-(NSString*)getAuthKey
{
    NSMutableDictionary* ippApplicationInfo = [self getMIPPlist];
    return [ippApplicationInfo objectForKey:@"auth_key"];
}

- (NSString *)dataFilePath {
	NSString* homeDirectoryPath = NSHomeDirectory();
	NSString* documentsDirectoryPath = [homeDirectoryPath stringByAppendingPathComponent:@"Documents"];
	NSString* plistPath = [documentsDirectoryPath stringByAppendingPathComponent:@"MICommunication-info.plist"];
	return plistPath;
}

@end
