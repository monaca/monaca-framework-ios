//
//  MIPUtility.h
//  MonacaDebugger
//
//  Created by Shikata on 5/13/13.
//  Copyright (c) 2013 ASIAL CORPORATION. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MIPUtility : NSObject

-(NSMutableDictionary*)getMIPPlist;
-(void)updateMIPPlist:(NSString*)authKey;
-(NSString*)getAuthKey;
-(NSString*)dataFilePath;


@end
